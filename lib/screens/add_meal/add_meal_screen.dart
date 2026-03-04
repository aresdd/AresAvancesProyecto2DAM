import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/consumable.dart';
import '../../models/dish.dart';
import '../../models/food.dart';
import '../../models/macros.dart';
import '../../providers/all_foods_provider.dart';
import '../../providers/dishes_provider.dart';
import '../../providers/meal_log_provider.dart';
import '../../core/navigation/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Add meal modal: select food + grams, calculate macros, save to today's log.
class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  int _segment = 0; // 0 foods, 1 dishes
  Consumable? _selected;
  final _gramsCtrl = TextEditingController(text: '150');
  bool _saving = false;

  @override
  void dispose() {
    _gramsCtrl.dispose();
    super.dispose();
  }

  bool get _isDishSelected => _segment == 1 && _selected is Dish;

  double get _grams {
    // For dishes, the logged grams are always the sum of ingredients.
    final item = _selected;
    if (item is Dish) return item.totalGrams;
    return (double.tryParse(_gramsCtrl.text.replaceAll(',', '.')) ?? 0)
        .clamp(0, 2000)
        .toDouble();
  }

  Macros _computedMacros() {
    final item = _selected;
    if (item == null) return const Macros.zero();
    return item.macrosPer100g.scale(_grams / 100.0);
  }

  Future<void> _save() async {
    final item = _selected;
    if (item == null || _grams <= 0) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    ref.read(mealLogProvider.notifier).addMeal(item: item, grams: _grams);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Preselect item if passed as navigation argument.
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (_selected == null && arg is Consumable) {
      _selected = arg;
      _segment = arg is Dish ? 1 : 0;
    }

    final foodsAsync = ref.watch(allFoodsProvider);
    final dishes = ref.watch(dishesProvider);
    final scheme = Theme.of(context).colorScheme;

    // If a dish is selected, keep the grams field synced and locked.
    final selectedNow = _selected;
    if (selectedNow is Dish) {
      final shouldBe = selectedNow.totalGrams.toStringAsFixed(0);
      if (_gramsCtrl.text != shouldBe) {
        _gramsCtrl.text = shouldBe;
      }
    }

    final macros = _computedMacros();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap outside to dismiss.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Añadir comida',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<int>(
                              segments: const [
                                ButtonSegment(value: 0, label: Text('Alimento')),
                                ButtonSegment(value: 1, label: Text('Plato')),
                              ],
                              selected: {_segment},
                              onSelectionChanged: (s) {
                                setState(() {
                                  _segment = s.first;
                                  _selected = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            tooltip: _segment == 0 ? 'Crear alimento' : 'Crear plato',
                            onPressed: () async {
                              if (_segment == 0) {
                                final result = await Navigator.of(context).pushNamed(AppRoutes.createFood);
                                if (result is Food && mounted) setState(() => _selected = result);
                              } else {
                                Navigator.of(context).pushNamed(AppRoutes.createDish);
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_segment == 0)
                        foodsAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e, _) => Text('Error: $e'),
                          data: (foods) {
                            if (_selected == null || _selected is! Food) {
                              _selected = foods.firstOrNull;
                            }
                            return DropdownButtonFormField<Food>(
                              initialValue: _selected as Food?,
                              items: foods
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f.name, overflow: TextOverflow.ellipsis),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _selected = v),
                              decoration: const InputDecoration(
                                labelText: 'Alimento',
                                prefixIcon: Icon(Icons.restaurant),
                              ),
                            );
                          },
                        )
                      else
                        DropdownButtonFormField<Dish>(
                          initialValue: _selected is Dish ? _selected as Dish : null,
                          items: dishes
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selected = v);
                            if (v != null) {
                              _gramsCtrl.text = v.totalGrams.toStringAsFixed(0);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Plato',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                        ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: _isDishSelected
                            ? 'Peso del plato (g) (auto)'
                            : 'Cantidad (gramos)',
                        controller: _gramsCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.scale_outlined,
                        readOnly: _isDishSelected,
                        enabled: !_isDishSelected,
                        onChanged: _isDishSelected ? null : (_) => setState(() {}),
                      ),
                      if (_isDishSelected) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Este plato se registra con su peso total (suma de ingredientes).',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Card(
                        color: scheme.surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: _MacroChip(
                                  label: 'Kcal',
                                  value: macros.calories.toStringAsFixed(0),
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MacroChip(
                                  label: 'P',
                                  value: macros.proteinG.toStringAsFixed(0),
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MacroChip(
                                  label: 'C',
                                  value: macros.carbsG.toStringAsFixed(0),
                                  color: scheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MacroChip(
                                  label: 'G',
                                  value: macros.fatG.toStringAsFixed(0),
                                  color: scheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomButton(
                        label: 'Guardar en consumo diario',
                        icon: Icons.check,
                        isLoading: _saving,
                        onPressed: (_selected != null && _grams > 0) ? _save : null,
                      ),
                      const SizedBox(height: 6),
                      CustomButton(
                        label: 'Cancelar',
                        variant: CustomButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
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
          const SizedBox(height: 4),
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

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

