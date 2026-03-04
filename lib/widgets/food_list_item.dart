import 'package:flutter/material.dart';

import '../models/consumable.dart';

/// List tile for a consumable (Food or custom Dish).
class FoodListItem extends StatelessWidget {
  const FoodListItem({
    super.key,
    required this.item,
    required this.onAdd,
    this.badge,
  });

  final Consumable item;
  final VoidCallback onAdd;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final m = item.macrosPer100g;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${item.caloriesPer100g.toStringAsFixed(0)} kcal · '
          'P ${m.proteinG.toStringAsFixed(0)}g · '
          'C ${m.carbsG.toStringAsFixed(0)}g · '
          'G ${m.fatG.toStringAsFixed(0)}g (por 100g)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  badge!,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
            ],
            IconButton.filledTonal(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

