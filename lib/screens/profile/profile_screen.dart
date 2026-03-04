import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/utils/date_utils.dart';
import '../../models/nutrition_goal.dart';
import '../../models/sex.dart';
import '../../models/activity_level.dart';
import '../../providers/meal_log_provider.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

/// Profile: user data + targets + actions (edit/reset).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final targets = ref.watch(targetsProvider);
    final meals = ref.watch(mealLogProvider);
    final lastMeals = meals.reversed.take(8).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? 'Sin perfil' : user.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  user == null
                      ? 'Completa tu registro para personalizar objetivos.'
                      : '${user.sex.label} · ${user.ageYears} años · ${user.activityLevel.label}\n'
                          '${user.weightKg.toStringAsFixed(1)} kg · ${user.heightCm.toStringAsFixed(0)} cm · ${user.goal.label}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _TargetTile(
                        label: 'Objetivo kcal',
                        value: targets.calorieTarget.toStringAsFixed(0),
                        color: AppColors.energyBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TargetTile(
                        label: 'Proteína (g)',
                        value: targets.macroTarget.proteinG.toStringAsFixed(0),
                        color: AppColors.healthGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TargetTile(
                        label: 'Carbos (g)',
                        value: targets.macroTarget.carbsG.toStringAsFixed(0),
                        color: AppColors.energyBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TargetTile(
                        label: 'Grasas (g)',
                        value: targets.macroTarget.fatG.toStringAsFixed(0),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: user == null ? 'Completar registro' : 'Editar datos',
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      user == null ? AppRoutes.register : AppRoutes.editProfile,
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Reset progreso (borrar comidas)',
                  variant: CustomButtonVariant.tonal,
                  icon: Icons.restart_alt,
                  onPressed: () {
                    ref.read(mealLogProvider.notifier).reset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progreso reseteado (mock).')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Cerrar sesión (mock)',
                  variant: CustomButtonVariant.text,
                  icon: Icons.logout,
                  onPressed: () {
                    ref.read(userProvider.notifier).reset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada (mock).')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Historial (últimos registros)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        if (lastMeals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aún no hay historial. Añade una comida para empezar.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ...lastMeals.map(
            (m) => Card(
              child: ListTile(
                title: Text(m.item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${DateUtilsX.shortDate(m.createdAt)} · '
                  '${m.grams.toStringAsFixed(0)}g · '
                  '${m.calories.toStringAsFixed(0)} kcal',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

