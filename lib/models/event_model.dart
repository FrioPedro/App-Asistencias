import 'package:flutter/material.dart';

// El Enum que ya usabas
enum EventType { other, technicalVisit, emergency }

class EventModel {
  final String id;
  final String name;
  final String company;
  final String code;
  final String dateTime;
  final EventType type;

  EventModel({
    required this.id,
    required this.name,
    required this.company,
    required this.code,
    required this.dateTime,
    required this.type,
  });

  // Factory para cuando venga la data real del Backend (JSON)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      company: json['company'] ?? '',
      code: json['code'] ?? '',
      dateTime: json['date_time'] ?? '', // Ajustar según backend
      type: _mapStringToType(json['type']),
    );
  }

  static EventType _mapStringToType(String? type) {
    switch (type) {
      case 'technicalVisit': return EventType.technicalVisit;
      case 'emergency': return EventType.emergency;
      default: return EventType.other;
    }
  }
}