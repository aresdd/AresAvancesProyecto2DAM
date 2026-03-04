import 'macros.dart';

/// Something that can be logged as a meal (Food or custom Dish).
///
/// It exposes nutrition values per 100g to keep calculations consistent.
abstract class Consumable {
  String get id;
  String get name;
  Macros get macrosPer100g;

  double get caloriesPer100g => macrosPer100g.calories;
}

