import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ProcurementContractPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> contractData;

  const ProcurementContractPreviewScreen({super.key, required this.contractData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '采购合同预览',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '采购合同',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003366),
                  ),
            ),
            const SizedBox(height: 32),
            // 合同内容
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 合同标题
                      Center(
                        child: Text(
                          '采购合同',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 合同编号
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('合同编号：'),
                          Text(contractData['contractNumber'] ?? 'HT${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}001'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 签订日期
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('签订日期：'),
                          Text(contractData['signDate'] ?? DateTime.now().toString().split(' ')[0]),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 合同双方
                      const Text('甲方：', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(contractData['company'] ?? '国铁科技有限公司'),
                      const SizedBox(height: 16),
                      const Text('乙方：', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(contractData['supplier'] ?? '供应商名称'),
                      const SizedBox(height: 32),
                      // 采购内容
                      const Text('一、采购内容', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildTable([
                        ['序号', '物资名称', '型号', '数量', '单价', '金额'],
                        ['1', contractData['materialName'] ?? '物资名称', contractData['model'] ?? '型号', contractData['quantity'] ?? '数量', '¥${contractData['unitPrice'] ?? '单价'}', '¥${contractData['amount'] ?? '金额'}'],
                      ]),
                      const SizedBox(height: 32),
                      // 合同条款
                      const Text('二、质量要求', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('1. 乙方提供的产品必须符合国家相关标准和甲方要求。'),
                      const Text('2. 乙方保证产品质量，自交货之日起提供12个月的质量保证期。'),
                      const SizedBox(height: 16),
                      const Text('三、交货时间和地点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('1. 交货时间：合同签订后7个工作日内。'),
                      const Text('2. 交货地点：甲方指定地点。'),
                      const SizedBox(height: 16),
                      const Text('四、付款方式', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('1. 合同签订后，甲方支付30%预付款。'),
                      const Text('2. 货物验收合格后，甲方支付剩余70%货款。'),
                      const SizedBox(height: 16),
                      const Text('五、违约责任', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('1. 乙方未按合同约定时间交货，每逾期一天，需向甲方支付合同总金额的0.5%作为违约金。'),
                      const Text('2. 甲方未按合同约定时间付款，每逾期一天，需向乙方支付合同总金额的0.5%作为违约金。'),
                      const SizedBox(height: 32),
                      // 合同尾部
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('甲方（盖章）：'),
                              const SizedBox(height: 40),
                              Text(contractData['company'] ?? '国铁科技有限公司'),
                              const SizedBox(height: 8),
                              Text(contractData['signDate'] ?? DateTime.now().toString().split(' ')[0]),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('乙方（盖章）：'),
                              const SizedBox(height: 40),
                              Text(contractData['supplier'] ?? '供应商名称'),
                              const SizedBox(height: 8),
                              Text(contractData['signDate'] ?? DateTime.now().toString().split(' ')[0]),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // 打印功能
                    print('打印合同');
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('打印'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // 下载功能
                    print('下载合同');
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('下载'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<List<String>> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: data.map((row) {
        return TableRow(
          decoration: BoxDecoration(
            color: row[0] == '序号' ? Colors.grey.shade200 : Colors.white,
          ),
          children: row.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                cell,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: row[0] == '序号' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
