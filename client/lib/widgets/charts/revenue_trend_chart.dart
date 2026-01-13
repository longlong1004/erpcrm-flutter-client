import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:erpcrm_client/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// 收入趋势图表组件
class RevenueTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const RevenueTrendChart({
    super.key,
    required this.data,
    this.title = '收入趋势',
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
    // 提取收入和支出数据点
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      final income = (data[i]['income'] as num).toDouble();
      final expense = (data[i]['expense'] as num).toDouble();
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
    }

    // 计算Y轴最大值
    final maxIncome = incomeSpots.isEmpty
        ? 100.0
        : incomeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxExpense = expenseSpots.isEmpty
        ? 100.0
        : expenseSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxY = maxIncome > maxExpense ? maxIncome : maxExpense;
    final yInterval = (maxY / 5).ceilToDouble();

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
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              // 格式化金额（万元）
              final valueInWan = value / 10000;
              return Text(
                '${valueInWan.toStringAsFixed(0)}万',
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
      maxY: maxY * 1.2,
      lineBarsData: [
        // 收入线
        LineChartBarData(
          spots: incomeSpots,
          isCurved: true,
          color: AppTheme.successColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.successColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.successColor.withOpacity(0.1),
          ),
        ),
        // 支出线
        LineChartBarData(
          spots: expenseSpots,
          isCurved: true,
          color: AppTheme.errorColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.errorColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: false,
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
              final income = data[index]['income'] as num;
              final expense = data[index]['expense'] as num;

              final isIncomeLine = spot.barIndex == 0;
              final value = isIncomeLine ? income : expense;
              final label = isIncomeLine ? '收入' : '支出';
              final color = isIncomeLine ? AppTheme.successColor : AppTheme.errorColor;

              return LineTooltipItem(
                '$dateStr\n$label: ¥${value.toStringAsFixed(0)}',
                TextStyle(
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
            Icons.trending_up,
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
