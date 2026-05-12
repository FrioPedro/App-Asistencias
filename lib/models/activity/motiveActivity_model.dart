enum MotiveActivity{
  endWork,
  startWork,
}

extension MotiveactivityX on MotiveActivity{
  int get id {
    switch(this) {
      case MotiveActivity.endWork:
        return 2;
      case MotiveActivity.startWork:
        return 1;
    }
  }

  static MotiveActivity fromLabel(String? label){
    final s = (label ?? '').trim().toLowerCase();

    if (s == "fin de labores") return MotiveActivity.endWork;
    if (s == "inicio de labores") return MotiveActivity.startWork;

    return MotiveActivity.startWork;
  }
}