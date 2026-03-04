import 'package:flutter/foundation.dart';

import 'consumable.dart';
import 'macros.dart';

/// A meal record logged by the user for a specific date/time.
@immutable
class MealEntry {
  const MealEntry({
    required this.id,
    required this.item,
    required this.grams,
    required this.createdAt,
  });

  final String id;
  final Consumable item;
  final double grams;
  final DateTime createdAt;

  /// Calculated macros for the logged grams.
  Macros get macros => item.macrosPer100g.scale(grams / 100.0);

  double get calories => macros.calories;
}

