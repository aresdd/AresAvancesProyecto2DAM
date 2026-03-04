import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/providers.dart';
import '../../providers/custom_foods_provider.dart';
import '../../services/nutrition_label_ocr_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen to create a custom food (macros per 100g). Used when the food isn't in the list.
class CreateFoodScreen extends ConsumerStatefulWidget {
  const CreateFoodScreen({super.key});

  @override
  ConsumerState<CreateFoodScreen> createState() => _CreateFoodScreenState();
}

class _CreateFoodScreenState extends ConsumerState<CreateFoodScreen> {
  final _nameCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController(text: '0');
  final _carbsCtrl = TextEditingController(text: '0');
  final _fatCtrl = TextEditingController(text: '0');
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;
  bool _scanning = false;
  XFile? _labelPhoto;
  String? _ocrPreview;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  double _parse(String s) => (double.tryParse(s.replaceAll(',', '.')) ?? 0).clamp(0, 100);

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2200,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _labelPhoto = picked;
      _ocrPreview = null;
    });
  }

  Future<void> _scanLabel() async {
    final photo = _labelPhoto;
    if (photo == null) return;

    setState(() => _scanning = true);
    try {
      final service = ref.read(nutritionLabelOcrServiceProvider);
      final LabelScanResult result = await service.scanFromImagePath(photo.path);

      if (result.suggestedName != null && _nameCtrl.text.trim().isEmpty) {
        _nameCtrl.text = result.suggestedName!;
      }
      if (result.proteinPer100g != null) {
        _proteinCtrl.text = result.proteinPer100g!.toStringAsFixed(1);
      }
      if (result.carbsPer100g != null) {
        _carbsCtrl.text = result.carbsPer100g!.toStringAsFixed(1);
      }
      if (result.fatPer100g != null) {
        _fatCtrl.text = result.fatPer100g!.toStringAsFixed(1);
      }

      setState(() {
        _ocrPreview = result.rawText.trim().isEmpty ? null : result.rawText.trim();
      });

      final hasAnyMacro = result.proteinPer100g != null ||
          result.carbsPer100g != null ||
          result.fatPer100g != null;
      if (!hasAnyMacro && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectaron macros automáticamente. Ajusta foto o rellena manualmente.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo analizar la etiqueta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final food = ref.read(customFoodsProvider.notifier).addFood(
          name: name,
          proteinPer100g: _parse(_proteinCtrl.text),
          carbsPer100g: _parse(_carbsCtrl.text),
          fatPer100g: _parse(_fatCtrl.text),
          labelImagePath: _labelPhoto?.path,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = _parse(_proteinCtrl.text);
    final c = _parse(_carbsCtrl.text);
    final f = _parse(_fatCtrl.text);
    final kcal = (p * 4) + (c * 4) + (f * 9);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear alimento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Valores por 100 g',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Introduce los macronutrientes del alimento por cada 100 gramos.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Foto etiqueta',
                            icon: Icons.camera_alt_outlined,
                            variant: CustomButtonVariant.tonal,
                            onPressed: () => _pickPhoto(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: 'Galería',
                            icon: Icons.photo_library_outlined,
                            variant: CustomButtonVariant.tonal,
                            onPressed: () => _pickPhoto(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    if (_labelPhoto != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FutureBuilder<Uint8List>(
                          future: _labelPhoto!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return const SizedBox(
                                height: 120,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (!snapshot.hasData) {
                              return Container(
                                height: 120,
                                color: scheme.surfaceContainerLow,
                                alignment: Alignment.center,
                                child: const Text('Vista previa no disponible'),
                              );
                            }
                            return Image.memory(
                              snapshot.data!,
                              height: 180,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        label: 'Analizar etiqueta (OCR)',
                        icon: Icons.document_scanner_outlined,
                        isLoading: _scanning,
                        onPressed: _scanLabel,
                      ),
                    ],
                    if (_ocrPreview != null) ...[
                      const SizedBox(height: 10),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Texto detectado'),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Text(
                              _ocrPreview!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Nombre del alimento',
                      controller: _nameCtrl,
                      prefixIcon: Icons.restaurant_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Proteína (g)',
                            controller: _proteinCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Carbos (g)',
                            controller: _carbsCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Grasa (g)',
                            controller: _fatCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kcal / 100 g',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          Text(
                            kcal.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(
              label: 'Guardar alimento',
              icon: Icons.check,
              isLoading: _saving,
              onPressed: _nameCtrl.text.trim().isEmpty ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
