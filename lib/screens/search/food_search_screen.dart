import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../models/food.dart';
import '../../providers/all_foods_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/food_list_item.dart';

/// Food search (mock list).
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(allFoodsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Buscar alimento',
                  controller: _searchCtrl,
                  prefixIcon: Icons.search,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Crear alimento',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createFood),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: foodsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error cargando alimentos: $e'),
              ),
              data: (foods) {
                final filtered = _filterFoods(foods, _query);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Sin resultados.'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final food = filtered[index];
                    return FoodListItem(
                      item: food,
                      onAdd: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.addMeal,
                          arguments: food,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Food> _filterFoods(List<Food> foods, String query) {
    if (query.isEmpty) return foods;
    return foods.where((f) => f.name.toLowerCase().contains(query)).toList();
  }
}

