import 'package:flutter/foundation.dart';

import 'consumable.dart';
import 'macros.dart';

/// Food item with nutrition values per 100g.
@immutable
class Food implements Consumable {
  const Food({
    required this.id,
    required this.name,
    required this.macrosPer100g,
    this.labelImagePath,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final Macros macrosPer100g;
  final String? labelImagePath;

  @override
  double get caloriesPer100g => macrosPer100g.calories;
}

