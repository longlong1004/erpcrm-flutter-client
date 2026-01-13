import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/screens/procurement/procurement_contract_preview_screen.dart';
import 'package:erpcrm_client/screens/procurement/procurement_voucher_screen.dart';
import 'package:erpcrm_client/screens/procurement/procurement_application_screen.dart';
import 'package:erpcrm_client/providers/procurement_application_provider.dart';

class ProcurementScreen extends ConsumerStatefulWidget {
  const ProcurementScreen({super.key});

  @override
  ConsumerState<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends ConsumerState<ProcurementScreen> {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    // 根据当前路径显示不同的内容
    Widget content = _buildDefaultContent(context, currentPath);
    
    if (currentPath == '/procurement/orders') {
      content = _buildProcurementOrdersScreen(context, ref);
    } else if (currentPath == '/procurement/applications') {
      content = _buildProcurementApplicationsScreen(context, ref);
    }

    return MainLayout(
      title: _getPageTitle(currentPath),
      showBackButton: true,
      child: content,
    );
  }
  
  // 获取页面标题
  String _getPageTitle(String path) {
    switch (path) {
      case '/procurement/orders':
        return '采购单';
      case '/procurement/applications':
        return '采购申请';
      default:
        return '采购管理';
    }
  }
  
  // 默认内容
  Widget _buildDefaultContent(BuildContext context, String currentPath) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '采购管理',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: Text(
                '请从左侧菜单选择具体的采购管理功能',
                style: TextStyle(fontSize: 18, color: Color(0xFF616161)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 采购单页面
  Widget _buildProcurementOrdersScreen(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 表格标题
          _buildTableHeader([
            '业务员', '状态', '订单编号', '公司', '供应商', '数量', '金额', '备注', '创建时间', '付款凭证', '操作'
          ]),
          const SizedBox(height: 16),
          // 表格内容
          Expanded(
            child: _buildTableContent(
              context,
              ref,
              [
                {'业务员': '张三', '状态': '已完成', '订单编号': 'PO001', '公司': '国铁科技有限公司', '供应商': '供应商A', '数量': 10, '金额': 1000.00, '备注': '采购设备', '创建时间': '2025-12-19', '付款凭证': '已上传'},
                {'业务员': '李四', '状态': '待审核', '订单编号': 'PO002', '公司': '国铁科技有限公司', '供应商': '供应商B', '数量': 20, '金额': 2000.00, '备注': '采购材料', '创建时间': '2025-12-18', '付款凭证': '未上传'},
                {'业务员': '王五', '状态': '已审核', '订单编号': 'PO003', '公司': '国铁科技有限公司', '供应商': '供应商C', '数量': 15, '金额': 1500.00, '备注': '采购办公用品', '创建时间': '2025-12-17', '付款凭证': '未上传'},
              ],
              true, // 采购单页面
            ),
          ),
        ],
      ),
    );
  }
  
  // 采购申请页面
  Widget _buildProcurementApplicationsScreen(BuildContext context, WidgetRef ref) {
    // 从状态管理获取采购申请数据
    final applications = ref.watch(procurementApplicationProvider);
    
    // 将采购申请数据转换为表格所需的格式
    final tableData = applications.map((app) => {
      'id': app.id,
      '业务员': app.salesman,
      '状态': app.status,
      '公司': app.company,
      '采购物资名称': app.materialName,
      '型号': app.model,
      '数量': app.quantity,
      '单价': app.unitPrice,
      '单位': app.unit,
      '金额': app.amount,
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 新增功能
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProcurementApplicationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('新增'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 16),
          // 表格标题
          _buildTableHeader([
            '业务员', '状态', '公司', '采购物资名称', '型号', '数量', '单价', '单位', '金额', '操作'
          ]),
          const SizedBox(height: 16),
          // 表格内容
          Expanded(
            child: _buildTableContent(
              context,
              ref,
              tableData,
              false, // 采购申请页面
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTableHeader(List<String> headers) {
    return Row(
      children: headers.map((header) {
        // 为操作列设置特殊宽度
        final width = header == '操作' ? 200.0 : 120.0;
        return Expanded(
          flex: header == '操作' ? 3 : 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF003366),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              header,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableCell(dynamic content, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          content.toString(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTableContent(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> data, bool isPurchaseOrder) {
    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // 渲染表格数据
              ...(isPurchaseOrder ? [
                // 采购单表头：业务员，状态，订单编号，公司，供应商，数量，金额，备注，创建时间，付款凭证，操作
                _buildTableCell(item['业务员'], 2),
                _buildTableCell(item['状态'], 2),
                _buildTableCell(item['订单编号'], 2),
                _buildTableCell(item['公司'], 2),
                _buildTableCell(item['供应商'], 2),
                _buildTableCell(item['数量'], 2),
                _buildTableCell('¥${item['金额']}', 2),
                _buildTableCell(item['备注'], 2),
                _buildTableCell(item['创建时间'], 2),
                _buildTableCell(item['付款凭证'], 2),
              ] : [
                // 采购申请表头：业务员，状态，公司，采购物资名称，型号，数量，单价，单位，金额，操作
                _buildTableCell(item['业务员'], 2),
                _buildTableCell(item['状态'], 2),
                _buildTableCell(item['公司'], 2),
                _buildTableCell(item['采购物资名称'], 2),
                _buildTableCell(item['型号'], 2),
                _buildTableCell(item['数量'], 2),
                _buildTableCell('¥${item['单价']}', 2),
                _buildTableCell(item['单位'], 2),
                _buildTableCell('¥${item['金额']}', 2),
              ]),

              // 操作按钮
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isPurchaseOrder) ...[
                        // 采购单操作按钮
                        TextButton(
                          onPressed: () {
                            // 生成合同功能
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProcurementContractPreviewScreen(
                                  contractData: {
                                    'materialName': '压力传感器',
                                    'model': 'PT100',
                                    'quantity': item['数量'].toString(),
                                    'unitPrice': (item['金额'] / item['数量']).toStringAsFixed(2),
                                    'amount': item['金额'].toString(),
                                    'company': item['公司'],
                                    'supplier': item['供应商'],
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text('生成合同'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 查看付款凭证功能
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProcurementVoucherScreen(
                                  voucherUrl: 'https://via.placeholder.com/800x600.png?text=付款凭证',
                                  orderNumber: item['订单编号'],
                                ),
                              ),
                            );
                          },
                          child: const Text('查看'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // 上传凭证功能 - 跨平台实现
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                            );
                             
                            if (result != null && result.files.isNotEmpty) {
                              final file = result.files.first;
                              print('选择的文件: ${file.name}');
                              
                              // 上传文件逻辑（模拟）
                              print('上传文件至服务器');
                              
                              // 显示成功消息
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('凭证上传成功，状态变更为待财务付款'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text('上传凭证'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 撤回功能
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('撤回确认'),
                                content: const Text('确定要撤回该采购单吗？撤回后状态将变为待提交审核。'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 执行撤回逻辑
                                      print('撤回采购单: ${item['订单编号']}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('采购单已撤回，状态变更为待提交审核'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('撤回'),
                        ),
                      ] else ...[
                        // 采购申请操作按钮
                        TextButton(
                          onPressed: () {
                            // 查看采购申请详情
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('查看采购申请详情：${item['采购物资名称']}'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                            // 这里可以导航到详情页面，当前先显示提示
                          },
                          child: const Text('查看'),
                        ),
                        TextButton(
                          onPressed: item['状态'] == '待审批' ? () {
                            // 编辑功能，仅在状态为待审核时可用
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('编辑采购申请：${item['采购物资名称']}'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          } : null,
                          child: const Text('编辑'),
                          style: TextButton.styleFrom(
                            disabledForegroundColor: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: (item['状态'] != '已批准' && item['状态'] != '已拒绝') ? () {
                            // 撤回功能，仅在审批流程未完成前有效
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('撤回确认'),
                                content: const Text('确定要撤回该采购申请吗？撤回后状态将变为已撤回。'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 执行撤回逻辑
                                      final applicationId = item['id'] as int;
                                      ref.read(procurementApplicationProvider.notifier).withdrawApplication(applicationId);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('采购申请已撤回，状态变更为已撤回'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          } : null,
                          child: const Text('撤回'),
                          style: TextButton.styleFrom(
                            disabledForegroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}