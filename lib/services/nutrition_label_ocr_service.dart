import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Parsed values from a nutrition label image.
class LabelScanResult {
  const LabelScanResult({
    required this.rawText,
    this.suggestedName,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
  });

  final String rawText;
  final String? suggestedName;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
}

/// Local OCR service to extract rough macro values from label photos.
class NutritionLabelOcrService {
  Future<LabelScanResult> scanFromImagePath(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = await recognizer.processImage(input);
      final raw = text.text;
      final fallback = _extractByNutritionTableOrder(raw);

      final protein = _extractMacro(
            raw,
            keywords: [
              'proteina',
              'proteinas',
              'proteína',
              'proteínas',
              'protein',
            ],
            afterKeywordPattern: RegExp(
              r'(?:prote(?:ina|inas)?|protein[a-z]*)[^\n\r\d]{0,24}(\d+(?:[.,]\d+)?)\s*(?:g|gr)?',
            ),
            beforeKeywordPattern: RegExp(
              r'(\d+(?:[.,]\d+)?)\s*(?:g|gr)?[^\n\r]{0,20}(?:prote(?:ina|inas)?|protein[a-z]*)',
            ),
          );

      final carbs = _extractMacro(
            raw,
            keywords: [
              'hidrato',
              'hidratos',
              'carbohidrato',
              'carbohidratos',
              'hidratos de carbono',
              'hid de carbono',
              'carbo',
              'carbs',
            ],
            afterKeywordPattern: RegExp(
              r'(?:hidratos?(?: de carbono)?|carbohidratos?|carbo|carbs?)[^\n\r\d]{0,24}(\d+(?:[.,]\d+)?)\s*(?:g|gr)?',
            ),
            beforeKeywordPattern: RegExp(
              r'(\d+(?:[.,]\d+)?)\s*(?:g|gr)?[^\n\r]{0,20}(?:hidratos?(?: de carbono)?|carbohidratos?|carbo|carbs?)',
            ),
          );

      final fat = _extractMacro(
            raw,
            keywords: [
              'grasa',
              'grasas',
              'lípidos',
              'lipidos',
              'fat',
              'fats',
              'lipid',
            ],
            afterKeywordPattern: RegExp(
              r'(?:grasas?|lipidos?|fats?|fat|lipid[a-z]*)[^\n\r\d]{0,24}(\d+(?:[.,]\d+)?)\s*(?:g|gr)?',
            ),
            beforeKeywordPattern: RegExp(
              r'(\d+(?:[.,]\d+)?)\s*(?:g|gr)?[^\n\r]{0,20}(?:grasas?|lipidos?|fats?|fat|lipid[a-z]*)',
            ),
          );

      final resolvedProtein = _resolveWithFallback(
        primary: protein,
        fallback: fallback.proteinPer100g,
      );
      final resolvedCarbs = _resolveWithFallback(
        primary: carbs,
        fallback: fallback.carbsPer100g,
      );
      final resolvedFat = _resolveWithFallback(
        primary: fat,
        fallback: fallback.fatPer100g,
      );

      return LabelScanResult(
        rawText: raw,
        suggestedName: _extractName(raw),
        proteinPer100g: resolvedProtein,
        carbsPer100g: resolvedCarbs,
        fatPer100g: resolvedFat,
      );
    } finally {
      await recognizer.close();
    }
  }

  String? _extractName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (final line in lines.take(8)) {
      final hasManyDigits = RegExp(r'\d').allMatches(line).length > 3;
      if (!hasManyDigits && line.length >= 3 && line.length <= 40) {
        return line;
      }
    }
    return null;
  }

  double? _extractMacro(
    String text, {
    required List<String> keywords,
    required RegExp afterKeywordPattern,
    required RegExp beforeKeywordPattern,
  }) {
    final normalizedText = _normalize(text);

    // Pass 1: direct regex over full OCR text (best for labels like the sample image).
    final byRegex = _extractByRegex(normalizedText, afterKeywordPattern, beforeKeywordPattern);
    if (byRegex != null) return byRegex.clamp(0.0, 100.0);

    // Pass 2: line-based fallback for split OCR outputs.
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    double? bestValue;
    int bestScore = -1;

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final line = _normalize(rawLine);
      if (!keywords.any((k) => line.contains(_normalize(k)))) continue;

      // OCR often splits labels/tables in two lines (keyword in one line and values in next).
      String joined = rawLine;
      if (i + 1 < lines.length) {
        final next = lines[i + 1];
        final nextNorm = _normalize(next);
        // Avoid false positives like "Proteínas" + "100 g" (table header).
        if (!_isReference100gLine(nextNorm)) {
          joined = '$rawLine $next';
        }
      }
      final candidates = _extractNumericCandidates(joined);
      if (candidates.isEmpty) continue;

      final lineScore = _scoreLine(joined);
      for (final candidate in candidates) {
        final score = lineScore + _scoreValue(candidate);
        if (score > bestScore) {
          bestScore = score;
          bestValue = candidate;
        }
      }
    }

    return bestValue?.clamp(0.0, 100.0);
  }

  double? _extractByRegex(
    String normalizedText,
    RegExp afterKeywordPattern,
    RegExp beforeKeywordPattern,
  ) {
    final candidates = <double>[];

    for (final match in afterKeywordPattern.allMatches(normalizedText)) {
      final raw = match.group(1);
      if (raw == null) continue;
      final v = double.tryParse(raw.replaceAll(',', '.'));
      if (v != null && v <= 120) candidates.add(v);
    }
    for (final match in beforeKeywordPattern.allMatches(normalizedText)) {
      final raw = match.group(1);
      if (raw == null) continue;
      final v = double.tryParse(raw.replaceAll(',', '.'));
      if (v != null && v <= 120) candidates.add(v);
    }

    if (candidates.isEmpty) return null;

    // Prefer plausible macro ranges first, otherwise first candidate.
    candidates.sort((a, b) {
      final sa = _scoreValue(a);
      final sb = _scoreValue(b);
      return sb.compareTo(sa);
    });
    return candidates.first;
  }

  List<double> _extractNumericCandidates(String line) {
    final normalized = _normalize(line);
    final matches = RegExp(r'(\d+(?:[.,]\d+)?)\s*(g|gr)?').allMatches(normalized);
    final values = <double>[];

    for (final m in matches) {
      final raw = m.group(1);
      if (raw == null) continue;
      final value = double.tryParse(raw.replaceAll(',', '.'));
      if (value == null) continue;

      // Ignore obvious non-macro numeric noise.
      if (value > 120) continue;

      // Avoid selecting the reference "100" from "por 100 g".
      final start = m.start;
      final contextStart = (start - 12).clamp(0, normalized.length);
      final context = normalized.substring(contextStart, start);
      if ((value - 100.0).abs() < 0.0001 && context.contains('por')) {
        continue;
      }

      values.add(value);
    }
    return values;
  }

  int _scoreLine(String line) {
    final n = _normalize(line);
    int score = 0;
    if (n.contains('por 100') || n.contains('/100')) score += 2;
    if (n.contains('g')) score += 1;
    return score;
  }

  int _scoreValue(double value) {
    if (value >= 0 && value <= 50) return 3;
    if (value > 50 && value <= 100) return 2;
    return 0;
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  bool _isReference100gLine(String normalizedLine) {
    return RegExp(r'^\s*(por\s*)?100\s*(g|gr)\s*$').hasMatch(normalizedLine);
  }

  double? _resolveWithFallback({
    required double? primary,
    required double? fallback,
  }) {
    if (primary == null) return fallback;
    if (fallback == null) return primary;

    // Main fix for OCR table headers: avoid taking "100 g" as macro value.
    if ((primary - 100.0).abs() < 0.0001 && (fallback - 100.0).abs() > 0.0001) {
      return fallback;
    }

    return primary;
  }

  /// Fallback for OCR outputs where labels and numbers are separated by lines.
  ///
  /// Typical order in EU labels after energy:
  /// fat, saturates, carbs, sugars, fiber, protein, salt.
  LabelScanResult _extractByNutritionTableOrder(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const LabelScanResult(rawText: '');
    }

    int startIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      final n = _normalize(lines[i]);
      if (n.contains('kcal') || n.contains('kj')) {
        startIdx = i;
      }
    }

    // If no explicit energy marker, still attempt with all lines.
    final from = startIdx >= 0 ? startIdx + 1 : 0;
    final values = <double>[];
    for (int i = from; i < lines.length; i++) {
      final n = _normalize(lines[i]);
      // Skip "100 g" reference lines.
      if (RegExp(r'^\s*100\s*(g|gr)\s*$').hasMatch(n)) continue;

      final extracted = _extractNumericCandidates(n);
      if (extracted.isEmpty) continue;
      // Keep first candidate in line (works better for "42 9" OCR noise -> 42).
      final v = extracted.first;
      if (v >= 0 && v <= 100) values.add(v);
    }

    if (values.isEmpty) {
      return const LabelScanResult(rawText: '');
    }

    double? fat;
    double? carbs;
    double? protein;

    if (values.length >= 6) {
      fat = values[0];
      carbs = values[2];
      protein = values[5];
    } else if (values.length >= 3) {
      fat = values[0];
      carbs = values[1];
      protein = values[2];
    }

    return LabelScanResult(
      rawText: '',
      fatPer100g: fat,
      carbsPer100g: carbs,
      proteinPer100g: protein,
    );
  }
}

