import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';
import '../models/macros.dart';
import '../models/nutrition_targets.dart';
import 'meal_log_provider.dart';
import 'services_providers.dart';
import 'user_provider.dart';

/// Daily nutrition targets based on user profile (or defaults when not registered).
final targetsProvider = Provider<NutritionTargets>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    // Safe defaults for unauthenticated mock state (UI preview).
    return const NutritionTargets(
      calorieTarget: 2200,
      macroTarget: Macros(proteinG: 140, carbsG: 240, fatG: 70),
    );
  }
  return ref.read(goalCalculatorProvider).targetsFor(user);
});

/// Total macros consumed for a given day.
final dayMacrosProvider = Provider.family<Macros, DateTime>((ref, day) {
  final meals = ref.watch(mealLogProvider);
  final start = DateUtilsX.startOfDay(day);
  final filtered = meals.where((m) => DateUtilsX.isSameDay(m.createdAt, start));
  return filtered.fold(const Macros.zero(), (sum, m) => sum + m.macros);
});

/// Convenience: today's totals.
final todayMacrosProvider = Provider<Macros>((ref) {
  return ref.watch(dayMacrosProvider(DateTime.now()));
});

