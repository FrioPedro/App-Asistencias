# Módulo KeyGroup - Documentación de Uso

## Descripción

El módulo KeyGroup proporciona funcionalidades extendidas para trabajar con la variable `keyGroup` que agrupa asistencias relacionadas (entrada/salida de un mismo evento).

## Estructura del Módulo

```
lib/
├── domain/
│   └── keygroup/
│       ├── keygroup.dart              # Barrel de exportación
│       ├── keygroup_service.dart      # Servicio principal
│       └── keygroup_extensions.dart   # Extensiones de utilidad
├── providers/
│   └── keygroup_stats_provider.dart   # Proveedor de estadísticas
└── ui/
    └── widgets/
        └── session_group_card.dart    # Widget de visualización
```

## Uso Básico

### 1. Importar el módulo

```dart
import 'package:app_asistencias/domain/keygroup/keygroup.dart';
```

### 2. Usar el servicio KeyGroupService

```dart
final service = KeyGroupService();

// Obtener actividades por keyGroup
final activities = await service.getActivitiesByKeyGroup('ABC123...');

// Obtener estadísticas de un keyGroup
final stats = await service.getKeyGroupStats('ABC123...');
print('Duración total: ${stats?.totalDuration}');
print('¿Completado?: ${stats?.isComplete}');

// Obtener sesiones de hoy
final todaySessions = await service.getSessionsByDay(DateTime.now());

// Obtener sesiones de la semana actual
final weekData = await service.getCurrentWeekSessions();
print('Total grupos: ${weekData.totalGroups}');
print('Tiempo trabajado: ${weekData.totalWorkedTime}');

// Obtener sesiones activas (sin cerrar)
final activeSessions = await service.getActiveSessions();
```

### 3. Usar las extensiones de ActivitySession

```dart
import 'package:app_asistencias/domain/keygroup/keygroup_extensions.dart';

// Las extensiones se aplican automáticamente a ActivitySession
final session = sessions.first;

print('Duración: ${session.formattedDuration}');
print('Rango de tiempo: ${session.timeRange}');
print('¿En curso?: ${session.isOngoing}');
print('¿Es hoy?: ${session.isToday}');
print('Resumen: ${session.summary}');

// Extensiones para listas
print('Tiempo total: ${sessions.formattedTotalWorkedTime}');
final todaySessions = sessions.todaySessions;
final completedSessions = sessions.completedSessions;
final byDay = sessions.groupedByDay;
final byTask = sessions.groupedByTaskType;
```

### 4. Usar el KeyGroupStatsProvider

```dart
import 'package:app_asistencias/providers/keygroup_stats_provider.dart';

final statsProvider = KeyGroupStatsProvider();

// Estadísticas de hoy
final todayStats = await statsProvider.getTodayStats();
print('Sesiones: ${todayStats.totalSessions}');
print('Completadas: ${todayStats.completedSessions}');
print('Tiempo total: ${todayStats.formattedTotalTime}');

// Estadísticas de la semana
final weekStats = await statsProvider.getCurrentWeekStats();
print('Día más activo: ${weekStats.busiestDayName}');

// Resumen rápido para UI
final summary = await statsProvider.getQuickSummary();
print('Hoy: ${summary['todaySessions']} sesiones');
print('Pendientes de sync: ${summary['pendingSync']}');
```

### 5. Usar el widget SessionGroupCard

```dart
import 'package:app_asistencias/ui/widgets/session_group_card.dart';

// Tarjeta completa
SessionGroupCard(
  session: session,
  onTap: () => print('Tap en ${session.keyGroup}'),
  showKeyGroup: true, // Mostrar el ID del grupo
);

// Tarjeta compacta
SessionGroupCard(
  session: session,
  compactMode: true,
);
```

## Modelos de Datos

### KeyGroupStats

- `keyGroup`: Identificador del grupo
- `totalEvents`: Número total de eventos
- `entryCount`: Conteo de entradas
- `exitCount`: Conteo de salidas
- `totalDuration`: Duración total (si está cerrado)
- `isComplete`: Si tiene entrada y salida
- `hasPendingSync`: Si hay eventos pendientes de sync
- `isActive`: Si está en curso (sin cerrar)

### DailyStats

- `date`: Fecha del día
- `totalSessions`: Total de sesiones
- `completedSessions`: Sesiones completadas
- `ongoingSessions`: Sesiones en curso
- `totalWorkedTime`: Tiempo total trabajado
- `averageSessionDuration`: Duración promedio

### WeeklyStats

- `weekStart` / `weekEnd`: Rango de la semana
- `dailyBreakdown`: Estadísticas por día
- `totalSessions`: Total de la semana
- `totalWorkedTime`: Tiempo trabajado en la semana
- `busiestDayName`: Día con más actividad

## Notas Importantes

- El `keyGroup` es un identificador único de 16 caracteres generado con SHA256
- Se genera a partir de: `assigmentId`, `collaboratorDocumentId` y `timestamp`
- Las funciones existentes en `history_provider.dart` no fueron modificadas
- Este módulo extiende la funcionalidad sin alterar la lógica original
