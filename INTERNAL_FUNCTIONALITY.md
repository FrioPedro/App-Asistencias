# Documentación Técnica: App-Asistencias

## 1. Visión General

Esta aplicación móvil desarrollada en **Flutter** permite la gestión de asistencias (control de horarios, entradas/salidas) y actividades de personal. Funciona con una arquitectura "Offline-First", permitiendo operar sin conexión y sincronizando datos cuando hay red disponible.

## 2. Stack Tecnológico

- **UI Framework**: Flutter.
- **Base de Datos Local**: [Isar Database](https://isar.dev/) (NoSQL, altamente eficiente).
- **Cliente HTTP**: Dio (con interceptores para manejo de Tokens).
- **Sincronización en Segundo Plano**: Workmanager.
- **Inyección de Dependencias / Estado**: Uso de Singletons (`Database`, `EndpointService`) y Providers (custom).
- **Rutas**: GoRouter.

## 3. Estructura del Proyecto (`lib/`)

- **`core/`**: Infraestructura base.
  - `database.dart`: Singleton que maneja la conexión a Isar.
  - `enpoinService.dart`: Servicio HTTP singleton.
  - `sync_worker.dart`: Lógica para el worker de sincronización.
- **`models/`**: Definición de esquemas de Base de Datos (Isar) y generación de código (`.g.dart`).
- **`domain/`**: Lógica de negocio y casos de uso (ej. `create_activity.dart`).
- **`ui/`**: Widgets y pantallas de la aplicación.
- **`providers/`**: Gestión de estado y lógica de presentación.

## 4. Capa de Datos (Base de Datos Local)

La persistencia es el corazón de la app. Se utiliza **Isar**.

### Configuración (`core/database.dart`)

La clase `Database` implementa un Singleton.

- `Database.instance()`: Abre la instancia de Isar si no está abierta. Configura los esquemas: `ActivityModel`, `AssigmentModel`, `UserModel`, `NoteModel`.

### Modelo Principal: `ActivityModel` (`models/activity_model.dart`)

Representa un evento de asistencia (una marcación). **NOTA: Es un evento puntual (log), no un intervalo de tiempo.**

**Campos Clave:**

- `id` (Isar autoIncrement): ID local.
- `serverId` (int?): ID en el backend.
- `dedupKey` (String, Index unique): Clave para evitar duplicados.
  - Formato: `id:SERVERID|m:MOTIVE_INDEX|t:TASK_INDEX|a:TYPE_INDEX|dt:TIMESTAMP`
  - **Importante**: Usa los índices de los enums (0, 1...), no los IDs de negocio.
- `motive` (Enum `MotiveType`): `entry` (Entrada), `exit` (Salida).
- `task` (Enum `TaskType`): `office`, `workshop`, `service`, `transport`.
- `timestamp` (DateTime): Fecha y hora del evento.
- `isSynced` (bool): `true` si ya se envió al servidor.

**Enums y Mapeo:**

- **TaskType**:
  - Code: `office` (1), `workshop` (2), `service` (3), `transport` (4).
  - **OJO**: Al enviar al servidor (`toMarkPayload`), se usa el `id` (1-based). En `dedupKey` se usa `index` (0-based).
- **MotiveType**:
  - Code: `entry` (1), `exit` (2).

### Envío de Datos (`toMarkPayload`)

El método `toMarkPayload` convierte el objeto local a un Map JSON específico para el endpoint de marcación.

## 5. Sincronización y Backend

- **Endpoint**: `http://endpoint.frioteam.pe:8050`
- **Mecanismo**: `Workmanager` ejecuta una tarea periódica (`sync-task-1`) cada ~15 minutos (mínimo de Android) o cuando se dispara manualmente, verificando conectividad (WiFi/Datos).
- Los registros con `isSynced = false` son candidatos a subida.

---

## 6. Guía para Modificar la Base de Datos (Contexto para LLM)

Si necesitas realizar cambios en la estructura de datos (ej. agregar un campo a una tabla), sigue este flujo estricto:

### Paso 1: Modificar el Modelo

Edita el archivo en `lib/models/` (ej. `activity_model.dart`).

```dart
@collection
class ActivityModel {
  // ... campos existentes ...

  // NUEVO CAMPO
  String? nuevoDato; // Recomendable usar nulos para evitar migraciones complejas
}
```

### Paso 2: Generar Código (Build Runner)

Isar requiere generación de código para actualizar los esquemas y adaptadores binarios.
Ejecuta en la terminal:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Paso 3: Actualizar Lógica de Mapeo

1.  **Desde Server (`fromServer`)**: Si el dato viene del API, asignalo en el constructor `fromServer`.
2.  **Hacia Server (`toMarkPayload`)**: Si el dato debe subirse, agrégalo al Map retornado.
3.  **Deduplicación**: Si el nuevo campo cambia la unicidad del registro, debes actualizar la lógica de `buildDedupKey`.

### Paso 4: Propagar a UI

Actualiza los formularios de creación (ej. en `lib/domain/activity/create_activity.dart` o `lib/ui/...`) para permitir ingresar o visualizar el nuevo dato.

### Consideraciones

- **Migraciones**: Isar maneja automáticamente la adición de campos (los registros viejos tendrán `null`). Cambiar tipos de datos o renombrar campos sin migración manual (script) puede causar pérdida de datos en el campo afectado.
- **Tipos de Datos**: Isar soporta `String`, `int`, `double`, `bool`, `DateTime`, `List<>` y Enums (guardados como índices o enteros).
