import 'package:flutter/foundation.dart';

import 'activity_level.dart';
import 'nutrition_goal.dart';
import 'sex.dart';

/// Local in-memory user profile (mock, no real auth).
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    required this.sex,
    required this.activityLevel,
    required this.goal,
  });

  final String name;
  final double weightKg;
  final double heightCm;
  final int ageYears;
  final Sex sex;
  final ActivityLevel activityLevel;
  final NutritionGoal goal;

  UserProfile copyWith({
    String? name,
    double? weightKg,
    double? heightCm,
    int? ageYears,
    Sex? sex,
    ActivityLevel? activityLevel,
    NutritionGoal? goal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      ageYears: ageYears ?? this.ageYears,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }
}

