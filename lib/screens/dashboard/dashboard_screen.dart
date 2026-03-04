import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/utils/date_utils.dart';
import '../../models/meal_entry.dart';
import '../../providers/home_tab_provider.dart';
import '../../providers/meal_log_provider.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/macro_progress_card.dart';

/// Home dashboard: daily macros + quick actions + today's meals.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final targets = ref.watch(targetsProvider);
    final today = DateTime.now();
    final todayMacros = ref.watch(todayMacrosProvider);
    final meals = ref.watch(mealLogProvider);
    final todayMeals = meals
        .where((m) => DateUtilsX.isSameDay(m.createdAt, today))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        MacroProgressCard(
          caloriesConsumed: todayMacros.calories,
          caloriesTarget: targets.calorieTarget,
          proteinG: todayMacros.proteinG,
          proteinTargetG: targets.macroTarget.proteinG,
          fatG: todayMacros.fatG,
          fatTargetG: targets.macroTarget.fatG,
          carbsG: todayMacros.carbsG,
          carbsTargetG: targets.macroTarget.carbsG,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accesos rápidos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Buscar',
                        variant: CustomButtonVariant.tonal,
                        icon: Icons.search,
                        onPressed: () {
                          ref.read(homeTabIndexProvider.notifier).state = 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Platos',
                        variant: CustomButtonVariant.tonal,
                        icon: Icons.menu_book_outlined,
                        onPressed: () {
                          ref.read(homeTabIndexProvider.notifier).state = 2;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Estadísticas',
                  variant: CustomButtonVariant.tonal,
                  icon: Icons.insights,
                  onPressed: () {
                    ref.read(homeTabIndexProvider.notifier).state = 3;
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: user == null ? 'Completar perfil' : 'Editar perfil',
                  variant: CustomButtonVariant.text,
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      user == null ? AppRoutes.register : AppRoutes.editProfile,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Comidas de hoy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            Text(
              '${todayMeals.length} registros',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.neutralGray),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (todayMeals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aún no has añadido comidas hoy. Pulsa “Añadir comida”.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ...todayMeals.map((m) => _MealTile(entry: m)),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.entry});

  final MealEntry entry;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: const Icon(Icons.restaurant_menu),
        ),
        title: Text(
          entry.item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${entry.grams.toStringAsFixed(0)} g · '
          '${entry.calories.toStringAsFixed(0)} kcal · '
          'P ${entry.macros.proteinG.toStringAsFixed(0)} · '
          'C ${entry.macros.carbsG.toStringAsFixed(0)} · '
          'G ${entry.macros.fatG.toStringAsFixed(0)}',
        ),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}

