import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';
import '../models/macros.dart';
import 'meal_log_provider.dart';

/// Calories for last 7 days (oldest -> newest).
final last7DaysCaloriesProvider = Provider<List<double>>((ref) {
  final meals = ref.watch(mealLogProvider);
  final now = DateTime.now();

  final List<double> values = [];
  for (int i = 6; i >= 0; i--) {
    final day = DateUtilsX.startOfDay(now.subtract(Duration(days: i)));
    final dayMeals = meals.where((m) => DateUtilsX.isSameDay(m.createdAt, day));
    final calories = dayMeals.fold<double>(0.0, (sum, m) => sum + m.calories);
    values.add(calories);
  }
  return values;
});

/// Weekly macro distribution (sum of grams for last 7 days).
final weeklyMacroDistributionProvider = Provider<Macros>((ref) {
  final meals = ref.watch(mealLogProvider);
  final now = DateTime.now();
  final start = DateUtilsX.startOfDay(now.subtract(const Duration(days: 6)));
  final filtered = meals.where((m) => m.createdAt.isAfter(start.subtract(const Duration(seconds: 1))));
  return filtered.fold(const Macros.zero(), (sum, m) => sum + m.macros);
});

