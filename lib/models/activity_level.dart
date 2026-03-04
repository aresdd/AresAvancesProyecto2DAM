/// Activity factor for estimating TDEE from BMR.
///
/// Common multipliers used in nutrition calculators.
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  intense,
  veryIntense,
}

extension ActivityLevelX on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentario';
      case ActivityLevel.light:
        return 'Actividad ligera (1-3 días/sem)';
      case ActivityLevel.moderate:
        return 'Actividad moderada (3-5 días/sem)';
      case ActivityLevel.intense:
        return 'Actividad intensa (6-7 días/sem)';
      case ActivityLevel.veryIntense:
        return 'Muy intensa (diario + trabajo físico)';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.intense:
        return 1.725;
      case ActivityLevel.veryIntense:
        return 1.9;
    }
  }
}

