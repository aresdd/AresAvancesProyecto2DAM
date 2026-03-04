/// Sex used by metabolic formulas (Mifflin-St Jeor / Harris-Benedict).
enum Sex {
  male,
  female,
}

extension SexX on Sex {
  String get label {
    switch (this) {
      case Sex.male:
        return 'Hombre';
      case Sex.female:
        return 'Mujer';
    }
  }
}

