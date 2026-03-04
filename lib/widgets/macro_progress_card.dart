import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'nutrient_bar.dart';

/// Card that shows daily calories + macros progress.
class MacroProgressCard extends StatelessWidget {
  const MacroProgressCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinG,
    required this.proteinTargetG,
    required this.fatG,
    required this.fatTargetG,
    required this.carbsG,
    required this.carbsTargetG,
  });

  final double caloriesConsumed;
  final double caloriesTarget;
  final double proteinG;
  final double proteinTargetG;
  final double fatG;
  final double fatTargetG;
  final double carbsG;
  final double carbsTargetG;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final calProgress = (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'Hoy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '${caloriesConsumed.toStringAsFixed(0)} / ${caloriesTarget.toStringAsFixed(0)} kcal',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: calProgress,
                minHeight: 12,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            NutrientBar(
              label: 'Proteínas',
              valueLabel:
                  '${proteinG.toStringAsFixed(0)} / ${proteinTargetG.toStringAsFixed(0)} g',
              progress: proteinG / proteinTargetG,
              color: AppColors.healthGreen,
            ),
            const SizedBox(height: 12),
            NutrientBar(
              label: 'Carbohidratos',
              valueLabel:
                  '${carbsG.toStringAsFixed(0)} / ${carbsTargetG.toStringAsFixed(0)} g',
              progress: carbsG / carbsTargetG,
              color: AppColors.energyBlue,
            ),
            const SizedBox(height: 12),
            NutrientBar(
              label: 'Grasas',
              valueLabel:
                  '${fatG.toStringAsFixed(0)} / ${fatTargetG.toStringAsFixed(0)} g',
              progress: fatG / fatTargetG,
              color: scheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

