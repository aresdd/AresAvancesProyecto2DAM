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

/// Edit profile data (local in-memory).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  NutritionGoal _goal = NutritionGoal.loseFat;
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _initFrom(UserProfile user) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = user.name;
    _weightCtrl.text = user.weightKg.toStringAsFixed(1);
    _heightCtrl.text = user.heightCm.toStringAsFixed(0);
    _ageCtrl.text = user.ageYears.toString();
    _goal = user.goal;
    _sex = user.sex;
    _activity = user.activityLevel;
  }

  Future<void> _save(UserProfile current) async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final name = _nameCtrl.text.trim().isEmpty ? current.name : _nameCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? current.weightKg;
    final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? current.heightCm;
    final age = int.tryParse(_ageCtrl.text.trim()) ?? current.ageYears;

    ref.read(userProvider.notifier).update(
          current.copyWith(
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
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      // If someone lands here without user, redirect to register.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.register);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _initFrom(user);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
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
                        items: ActivityLevel.values
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(a.label, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _activity = v ?? _activity),
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
                          for (final g in NutritionGoal.values)
                            ChoiceChip(
                              label: Text(g.label),
                              selected: _goal == g,
                              onSelected: (_) => setState(() => _goal = g),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: 'Guardar cambios',
                        icon: Icons.save_outlined,
                        isLoading: _saving,
                        onPressed: () => _save(user),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

