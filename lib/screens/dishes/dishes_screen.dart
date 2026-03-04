import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../models/dish.dart';
import '../../providers/dishes_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Tab to manage and view custom dishes (platos combinados).
class DishesScreen extends ConsumerStatefulWidget {
  const DishesScreen({super.key});

  @override
  ConsumerState<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends ConsumerState<DishesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dishes = ref.watch(dishesProvider);
    final filtered = _filter(dishes, _query);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Buscar plato',
                controller: _searchCtrl,
                prefixIcon: Icons.search,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: 'Crear plato',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createDish),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dishes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Aún no tienes platos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crea platos combinados (varios alimentos) para añadirlos al día más rápido.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else if (filtered.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Sin resultados.')))
        else
          ...filtered.map((d) => _DishCard(dish: d)),
        if (dishes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CustomButton(
              label: 'Crear mi primer plato',
              icon: Icons.menu_book_outlined,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createDish),
            ),
          ),
      ],
    );
  }

  List<Dish> _filter(List<Dish> dishes, String q) {
    if (q.isEmpty) return dishes;
    return dishes.where((d) => d.name.toLowerCase().contains(q)).toList();
  }
}

class _DishCard extends ConsumerWidget {
  const _DishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalGrams = dish.totalGrams;
    final kcalTotal = dish.macrosTotal.calories;
    final kcalPer100 = dish.caloriesPer100g;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          '${totalGrams.toStringAsFixed(0)} g · '
          '${kcalTotal.toStringAsFixed(0)} kcal total · '
          '${kcalPer100.toStringAsFixed(0)} kcal/100g',
        ),
        leading: CircleAvatar(
          backgroundColor: scheme.secondary.withOpacity(0.12),
          child: const Icon(Icons.menu_book_outlined),
        ),
        onTap: () => _showDetails(context, ref, dish),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              tooltip: 'Opciones',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).pushNamed(AppRoutes.createDish, arguments: dish);
                } else if (value == 'delete') {
                  _confirmDelete(context, ref, dish);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Editar')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20), SizedBox(width: 12), Text('Eliminar')])),
              ],
            ),
            IconButton.filledTonal(
              tooltip: 'Añadir al día',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.addMeal, arguments: dish);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Dish dish) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar plato'),
        content: Text('¿Eliminar "${dish.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(dishesProvider.notifier).removeDish(dish.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plato eliminado')));
    }
  }

  void _showDetails(BuildContext context, WidgetRef ref, Dish dish) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dish.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${dish.totalGrams.toStringAsFixed(0)} g · ${dish.macrosTotal.calories.toStringAsFixed(0)} kcal',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingredientes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              for (final i in dish.ingredients)
                Card(
                  color: scheme.surfaceContainerLow,
                  child: ListTile(
                    title: Text(i.food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${i.grams.toStringAsFixed(0)} g'),
                  ),
                ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Añadir al consumo diario',
                icon: Icons.add,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.addMeal, arguments: dish);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Editar',
                      icon: Icons.edit_outlined,
                      variant: CustomButtonVariant.tonal,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).pushNamed(AppRoutes.createDish, arguments: dish);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Eliminar',
                      icon: Icons.delete_outline,
                      variant: CustomButtonVariant.tonal,
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar plato'),
                            content: Text('¿Eliminar "${dish.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          ref.read(dishesProvider.notifier).removeDish(dish.id);
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plato eliminado')));
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

