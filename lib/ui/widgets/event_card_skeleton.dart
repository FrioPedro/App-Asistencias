import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140, // Altura aproximada de tu EventCard real
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F), // Mismo fondo que tu tarjeta
        borderRadius: BorderRadius.circular(16),
      ),
      // El widget Shimmer anima todo lo que está adentro
      child: Shimmer.fromColors(
        // Colores ajustados para tu tema oscuro:
        baseColor: Colors.white.withValues(alpha: 0.05),      // Gris muy oscuro
        highlightColor: Colors.white.withValues(alpha: 0.1),  // Brillo más claro
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // COLUMNA IZQUIERDA (Simulando Textos)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título (Barra larga)
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtítulo (Barra mediana)
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Código (Barra corta)
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // DERECHA (Simulando el Tag o Ícono)
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}