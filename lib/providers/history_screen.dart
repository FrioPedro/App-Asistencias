import 'package:flutter/material.dart';

import '../../models/activity_model.dart';
import '../../providers/history_provider.dart';
import 'package:app_asistencias/ui/widgets/event_card.dart';
import 'package:app_asistencias/ui/widgets/event_card_skeleton.dart'; // Para el estado de carga

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryProvider _provider = HistoryProvider();
  late Future<List<ActivityModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Usamos un Future para que el FutureBuilder se encargue del estado
    setState(() {
      _historyFuture = _provider.fetchHistory();
    });
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Fecha desconocida';

    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Historial de Actividad', style: TextStyle(color: Colors.white)),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: const Color(0xFF1E1E1E),
        child: FutureBuilder<List<ActivityModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoader();
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  snapshot.hasError ? 'Error al cargar' : 'No hay registros',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            final history = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final activity = history[index];
                return EventCard(
                  eventName: activity.description ?? 'Sin Descripción',
                  companyName: activity.client ?? 'Cliente no especificado',
                  eventCode: 'ID Asignación: ${activity.serverId}',
                  dateTime: _formatTimestamp(activity.timestamp),
                  motive: activity.motive, // <-- ¡Aquí usamos el nuevo parámetro!
                  assigmentType: activity.activityType,
                  hasPendingSync: !(activity.isSynced ?? true),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => const EventCardSkeleton(),
    );
  }
}
