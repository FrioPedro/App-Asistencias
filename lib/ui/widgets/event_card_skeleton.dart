import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      height: 140, // Altura aproximada de tu EventCard real
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt, // Mismo fondo que tu tarjeta
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      // El widget Shimmer anima todo lo que está adentro
      child: Shimmer.fromColors(
        // Colores ajustados para tu tema oscuro:
        baseColor: Colors.white.withOpacity(0.05), // Gris muy oscuro
        highlightColor: Colors.white.withOpacity(0.1), // Brillo más claro
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Subtítulo (Barra mediana)
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Código (Barra corta)
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // DERECHA (Simulando el Tag o Ícono)
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sheet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
