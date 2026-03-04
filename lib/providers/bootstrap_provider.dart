import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'food_provider.dart';
import 'meal_log_provider.dart';
import 'services_providers.dart';

/// App bootstrap: load mock foods and seed mock history.
///
/// Called from Splash to simulate initial API loading.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  final foods = await ref.watch(foodsProvider.future);
  final seedService = ref.read(mockSeedServiceProvider);
  final entries = seedService.generateLast7DaysHistory(foods);

  ref.read(mealLogProvider.notifier).seed(entries);
});

