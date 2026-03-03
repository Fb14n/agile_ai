import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Line chart: sentiment score over time.
class SentimentChartWidget extends StatelessWidget {
  /// Each entry: {'date': DateTime, 'score': double, 'ceremony': String}
  final List<Map<String, dynamic>> data;

  const SentimentChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Noch keine Sentiment-Daten'));
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value['score'] as double);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                final date = data[idx]['date'] as DateTime;
                return Text(
                  '${date.day}.${date.month}',
                  style: const TextStyle(fontSize: 9),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: _scoreColor(spot.y),
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt();
              final ceremony = idx < data.length ? data[idx]['ceremony'] as String : '';
              return LineTooltipItem(
                '${s.y.toStringAsFixed(1)}\n$ceremony',
                const TextStyle(fontSize: 11, color: Colors.white),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 7) return Colors.green;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}

/// Bar chart: sprint velocity.
class VelocityChartWidget extends StatelessWidget {
  /// Each entry: {'sprint': int, 'velocity': int, 'planned': int?}
  final List<Map<String, dynamic>> data;

  const VelocityChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Noch keine Velocity-Daten'));
    }

    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data
                .map((d) => (d['planned'] as int? ?? d['velocity'] as int).toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.3,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Text('S${data[idx]['sprint']}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((e) {
          final idx = e.key;
          final d = e.value;
          final vel = (d['velocity'] as int).toDouble();
          final planned = (d['planned'] as int?)?.toDouble();
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(toY: vel, color: primary, width: 14, borderRadius: BorderRadius.circular(4)),
              if (planned != null)
                BarChartRodData(toY: planned, color: secondary.withValues(alpha: 0.5), width: 14, borderRadius: BorderRadius.circular(4)),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, rodIdx) {
              final sprint = data[group.x]['sprint'] as int;
              final label = rodIdx == 0 ? 'Velocity' : 'Geplant';
              return BarTooltipItem(
                'Sprint $sprint\n$label: ${rod.toY.toInt()}',
                const TextStyle(fontSize: 11, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
