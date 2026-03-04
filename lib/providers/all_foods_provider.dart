import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food.dart';
import 'custom_foods_provider.dart';
import 'food_provider.dart';

/// Combined list: mock foods + user-created foods.
final allFoodsProvider = Provider<AsyncValue<List<Food>>>((ref) {
  final async = ref.watch(foodsProvider);
  final custom = ref.watch(customFoodsProvider);
  return async.whenData((list) => [...list, ...custom]);
});
