import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/dish.dart';
import '../models/food.dart';

/// In-memory list of custom dishes (platos combinados).
class DishesNotifier extends StateNotifier<List<Dish>> {
  DishesNotifier({Uuid? uuid}) : _uuid = uuid ?? const Uuid(), super(const []);

  final Uuid _uuid;

  void addDish({
    required String name,
    required List<DishIngredient> ingredients,
  }) {
    final dish = Dish(id: _uuid.v4(), name: name.trim(), ingredients: ingredients);
    state = [...state, dish];
  }

  void removeDish(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void updateDish(Dish dish, {required String name, required List<DishIngredient> ingredients}) {
    final updated = Dish(
      id: dish.id,
      name: name.trim(),
      ingredients: ingredients,
    );
    state = state.map((d) => d.id == dish.id ? updated : d).toList();
  }

  void reset() {
    state = const [];
  }

  Dish? byId(String id) {
    for (final d in state) {
      if (d.id == id) return d;
    }
    return null;
  }
}

final dishesProvider = StateNotifierProvider<DishesNotifier, List<Dish>>((ref) {
  return DishesNotifier();
});

/// Helper provider: all dishes as a flat list of ingredients' foods.
/// (Useful for UI if needed later.)
final dishFoodsProvider = Provider<List<Food>>((ref) {
  final dishes = ref.watch(dishesProvider);
  final foods = <Food>{};
  for (final d in dishes) {
    for (final i in d.ingredients) {
      foods.add(i.food);
    }
  }
  return foods.toList();
});

