import 'package:flutter/foundation.dart';

import 'consumable.dart';
import 'food.dart';
import 'macros.dart';

/// Ingredient of a custom dish (food + grams inside the dish).
@immutable
class DishIngredient {
  const DishIngredient({
    required this.food,
    required this.grams,
  });

  final Food food;
  final double grams;

  Macros get macros => food.macrosPer100g.scale(grams / 100.0);
}

/// Custom combined dish created by the user.
///
/// Internally it stores a list of ingredients and exposes computed macros per 100g
/// so the rest of the app can treat it like a normal "food" when logging.
@immutable
class Dish implements Consumable {
  const Dish({
    required this.id,
    required this.name,
    required this.ingredients,
  });

  @override
  final String id;
  @override
  final String name;

  final List<DishIngredient> ingredients;

  double get totalGrams =>
      ingredients.fold<double>(0.0, (sum, i) => sum + i.grams).clamp(0.0, double.infinity);

  Macros get macrosTotal =>
      ingredients.fold(const Macros.zero(), (sum, i) => sum + i.macros);

  @override
  Macros get macrosPer100g {
    final grams = totalGrams;
    if (grams <= 0) return const Macros.zero();
    return macrosTotal.scale(100.0 / grams);
  }

  // Because this class uses `implements`, we must implement all members,
  // including getters with default bodies in the interface.
  @override
  double get caloriesPer100g => macrosPer100g.calories;
}

