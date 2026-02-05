import 'package:flutter/material.dart';

enum TaskType { office, workshop, service, transport }

extension TaskTypeX on TaskType {
  int get id {
    switch (this) {
      case TaskType.office:
        return 1;
      case TaskType.workshop:
        return 2;
      case TaskType.service:
        return 3;
      case TaskType.transport:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case TaskType.office:
        return 'Oficina';
      case TaskType.workshop:
        return 'Taller';
      case TaskType.service:
        return 'Servicio';
      case TaskType.transport:
        return 'Transporte';
    }
  }

  static TaskType fromId(int? id) {
    switch (id) {
      case 1:
        return TaskType.office;
      case 2:
        return TaskType.workshop;
      case 3:
        return TaskType.service;
      case 4:
        return TaskType.transport;
      default:
        return TaskType.office;
    }
  }

  static TaskType fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();
    if (s == 'oficina') return TaskType.office;
    if (s == 'taller') return TaskType.workshop;
    if (s == 'servicio') return TaskType.service;
    if (s == 'transporte') return TaskType.transport;
    return TaskType.office;
  }

  Color get color {
    switch (this) {
      case TaskType.office:
        return Colors.grey;
      case TaskType.workshop:
        return Colors.green;
      case TaskType.service:
        return Colors.blue;
      case TaskType.transport:
        return Colors.orange;
    }
  }
}
