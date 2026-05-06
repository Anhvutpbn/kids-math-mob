import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dashboard_models.dart';

class ProgressChart extends StatelessWidget {
  final List<DailyXp> data;
  const ProgressChart({super.key, required this.data});

  Color _barColor(int xp) {
    if (xp >= 100) return AppColors.mastered;
    if (xp >= 50) return AppColors.learning;
    if (xp > 0) return AppColors.beginner;
    return Colors.grey.shade300;
  }

  String _shortDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textLight))),
      );
    }

    final maxXp = data.fold<int>(0, (m, d) => d.xp > m ? d.xp : m);
    final maxY = ((maxXp / 50).ceil() * 50).toDouble().clamp(50.0, double.infinity).toDouble();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_shortDate(data[i].date),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final xp = data[i].xp.toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: xp,
                  color: _barColor(data[i].xp),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toInt()} XP',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
