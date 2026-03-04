import 'dart:math';

import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../models/food.dart';
import '../models/meal_entry.dart';

/// Seeds the app with mock meal history (last 7 days).
class MockSeedService {
  MockSeedService({Uuid? uuid, Random? random})
      : _uuid = uuid ?? const Uuid(),
        _random = random ?? Random();

  final Uuid _uuid;
  final Random _random;

  List<MealEntry> generateLast7DaysHistory(List<Food> foods) {
    final now = DateTime.now();
    final List<MealEntry> entries = [];

    for (int daysAgo = 0; daysAgo < 7; daysAgo++) {
      final day = DateUtilsX.startOfDay(now.subtract(Duration(days: daysAgo)));
      final mealsCount = 2 + _random.nextInt(3); // 2..4 meals/day

      for (int i = 0; i < mealsCount; i++) {
        final food = foods[_random.nextInt(foods.length)];
        final grams = 80 + _random.nextInt(220); // 80..299g
        final time = day.add(Duration(hours: 8 + (i * 4) + _random.nextInt(2)));
        entries.add(
          MealEntry(
            id: _uuid.v4(),
            item: food,
            grams: grams.toDouble(),
            createdAt: time,
          ),
        );
      }
    }

    // Keep chronological order.
    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }
}

