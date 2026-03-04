import '../models/macros.dart';
import '../models/sex.dart';
import '../models/activity_level.dart';
import '../models/nutrition_goal.dart';
import '../models/nutrition_targets.dart';
import '../models/user_profile.dart';

/// Calculates daily calories using the formulas referenced in FitGeneration:
/// - BMR via Mifflin-St Jeor (1990) (most used variant today)
/// - TDEE via activity multiplier
/// - Goal adjustment (deficit/surplus)
///
/// Source (Spanish): https://fitgeneration.es/calculadora/harris-benedict/
class GoalCalculator {
  const GoalCalculator();

  NutritionTargets targetsFor(UserProfile user) {
    final bmr = _mifflinStJeorBmr(
      weightKg: user.weightKg,
      heightCm: user.heightCm,
      ageYears: user.ageYears,
      isMale: user.sex == Sex.male,
    );

    final tdee = bmr * user.activityLevel.multiplier;

    // Goal adjustment (kept moderate for adherence).
    final adjusted = switch (user.goal) {
      NutritionGoal.loseFat => tdee * 0.85, // ~15% deficit
      NutritionGoal.gainMuscle => tdee * 1.10, // ~10% surplus
      NutritionGoal.maintain => tdee,
    };

    final calorieTarget = adjusted.clamp(1200.0, 4200.0);

    // Protein: prioritize for gym goals.
    final proteinG = switch (user.goal) {
      NutritionGoal.loseFat => user.weightKg * 2.0,
      NutritionGoal.gainMuscle => user.weightKg * 2.0,
      NutritionGoal.maintain => user.weightKg * 1.8,
    };

    // Fat: minimum essential intake.
    final fatG = user.weightKg * 0.8;

    // Carbs fill the rest.
    final remainingCalories = calorieTarget - (proteinG * 4.0) - (fatG * 9.0);
    final carbsG = (remainingCalories / 4.0).clamp(0.0, 500.0);

    return NutritionTargets(
      calorieTarget: calorieTarget,
      macroTarget: Macros(proteinG: proteinG, carbsG: carbsG, fatG: fatG),
    );
  }

  /// Mifflin-St Jeor BMR (kcal/day).
  ///
  /// Men: 10W + 6.25H - 5A + 5
  /// Women: 10W + 6.25H - 5A - 161
  double _mifflinStJeorBmr({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required bool isMale,
  }) {
    final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * ageYears);
    return isMale ? (base + 5.0) : (base - 161.0);
  }
}

