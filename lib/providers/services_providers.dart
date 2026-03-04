import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/goal_calculator.dart';
import '../services/mock_food_service.dart';
import '../services/mock_seed_service.dart';
import '../services/nutrition_label_ocr_service.dart';

/// Providers for pure services (no UI state).
final mockFoodServiceProvider = Provider<MockFoodService>((ref) {
  return const MockFoodService();
});

final goalCalculatorProvider = Provider<GoalCalculator>((ref) {
  return const GoalCalculator();
});

final mockSeedServiceProvider = Provider<MockSeedService>((ref) {
  return MockSeedService();
});

final nutritionLabelOcrServiceProvider = Provider<NutritionLabelOcrService>((ref) {
  return NutritionLabelOcrService();
});

