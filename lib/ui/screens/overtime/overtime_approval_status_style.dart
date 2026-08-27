import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/overtime_request_model.dart';

/// Color de estado de una solicitud de horas extras. Lo consumen la tarjeta de
/// `OvertimeRequestsScreen` y `OvertimeDetailSheet`, que tienen que coincidir.
extension OvertimeStatusStyle on OvertimeStatus {
  Color get color {
    switch (this) {
      case OvertimeStatus.approved:
        return AppColors.success;
      case OvertimeStatus.rejected:
        return AppColors.danger;
      case OvertimeStatus.pending:
        return AppColors.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case OvertimeStatus.approved:
        return Icons.check_circle;
      case OvertimeStatus.rejected:
        return Icons.cancel;
      case OvertimeStatus.pending:
        return Icons.hourglass_top;
    }
  }
}
