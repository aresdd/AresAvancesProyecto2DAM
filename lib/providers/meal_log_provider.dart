import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../models/consumable.dart';
import '../models/meal_entry.dart';

/// In-memory meal log (no local storage, no backend).
class MealLogNotifier extends StateNotifier<List<MealEntry>> {
  MealLogNotifier({Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(const []);

  final Uuid _uuid;

  void seed(List<MealEntry> entries) {
    // Seed only if empty, so we don't duplicate when rebuilding.
    if (state.isNotEmpty) return;
    state = List<MealEntry>.of(entries);
  }

  void addMeal({required Consumable item, required double grams, DateTime? at}) {
    final entry = MealEntry(
      id: _uuid.v4(),
      item: item,
      grams: grams,
      createdAt: at ?? DateTime.now(),
    );
    state = [...state, entry]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void reset() {
    state = const [];
  }

  List<MealEntry> mealsForDay(DateTime day) {
    return state.where((m) => DateUtilsX.isSameDay(m.createdAt, day)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

final mealLogProvider =
    StateNotifierProvider<MealLogNotifier, List<MealEntry>>((ref) {
  return MealLogNotifier();
});

