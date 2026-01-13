import 'package:flutter/material.dart';
import 'package:erpcrm_client/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// 自定义时间范围选择器
class CustomDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();

  /// 显示日期范围选择对话框
  static Future<void> show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required Function(DateTime startDate, DateTime endDate) onDateRangeSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: CustomDateRangePicker(
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
          onDateRangeSelected: onDateRangeSelected,
        ),
      ),
    );
  }
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = widget.initialStartDate ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEndDate ?? now;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '自定义时间范围',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // 快捷选择按钮
          Wrap(
            spacing: AppTheme.spacingSmall,
            runSpacing: AppTheme.spacingSmall,
            children: [
              _buildQuickSelectButton('今天', _getToday),
              _buildQuickSelectButton('昨天', _getYesterday),
              _buildQuickSelectButton('本周', _getThisWeek),
              _buildQuickSelectButton('上周', _getLastWeek),
              _buildQuickSelectButton('本月', _getThisMonth),
              _buildQuickSelectButton('上月', _getLastMonth),
              _buildQuickSelectButton('本季度', _getThisQuarter),
              _buildQuickSelectButton('本年', _getThisYear),
              _buildQuickSelectButton('最近7天', _getLast7Days),
              _buildQuickSelectButton('最近30天', _getLast30Days),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // 开始日期选择
          _buildDateSelector(
            label: '开始日期',
            date: _startDate,
            onTap: () => _selectStartDate(context),
          ),

          const SizedBox(height: AppTheme.spacingMedium),

          // 结束日期选择
          _buildDateSelector(
            label: '结束日期',
            date: _endDate,
            onTap: () => _selectEndDate(context),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快捷选择按钮
  Widget _buildQuickSelectButton(String label, Function() onPressed) {
    return OutlinedButton(
      onPressed: () {
        onPressed();
        setState(() {});
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
      ),
      child: Text(label),
    );
  }

  /// 构建日期选择器
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: AppTheme.spacingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 选择开始日期
  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  /// 选择结束日期
  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  /// 确认选择
  void _onConfirm() {
    widget.onDateRangeSelected(_startDate, _endDate);
    Navigator.of(context).pop();
  }

  // 快捷选择方法
  void _getToday() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    _endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
  }

  void _getThisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    _startDate = DateTime(monday.year, monday.month, monday.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getLastWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final lastMonday = now.subtract(Duration(days: weekday + 6));
    final lastSunday = lastMonday.add(const Duration(days: 6));
    _startDate = DateTime(lastMonday.year, lastMonday.month, lastMonday.day);
    _endDate = DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 23, 59, 59);
  }

  void _getThisMonth() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    _startDate = lastMonth;
    _endDate = DateTime(lastDayOfLastMonth.year, lastDayOfLastMonth.month, lastDayOfLastMonth.day, 23, 59, 59);
  }

  void _getThisQuarter() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) / 3).floor();
    final firstMonthOfQuarter = quarter * 3 + 1;
    _startDate = DateTime(now.year, firstMonthOfQuarter, 1);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getThisYear() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, 1, 1);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getLast7Days() {
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 6));
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _getLast30Days() {
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 29));
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}
