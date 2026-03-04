import 'package:flutter/foundation.dart';

import 'macros.dart';

/// Daily targets (calories + macro grams).
@immutable
class NutritionTargets {
  const NutritionTargets({
    required this.calorieTarget,
    required this.macroTarget,
  });

  final double calorieTarget;
  final Macros macroTarget;
}

