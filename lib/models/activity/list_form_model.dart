enum ListForm {
  foto_antes,
  foto_despues,
  acciones,
  incidencias,
  conclusiones,
  recomendaciones,
}

extension ListFormX on ListForm {
  int get id {
    switch (this) {
      case ListForm.foto_antes:
        return 1;
      case ListForm.foto_despues:
        return 2;
      case ListForm.acciones:
        return 3;
      case ListForm.incidencias:
        return 4;
      case ListForm.conclusiones:
        return 5;
      case ListForm.recomendaciones:
        return 6;
    }
  }

  static ListForm fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();

    if (s == "foto antes") return ListForm.foto_antes;
    if (s == "foto despues" || s == "foto después")
      return ListForm.foto_despues;
    if (s == "acciones") return ListForm.acciones;
    if (s == "incidencias" || s == "indicencias") return ListForm.incidencias;
    if (s == "conclusiones") return ListForm.conclusiones;
    if (s == "recomendaciones") return ListForm.recomendaciones;

    return ListForm.foto_antes;
  }

  String get label {
    switch (this) {
      case ListForm.foto_antes:
        return "Foto antes";
      case ListForm.foto_despues:
        return "Foto después";
      case ListForm.acciones:
        return "Acciones";
      case ListForm.incidencias:
        return "Incidencias";
      case ListForm.conclusiones:
        return "Conclusiones";
      case ListForm.recomendaciones:
        return "Recomendaciones";
    }
  }
}
