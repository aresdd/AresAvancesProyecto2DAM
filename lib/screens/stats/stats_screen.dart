import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../models/macros.dart';
import '../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';

/// Stats: calories last 7 days + macro distribution + weekly summary.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last7 = ref.watch(last7DaysCaloriesProvider);
    final macros = ref.watch(weeklyMacroDistributionProvider);
    final now = DateTime.now();

    final totalWeekCalories = last7.fold<double>(0, (s, v) => s + v);
    final avgCalories = totalWeekCalories / (last7.isEmpty ? 1 : last7.length);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _SectionTitle(title: 'Calorías (últimos 7 días)'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: _CaloriesLineChart(
                values: last7,
                labels: List<String>.generate(
                  7,
                  (i) => DateUtilsX.shortDate(now.subtract(Duration(days: 6 - i))),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(title: 'Distribución de macronutrientes (semana)'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: _MacroPieChart(macros: macros),
                ),
                const SizedBox(height: 10),
                _MacroLegend(macros: macros),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(title: 'Resumen semanal'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${totalWeekCalories.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Media diaria: ${avgCalories.toStringAsFixed(0)} kcal',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Text(
                  'Macros (g): P ${macros.proteinG.toStringAsFixed(0)} · '
                  'C ${macros.carbsG.toStringAsFixed(0)} · '
                  'G ${macros.fatG.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _CaloriesLineChart extends StatelessWidget {
  const _CaloriesLineChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = (values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b)) * 1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY.isFinite && maxY > 0 ? maxY : 1,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.energyBlue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.energyBlue.withOpacity(0.12),
            ),
            spots: List<FlSpot>.generate(
              values.length,
              (i) => FlSpot(i.toDouble(), values[i]),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: maxY * 0.5,
            color: scheme.outlineVariant,
            strokeWidth: 1,
            dashArray: [6, 6],
          ),
        ]),
      ),
    );
  }
}

class _MacroPieChart extends StatelessWidget {
  const _MacroPieChart({required this.macros});

  final Macros macros;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pCal = macros.proteinG * 4.0;
    final cCal = macros.carbsG * 4.0;
    final fCal = macros.fatG * 9.0;
    final total = (pCal + cCal + fCal).clamp(1.0, double.infinity);

    return PieChart(
      PieChartData(
        centerSpaceRadius: 52,
        sectionsSpace: 3,
        sections: [
          PieChartSectionData(
            value: pCal,
            title: '${(pCal / total * 100).toStringAsFixed(0)}%',
            radius: 54,
            color: AppColors.healthGreen,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          PieChartSectionData(
            value: cCal,
            title: '${(cCal / total * 100).toStringAsFixed(0)}%',
            radius: 54,
            color: AppColors.energyBlue,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          PieChartSectionData(
            value: fCal,
            title: '${(fCal / total * 100).toStringAsFixed(0)}%',
            radius: 54,
            color: scheme.tertiary,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  const _MacroLegend({required this.macros});

  final Macros macros;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: AppColors.healthGreen, label: 'Proteína', value: '${macros.proteinG.toStringAsFixed(0)}g'),
        _LegendItem(color: AppColors.energyBlue, label: 'Carbo', value: '${macros.carbsG.toStringAsFixed(0)}g'),
        _LegendItem(color: scheme.tertiary, label: 'Grasa', value: '${macros.fatG.toStringAsFixed(0)}g'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value),
        ],
      ),
    );
  }
}

