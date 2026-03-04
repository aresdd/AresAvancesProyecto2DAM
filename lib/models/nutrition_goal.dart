/// Fitness goal selected by the user.
enum NutritionGoal {
  loseFat,
  gainMuscle,
  maintain,
}

extension NutritionGoalX on NutritionGoal {
  String get label {
    switch (this) {
      case NutritionGoal.loseFat:
        return 'Perder grasa';
      case NutritionGoal.gainMuscle:
        return 'Ganar músculo';
      case NutritionGoal.maintain:
        return 'Mantener peso';
    }
  }
}

