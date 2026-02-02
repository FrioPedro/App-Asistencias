# Implementación de Sesión Unificada y Token Offline

Este documento detalla la arquitectura de **"Sesión Unificada"** implementada para manejar la asistencia, centrada en el uso de un **Token Único** generado localmente. Este enfoque resuelve los problemas de inconsistencia entre marcas de entrada y salida, especialmente en entornos con conectividad inestable.

---

## 1. Concepto Core: De "Marcas" a "Sesiones"

Anteriormente, el sistema guardaba una fila por cada evento (una fila para entrada, otra para salida). Esto causaba problemas de "huérfanos".

**Nuevo Modelo:**

- **Una fila en base de datos (`ActivityModel`) representa toda la sesión de trabajo.**
- Tiene un campo `entryTimestamp` (obligatorio) y un campo `exitTimestamp` (opcional/nulo).
- **Estado:**
  - Si `exitTimestamp == null` → La sesión está **ABIERTA** (En curso).
  - Si `exitTimestamp != null` → La sesión está **CERRADA** (Finalizada).

---

## 2. El Token de Sesión (`token`)

El `token` es la pieza clave que vincula la entrada y la salida, tanto localmente como en el servidor.

### Características

- **Generación Local:** Se crea inmediatamente cuando el usuario da "Ingresar". No esperamos al servidor.
- **Formato:** `SESS-{timestamp}-{random}` (ej. `SESS-1701234567890-55921`).
- **Inmutabilidad:** Una vez creado para una sesión, nunca cambia.

### Estructura de Datos (`ActivityModel`)

```dart
@collection
class ActivityModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true) // Clave primaria lógica
  late String token;

  late DateTime entryTimestamp;
  DateTime? exitTimestamp; // Nulo = Activo

  // ... otros campos (latitud, longitud, serverId, etc)
}
```

---

## 3. Flujo de Datos

### A. Creación (Inicio de Jornada)

Cuando el usuario pulsa **"INGRESAR"**:

1. Se instancia un `ActivityModel`.
2. Se genera el `token` único.
3. Se guarda en Isar localmente.
4. **Estado:** `isSynced = false`.

### B. Cierre (Fin de Jornada)

Cuando el usuario pulsa **"SALIDA"**:

1. El sistema busca en Isar la última actividad que tenga `exitTimestamp == null` para ese proyecto.
2. **¡No se crea una fila nueva!** Se actualiza la fila existente.
3. Se establece `exitTimestamp = DateTime.now()`.
4. Se marca `isSynced = false` (para forzar resubida).

### C. Sincronización (Estrategia "Double-Send")

El servicio de sincronización (`syncService.dart`) se encarga de traducir este modelo unificado al protocolo que espera el backend (que podría seguir esperando eventos separados "Entrada/Salida").

**Algoritmo de Sync:**

1. Iterar sobre actividades con `isSynced = false`.
2. **Enviar Entrada:**
   - Construir payload con `motive: 1` (Entrada) y el `token`.
   - Enviar al endpoint.
3. **Enviar Salida** (Solo si la sesión local ya está cerrada):
   - Construir payload con `motive: 2` (Salida) y el **mismo `token`**.
   - Enviar al endpoint.
   - El servidor usa el token para "cerrar" la sesión que abrió en el paso 2.

---

## 4. Recuperación de Datos (Server -> Local)

Para asegurar que si el usuario reinstala la app o limpia datos, recupere su historial correctamente:

### `syncOnlineToLocal`

1. Descarga el historial del servidor.
2. Para cada registro que llega:
   - **Match Fuerte:** Busca en Isar local si existe un registro con el mismo `token`.
   - **Match Débil (Fallback):** Si no hay token (data legacy), busca por `ServerID` + `Rango de Hora`.
   - Si encuentra match, actualiza el registro local (ej. actualiza la hora de salida si se cerró en web).
   - Si no, inserta uno nuevo.

---

## 5. Guía de Implementación Rápida (Reset DB)

Si vas a reiniciar la base de datos o implementar esto desde cero:

1. **Modelo de Datos:**
   Asegúrate de que tu `ActivityModel` tenga el campo `token` inicializado en el constructor si es nulo.

   ```dart
   ActivityModel({String? token, ...}) {
     this.token = token ?? 'SESS-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';
   }
   ```

2. **Deduplicación:**
   Usa el `token` como tu "External ID". Evita usar IDs autoincrementables del servidor para lógica de negocio local.

3. **Backend:**
   El backend debe estar preparado recibir el campo `token` (o `session_token`).
   - Al recibir `motive: 1` + `token X`: Crea sesión X.
   - Al recibir `motive: 2` + `token X`: Busca sesión X y ponle hora de fin.

Siguiendo este esquema, la aplicación es robusta ante fallos de red, duplicidad de clics y pérdida de datos local.
