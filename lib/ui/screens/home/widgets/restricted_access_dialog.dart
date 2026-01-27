import 'package:flutter/material.dart';

class RestrictedAccessDialog extends StatelessWidget {
  const RestrictedAccessDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => const RestrictedAccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_filled, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text('Horario Restringido',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                  'No se pueden crear actividades en este horario.\n\nHorario permitido:\nLun - Vie: 8:00 PM - 6:00 AM\nSáb - Dom: Todo el día',
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
