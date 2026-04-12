import 'package:amls/utils/chart_buckets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Reference-style “Likes” / secondary line.
const Color _chartLogsGreen = Color(0xFF43A047);

/// White card with a dual-line chart: new issues vs new logs per day (last 7 days).
class DashboardWeeklyOverviewCard extends StatelessWidget {
  const DashboardWeeklyOverviewCard({
    super.key,
    required this.issuesByDay,
    required this.logsByDay,
    this.subtitle = 'Last 7 days',
  });

  final List<double> issuesByDay;
  final List<double> logsByDay;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final issuesLineColor = cs.onSurface;
    final labels = weekdayLabelsLast7Days();

    assert(issuesByDay.length == 7 && logsByDay.length == 7);

    final maxVal = [
      ...issuesByDay,
      ...logsByDay,
    ].reduce((a, b) => a > b ? a : b);
    var maxY = maxVal * 1.25;
    if (maxY < 4) maxY = 4;
    if (maxY == 0) maxY = 4;

    final gridInterval = maxY <= 8 ? 2.0 : (maxY / 4).ceilToDouble();

    final issueSpots = List<FlSpot>.generate(
      7,
      (i) => FlSpot(i.toDouble(), issuesByDay[i]),
    );
    final logSpots = List<FlSpot>.generate(
      7,
      (i) => FlSpot(i.toDouble(), logsByDay[i]),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly overview',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendDot(issuesLineColor, 'Issues', cs, tt),
              const SizedBox(width: 16),
              _legendDot(_chartLogsGreen, 'Logs', cs, tt),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: gridInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: cs.outline.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[i],
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: gridInterval,
                      getTitlesWidget: (value, meta) {
                        if (value > maxY + 0.01) return const SizedBox.shrink();
                        if (value < 0) return const SizedBox.shrink();
                        final v = value.round();
                        return Text(
                          '$v',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot s) {
                        final line = s.barIndex == 0 ? 'Issues' : 'Logs';
                        final yStr = s.y == s.y.roundToDouble()
                            ? s.y.toInt().toString()
                            : s.y.toStringAsFixed(1);
                        return LineTooltipItem(
                          '$line: $yStr',
                          TextStyle(
                            color: s.barIndex == 0 ? issuesLineColor : _chartLogsGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: issueSpots,
                    isCurved: true,
                    color: issuesLineColor,
                    barWidth: 2.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, xPct, bar, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: issuesLineColor,
                        strokeWidth: 1.5,
                        strokeColor: cs.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          issuesLineColor.withOpacity(0.12),
                          issuesLineColor.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: logSpots,
                    isCurved: true,
                    color: _chartLogsGreen,
                    barWidth: 2.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, xPct, bar, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: _chartLogsGreen,
                        strokeWidth: 1.5,
                        strokeColor: cs.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _chartLogsGreen.withOpacity(0.1),
                          _chartLogsGreen.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text, ColorScheme cs, TextTheme tt) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: tt.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
