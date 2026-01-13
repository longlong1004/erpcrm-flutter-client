import 'package:flutter/material.dart';
import 'package:erpcrm_client/services/finance_data_service.dart';
import 'package:erpcrm_client/widgets/finance/finance_stat_card.dart';
import 'package:erpcrm_client/widgets/finance/revenue_expense_chart.dart';

/// 财务仪表盘页面
/// 展示财务总览、统计分析、预警信息等
class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _financeMetrics = {};
  List<Map<String, dynamic>> _revenueTrend = [];
  Map<String, dynamic> _receivableWarnings = {};
  Map<String, dynamic> _costProfitAnalysis = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final metrics = await FinanceDataService.getFinanceMetrics();
      final trend = await FinanceDataService.getRevenueTrend(days: 30);
      final warnings = await FinanceDataService.getReceivableWarnings();
      final analysis = await FinanceDataService.getCostProfitAnalysis();

      setState(() {
        _financeMetrics = metrics;
        _revenueTrend = trend;
        _receivableWarnings = warnings;
        _costProfitAnalysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('财务仪表盘'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
            tooltip: '导出报表',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 财务统计卡片
                    _buildFinanceStats(),
                    const SizedBox(height: 24),
                    
                    // 收支趋势图表
                    RevenueExpenseChart(
                      trendData: _revenueTrend,
                      title: '收支趋势（最近30天）',
                    ),
                    const SizedBox(height: 24),
                    
                    // 应收账款预警
                    _buildReceivableWarnings(),
                    const SizedBox(height: 24),
                    
                    // 成本和利润分析
                    _buildCostProfitAnalysis(),
                    const SizedBox(height: 24),
                    
                    // 快速操作
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 构建财务统计卡片
  Widget _buildFinanceStats() {
    final totalReceivable = _financeMetrics['totalReceivable'] ?? 0.0;
    final receivableCount = _financeMetrics['receivableCount'] ?? 0;
    final totalPayable = _financeMetrics['totalPayable'] ?? 0.0;
    final payableCount = _financeMetrics['payableCount'] ?? 0;
    final monthlyIncome = _financeMetrics['monthlyIncome'] ?? 0.0;
    final incomeCount = _financeMetrics['incomeCount'] ?? 0;
    final monthlyExpense = _financeMetrics['monthlyExpense'] ?? 0.0;
    final expenseCount = _financeMetrics['expenseCount'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '财务概览',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            FinanceStatCard(
              title: '应收总额',
              value: '¥${(totalReceivable / 10000).toStringAsFixed(2)}万',
              subtitle: '共 $receivableCount 笔',
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
              onTap: () {
                // TODO: 跳转到应收账款页面
              },
            ),
            FinanceStatCard(
              title: '应付总额',
              value: '¥${(totalPayable / 10000).toStringAsFixed(2)}万',
              subtitle: '共 $payableCount 笔',
              icon: Icons.payment,
              color: Colors.orange,
              onTap: () {
                // TODO: 跳转到应付账款页面
              },
            ),
            FinanceStatCard(
              title: '本月收入',
              value: '¥${(monthlyIncome / 10000).toStringAsFixed(2)}万',
              subtitle: '共 $incomeCount 笔',
              icon: Icons.trending_up,
              color: Colors.green,
              trend: '+12.5%',
              onTap: () {
                // TODO: 跳转到收入明细页面
              },
            ),
            FinanceStatCard(
              title: '本月支出',
              value: '¥${(monthlyExpense / 10000).toStringAsFixed(2)}万',
              subtitle: '共 $expenseCount 笔',
              icon: Icons.trending_down,
              color: Colors.red,
              trend: '+8.3%',
              onTap: () {
                // TODO: 跳转到支出明细页面
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 构建应收账款预警
  Widget _buildReceivableWarnings() {
    final overdueCount = _receivableWarnings['overdueCount'] ?? 0;
    final overdueAmount = _receivableWarnings['overdueAmount'] ?? 0.0;
    final soonDueCount = _receivableWarnings['soonDueCount'] ?? 0;
    final soonDueAmount = _receivableWarnings['soonDueAmount'] ?? 0.0;
    final normalCount = _receivableWarnings['normalCount'] ?? 0;
    final normalAmount = _receivableWarnings['normalAmount'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '应收账款预警',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 跳转到应收账款页面
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWarningCard(
                    '已逾期',
                    overdueCount,
                    overdueAmount,
                    Colors.red,
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWarningCard(
                    '即将逾期（7天内）',
                    soonDueCount,
                    soonDueAmount,
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWarningCard(
                    '正常',
                    normalCount,
                    normalAmount,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(
    String title,
    int count,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count 笔',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¥${(amount / 10000).toStringAsFixed(2)}万',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建成本和利润分析
  Widget _buildCostProfitAnalysis() {
    final byType = _costProfitAnalysis['byType'] as List? ?? [];
    final byProduct = _costProfitAnalysis['byProduct'] as List? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成本和利润分析（本月）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 16),
            
            // 按业务类型
            if (byType.isNotEmpty) ...[
              const Text(
                '按业务类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAnalysisTable(byType, 'type'),
              const SizedBox(height: 24),
            ],
            
            // 按产品
            if (byProduct.isNotEmpty) ...[
              const Text(
                '按产品（Top 10）',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAnalysisTable(byProduct, 'product'),
            ],
            
            if (byType.isEmpty && byProduct.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    '暂无数据',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTable(List<dynamic> data, String keyField) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1),
      },
      children: [
        // 表头
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          children: [
            _buildTableCell(keyField == 'type' ? '业务类型' : '产品名称', isHeader: true),
            _buildTableCell('收入', isHeader: true),
            _buildTableCell('成本', isHeader: true),
            _buildTableCell('利润', isHeader: true),
            _buildTableCell('利润率', isHeader: true),
          ],
        ),
        // 数据行
        ...data.map((item) {
          return TableRow(
            children: [
              _buildTableCell(item[keyField] as String),
              _buildTableCell('¥${(item['revenue'] as double).toStringAsFixed(2)}'),
              _buildTableCell('¥${(item['cost'] as double).toStringAsFixed(2)}'),
              _buildTableCell(
                '¥${(item['profit'] as double).toStringAsFixed(2)}',
                color: (item['profit'] as double) > 0 ? Colors.green : Colors.red,
              ),
              _buildTableCell(
                '${(item['profitMargin'] as double).toStringAsFixed(1)}%',
                color: (item['profitMargin'] as double) > 0 ? Colors.green : Colors.red,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? const Color(0xFF003366) : Colors.black87),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建快速操作
  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  '应收账款',
                  Icons.account_balance_wallet,
                  Colors.blue,
                  () {
                    // TODO: 跳转到应收账款页面
                  },
                ),
                _buildQuickActionButton(
                  '应付账款',
                  Icons.payment,
                  Colors.orange,
                  () {
                    // TODO: 跳转到应付账款页面
                  },
                ),
                _buildQuickActionButton(
                  '进项发票',
                  Icons.receipt,
                  Colors.purple,
                  () {
                    // TODO: 跳转到进项发票页面
                  },
                ),
                _buildQuickActionButton(
                  '销项发票',
                  Icons.receipt_long,
                  Colors.teal,
                  () {
                    // TODO: 跳转到销项发票页面
                  },
                ),
                _buildQuickActionButton(
                  '其它收入',
                  Icons.trending_up,
                  Colors.green,
                  () {
                    // TODO: 跳转到其它收入页面
                  },
                ),
                _buildQuickActionButton(
                  '其它支出',
                  Icons.trending_down,
                  Colors.red,
                  () {
                    // TODO: 跳转到其它支出页面
                  },
                ),
                _buildQuickActionButton(
                  '报销',
                  Icons.request_quote,
                  Colors.indigo,
                  () {
                    // TODO: 跳转到报销页面
                  },
                ),
                _buildQuickActionButton(
                  '导出报表',
                  Icons.file_download,
                  Colors.brown,
                  _exportReport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 导出报表
  Future<void> _exportReport() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出财务报表'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('利润表'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FinanceDataService.exportFinanceReport('利润表');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('资产负债表'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FinanceDataService.exportFinanceReport('资产负债表');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('现金流量表'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FinanceDataService.exportFinanceReport('现金流量表');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
