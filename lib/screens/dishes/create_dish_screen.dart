import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dish.dart';
import '../../models/food.dart';
import '../../models/macros.dart';
import '../../providers/all_foods_provider.dart';
import '../../providers/dishes_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen to create a combined dish using multiple foods.
class CreateDishScreen extends ConsumerStatefulWidget {
  const CreateDishScreen({super.key});

  @override
  ConsumerState<CreateDishScreen> createState() => _CreateDishScreenState();
}

class _CreateDishScreenState extends ConsumerState<CreateDishScreen> {
  final _nameCtrl = TextEditingController();
  final List<DishIngredient> _ingredients = [];
  bool _saving = false;
  Dish? _editingDish;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _initFromRoute(BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Dish) {
      _editingDish = arg;
      _nameCtrl.text = arg.name;
      _ingredients.addAll(arg.ingredients);
    }
  }

  double get _totalGrams =>
      _ingredients.fold<double>(0.0, (sum, i) => sum + i.grams);

  Macros get _totalMacros =>
      _ingredients.fold(const Macros.zero(), (sum, i) => sum + i.macros);

  Future<void> _addIngredient(BuildContext context, List<Food> foods) async {
    final result = await showModalBottomSheet<_IngredientDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _IngredientPickerSheet(foods: foods),
    );
    if (result == null) return;
    setState(() {
      _ingredients.add(DishIngredient(food: result.food, grams: result.grams));
    });
  }

  Future<void> _saveDish() async {
    final name = _nameCtrl.text.trim().isEmpty ? 'Plato personalizado' : _nameCtrl.text.trim();
    if (_ingredients.isEmpty) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final notifier = ref.read(dishesProvider.notifier);
    if (_editingDish != null) {
      notifier.updateDish(_editingDish!, name: name, ingredients: List.of(_ingredients));
    } else {
      notifier.addDish(name: name, ingredients: List.of(_ingredients));
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _initFromRoute(context);
    final foodsAsync = ref.watch(allFoodsProvider);
    final scheme = Theme.of(context).colorScheme;
    final macros = _totalMacros;
    final grams = _totalGrams;
    final per100 = grams <= 0 ? const Macros.zero() : macros.scale(100 / grams);
    final isEditing = _editingDish != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar plato' : 'Crear plato')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: 'Nombre del plato',
                      controller: _nameCtrl,
                      prefixIcon: Icons.restaurant_outlined,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (_ingredients.isEmpty)
                      Text(
                        'Añade alimentos y sus gramos para formar el plato.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      )
                    else
                      ..._ingredients.asMap().entries.map((e) {
                        final idx = e.key;
                        final ing = e.value;
                        return Card(
                          color: scheme.surfaceContainerLow,
                          child: ListTile(
                            title: Text(ing.food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${ing.grams.toStringAsFixed(0)} g'),
                            trailing: IconButton(
                              onPressed: () => setState(() => _ingredients.removeAt(idx)),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 10),
                    foodsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (foods) => CustomButton(
                        label: 'Añadir ingrediente',
                        icon: Icons.add,
                        variant: CustomButtonVariant.tonal,
                        onPressed: () => _addIngredient(context, foods),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Macros del plato',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _MacroRow(label: 'Total gramos', value: '${grams.toStringAsFixed(0)} g'),
                    _MacroRow(label: 'Kcal total', value: macros.calories.toStringAsFixed(0)),
                    _MacroRow(label: 'Proteína (g)', value: macros.proteinG.toStringAsFixed(0)),
                    _MacroRow(label: 'Carbo (g)', value: macros.carbsG.toStringAsFixed(0)),
                    _MacroRow(label: 'Grasa (g)', value: macros.fatG.toStringAsFixed(0)),
                    const Divider(height: 24),
                    Text(
                      'Por 100g (para logging)',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    _MacroRow(label: 'Kcal/100g', value: per100.calories.toStringAsFixed(0)),
                    _MacroRow(label: 'P/100g', value: per100.proteinG.toStringAsFixed(0)),
                    _MacroRow(label: 'C/100g', value: per100.carbsG.toStringAsFixed(0)),
                    _MacroRow(label: 'G/100g', value: per100.fatG.toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(
              label: isEditing ? 'Guardar cambios' : 'Guardar plato',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: (_ingredients.isNotEmpty) ? _saveDish : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _IngredientDraft {
  const _IngredientDraft({required this.food, required this.grams});

  final Food food;
  final double grams;
}

class _IngredientPickerSheet extends StatefulWidget {
  const _IngredientPickerSheet({required this.foods});

  final List<Food> foods;

  @override
  State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  Food? _food;
  final _gramsCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _food = widget.foods.isEmpty ? null : widget.foods.first;
  }

  @override
  void dispose() {
    _gramsCtrl.dispose();
    super.dispose();
  }

  double get _grams => (double.tryParse(_gramsCtrl.text.replaceAll(',', '.')) ?? 0)
      .clamp(0, 2000)
      .toDouble();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Añadir ingrediente',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Food>(
            initialValue: _food,
            items: widget.foods
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _food = v),
            decoration: const InputDecoration(
              labelText: 'Alimento',
              prefixIcon: Icon(Icons.restaurant),
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Gramos',
            controller: _gramsCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.scale_outlined,
          ),
          const SizedBox(height: 14),
          CustomButton(
            label: 'Añadir',
            icon: Icons.add,
            onPressed: (_food != null && _grams > 0)
                ? () => Navigator.of(context).pop(
                      _IngredientDraft(food: _food!, grams: _grams),
                    )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: luego podrás “loggear” el plato como si fuese un alimento por gramos.',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

