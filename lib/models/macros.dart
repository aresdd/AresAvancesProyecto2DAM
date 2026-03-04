import 'package:flutter/foundation.dart';

/// Macro nutrients in grams (protein / carbs / fat).
@immutable
class Macros {
  const Macros({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;

  const Macros.zero()
      : proteinG = 0,
        carbsG = 0,
        fatG = 0;

  double get calories =>
      (proteinG * 4.0) + (carbsG * 4.0) + (fatG * 9.0);

  Macros operator +(Macros other) => Macros(
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
      );

  Macros scale(double factor) => Macros(
        proteinG: proteinG * factor,
        carbsG: carbsG * factor,
        fatG: fatG * factor,
      );

  Macros copyWith({
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) {
    return Macros(
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }
}

