import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/food.dart';
import '../models/macros.dart';

/// User-created foods (in-memory). Merged with mock list for selection.
class CustomFoodsNotifier extends StateNotifier<List<Food>> {
  CustomFoodsNotifier({Uuid? uuid}) : _uuid = uuid ?? const Uuid(), super(const []);

  final Uuid _uuid;

  /// Returns the created food (e.g. to preselect in Add meal).
  Food addFood({
    required String name,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    String? labelImagePath,
  }) {
    final food = Food(
      id: 'custom_${_uuid.v4()}',
      name: name.trim(),
      macrosPer100g: Macros(
        proteinG: proteinPer100g.clamp(0, 100),
        carbsG: carbsPer100g.clamp(0, 100),
        fatG: fatPer100g.clamp(0, 100),
      ),
      labelImagePath: labelImagePath,
    );
    state = [...state, food];
    return food;
  }

  void removeFood(String id) {
    state = state.where((f) => f.id != id).toList();
  }
}

final customFoodsProvider = StateNotifierProvider<CustomFoodsNotifier, List<Food>>((ref) {
  return CustomFoodsNotifier();
});
