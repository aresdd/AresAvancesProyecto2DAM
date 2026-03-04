import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../models/activity_level.dart';
import '../../models/nutrition_goal.dart';
import '../../models/sex.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// User registration (local mock).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '75');
  final _heightCtrl = TextEditingController(text: '175');
  final _ageCtrl = TextEditingController(text: '25');
  NutritionGoal _goal = NutritionGoal.loseFat;
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final name = _nameCtrl.text.trim().isEmpty ? 'Usuario' : _nameCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 75;
    final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 175;
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 25;

    ref.read(userProvider.notifier).setUser(
          UserProfile(
            name: name,
            weightKg: weight.clamp(35, 220),
            heightCm: height.clamp(120, 220),
            ageYears: age.clamp(12, 90),
            sex: _sex,
            activityLevel: _activity,
            goal: _goal,
          ),
        );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goals = NutritionGoal.values;
    final activities = ActivityLevel.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crea tu perfil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estos datos se guardan solo en memoria (mock).',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Nombre',
                            controller: _nameCtrl,
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Peso (kg)',
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.monitor_weight_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Altura (cm)',
                                  controller: _heightCtrl,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.height,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Edad (años)',
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.cake_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<Sex>(
                                  initialValue: _sex,
                                  items: Sex.values
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _sex = v ?? _sex),
                                  decoration: const InputDecoration(
                                    labelText: 'Sexo',
                                    prefixIcon: Icon(Icons.wc_outlined),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<ActivityLevel>(
                            initialValue: _activity,
                            items: activities
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a.label, overflow: TextOverflow.ellipsis),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _activity = v ?? _activity),
                            decoration: const InputDecoration(
                              labelText: 'Nivel de actividad',
                              prefixIcon: Icon(Icons.fitness_center_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Objetivo fitness',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final g in goals)
                                ChoiceChip(
                                  label: Text(g.label),
                                  selected: _goal == g,
                                  onSelected: (_) => setState(() => _goal = g),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          CustomButton(
                            label: 'Guardar y continuar',
                            icon: Icons.check_circle_outline,
                            isLoading: _loading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Luego podrás editar tu perfil en “Perfil”.',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

