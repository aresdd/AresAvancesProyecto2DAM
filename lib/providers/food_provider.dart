import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food.dart';
import 'services_providers.dart';

/// Fetches foods from mock API (simulated latency).
final foodsProvider = FutureProvider<List<Food>>((ref) async {
  final service = ref.read(mockFoodServiceProvider);
  return service.fetchFoods();
});

