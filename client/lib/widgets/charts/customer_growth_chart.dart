import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:erpcrm_client/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// 客户增长图表组件
class CustomerGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const CustomerGrowthChart({
    super.key,
    required this.data,
    this.title = '客户增长',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建折线图数据
  LineChartData _buildLineChartData() {
    // 提取新增和累计数据点
    final newSpots = <FlSpot>[];
    final cumulativeSpots = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      final newCount = (data[i]['newCount'] as int).toDouble();
      final cumulativeCount = (data[i]['cumulativeCount'] as int).toDouble();
      newSpots.add(FlSpot(i.toDouble(), newCount));
      cumulativeSpots.add(FlSpot(i.toDouble(), cumulativeCount));
    }

    // 计算Y轴最大值
    final maxCumulative = cumulativeSpots.isEmpty
        ? 100.0
        : cumulativeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final yInterval = (maxCumulative / 5).ceilToDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: yInterval,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppTheme.borderColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppTheme.borderColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const Text('');
              }

              final date = DateTime.parse(data[index]['date'] as String);
              final dateStr = DateFormat('MM/dd').format(date);

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateStr,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInterval,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxCumulative * 1.2,
      lineBarsData: [
        // 累计客户线
        LineChartBarData(
          spots: cumulativeSpots,
          isCurved: true,
          color: AppTheme.infoColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.infoColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.infoColor.withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= data.length) {
                return null;
              }

              final date = DateTime.parse(data[index]['date'] as String);
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final newCount = data[index]['newCount'] as int;
              final cumulativeCount = data[index]['cumulativeCount'] as int;

              return LineTooltipItem(
                '$dateStr\n新增: $newCount\n累计: $cumulativeCount',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            '暂无数据',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
