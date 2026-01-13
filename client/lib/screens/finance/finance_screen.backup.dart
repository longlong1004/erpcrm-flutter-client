import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/screens/finance/receivable_detail_screen.dart';
import 'package:erpcrm_client/screens/finance/receivable_collect_screen.dart';
import 'package:erpcrm_client/screens/finance/payable_detail_screen.dart';
import 'package:erpcrm_client/screens/finance/payable_pay_screen.dart';
import 'package:erpcrm_client/screens/finance/payable_application_screen.dart';
import 'package:erpcrm_client/screens/finance/invoice_detail_screen.dart';
import 'package:erpcrm_client/screens/finance/invoice_upload_screen.dart';
import 'package:erpcrm_client/screens/finance/invoice_input_screen.dart';
import 'package:erpcrm_client/screens/finance/other_income_form_screen.dart';
import 'package:erpcrm_client/screens/finance/reimbursement_screen.dart';
import 'package:erpcrm_client/screens/finance/other_expense_modal.dart';
import 'package:erpcrm_client/providers/finance_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    // 根据当前路径确定页面配置
    String pageTitle;
    List<String> tableHeaders;
    List<String> actionButtons;
    FinanceDataType? dataType;
    bool showAddButton = false;
    String addButtonText = '新增';

    // 应收相关页面
    if (currentPath == '/finance/receivable/mall') {
      pageTitle = '商城应收';
      tableHeaders = ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'];
      actionButtons = ['查看', '收款'];
      dataType = FinanceDataType.receivableMall;
    } else if (currentPath == '/finance/receivable/collector') {
      pageTitle = '集货商应收';
      tableHeaders = ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'];
      actionButtons = ['查看', '收款'];
      dataType = FinanceDataType.receivableCollector;
    } else if (currentPath == '/finance/receivable/other') {
      pageTitle = '其它业务应收';
      tableHeaders = ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'];
      actionButtons = ['查看', '收款'];
      dataType = FinanceDataType.receivableOther;
    } 
    // 对外业务应收
    else if (currentPath == '/finance/receivable/external') {
      pageTitle = '对外业务应收';
      tableHeaders = ['业务员', '状态', '客户公司名称', '联系人', '联系电话', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'];
      actionButtons = ['查看', '收款'];
      dataType = FinanceDataType.receivableExternal;
    }
    // 应付页面
    else if (currentPath == '/finance/payable') {
      pageTitle = '应付';
      tableHeaders = ['业务员', '订单编号', '状态', '类型', '付款方', '付款方式', '收款方', '联系人', '单据类型', '应付欠款', '欠款类型', '采购凭证', '国铁凭证', '付款日期', '操作'];
      actionButtons = ['查看', '付款', '付款申请单', '驳回'];
      dataType = FinanceDataType.payable;
    }
    // 进项发票
    else if (currentPath == '/finance/invoice/incoming') {
      pageTitle = '进项发票';
      tableHeaders = ['业务员', '状态', '类型', '订单编号', '供应商', '付款金额', '付款日期', '发票号', '发票金额', '开票日期', '操作'];
      actionButtons = ['查看', '上传', '录入'];
      dataType = FinanceDataType.invoiceIncoming;
    }
    // 销项发票
    else if (currentPath == '/finance/invoice/outgoing') {
      pageTitle = '销项发票';
      tableHeaders = ['录入时间', '公司名称', '申请单号', '申请时间', '账单编号', '发票类型', '发票抬头', '纳税人识别码', '开户银行', '银行账户', '注册地址', '注册电话', '收票人姓名', '收票人地址', '收票人电话', '明细', '总金额', '备注', '结果', '发票状态', '开票状态', '操作'];
      actionButtons = ['修改', '编辑', '开票'];
      dataType = FinanceDataType.invoiceOutgoing;
    }
    // 其它收入
    else if (currentPath == '/finance/income/other') {
      pageTitle = '其它收入';
      tableHeaders = ['业务员', '编号', '付款单位', '收款单位', '收入类型', '收款金额', '备注', '操作'];
      actionButtons = ['查看', '编辑', '删除'];
      showAddButton = true;
      dataType = FinanceDataType.incomeOther;
    }
    // 其他支出
    else if (currentPath == '/finance/expense/other') {
      pageTitle = '其他支出';
      tableHeaders = ['业务员', '编号', '付款单位', '收款单位', '支出类型', '支出金额', '备注', '操作'];
      actionButtons = ['查看', '编辑', '删除'];
      showAddButton = true;
      dataType = FinanceDataType.expenseOther;
    }
    // 报销
    else if (currentPath == '/finance/reimbursement') {
      pageTitle = '报销';
      tableHeaders = ['业务员', '状态', '报销类型', '关联单号', '公司名称', '报销金额', '报销凭证', '备注', '操作'];
      actionButtons = ['查看', '编辑', '撤回', '上传', '删除'];
      showAddButton = true;
      addButtonText = '报销';
      dataType = FinanceDataType.reimbursement;
    }
    // 默认情况
    else {
      pageTitle = '财务管理';
      tableHeaders = ['业务类型', '订单编号', '金额', '状态', '创建时间', '操作'];
      actionButtons = ['查看', '收款', '付款', '上传发票', '录入发票'];
      dataType = null;
    }

    // 获取财务状态管理
    final financeState = ref.watch(financeNotifierProvider);
    final financeNotifier = ref.read(financeNotifierProvider.notifier);

    // 如果有数据类型，获取对应的数据
    final currentData = dataType != null ? financeState.data[dataType] ?? [] : [];
    final isLoading = dataType != null ? financeState.isLoading[dataType] ?? false : false;
    final error = dataType != null ? financeState.error[dataType] : null;

    // 如果数据为空且不是加载中，尝试获取数据
    if (currentData.isEmpty && !isLoading && dataType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        financeNotifier.fetchFinanceData(dataType!);
      });
    }

    // 构建主要内容
    Widget content = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // 页面标题和新增按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pageTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                if (showAddButton)
                      ElevatedButton(
                        onPressed: () {
                          // 新增/报销按钮点击事件
                          if (currentPath == '/finance/income/other') {
                            // 新增其他收入
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OtherIncomeFormScreen(),
                              ),
                            );
                          } else if (currentPath == '/finance/reimbursement') {
                            // 新增报销
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReimbursementFormScreen(),
                              ),
                            );
                          } else if (currentPath == '/finance/expense/other') {
                            // 新增其他支出 - 弹出模态窗口
                            showDialog(
                              context: context,
                              builder: (context) => const OtherExpenseModal(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(addButtonText),
                      ),
              ],
            ),
            const SizedBox(height: 32),
            // 表格容器
            Expanded(
              child: Container(
                width: double.infinity,
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
                  children: [
                    // 表格标题
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: tableHeaders.map((header) => Expanded(
                          flex: header == '操作' ? 3 : 2,
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F1F1F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )).toList(),
                      ),
                    ),
                    // 表格内容
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                              ? Center(child: Text('加载失败: $error'))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 300, // 调整宽度以适应内容
                                    child: ListView.builder(
                                      itemCount: currentData.length,
                                      itemBuilder: (context, index) {
                                        final item = currentData[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: const Color(0xFFE0E0E0)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // 动态生成表格单元格
                                              ...tableHeaders.where((header) => header != '操作').map((header) => Expanded(
                                                flex: header == '操作' ? 3 : 2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Text(
                                                    (header == '应收金额' || header == '国铁单价' || header == '总金额' || 
                                                     header == '收款金额' || header == '支出金额' || header == '报销金额') 
                                                      ? '¥${item[header] ?? 0.0}'
                                                      : (item[header] ?? '').toString(),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              )),
                                              // 操作按钮
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Wrap(
                                                    spacing: 8.0,
                                                    runSpacing: 8.0,
                                                    alignment: WrapAlignment.center,
                                                    children: actionButtons.map((button) => ElevatedButton(
                                                      onPressed: () {
                                                        // 处理按钮点击事件
                                                        if (button == '查看') {
                                                          if (currentPath == '/finance/payable') {
                                                            // 应付查看
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => PayableDetailScreen(payableData: item),
                                                              ),
                                                            );
                                                          } else if (currentPath.contains('/invoice/')) {
                                                            // 发票查看
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => InvoiceDetailScreen(
                                                                  invoiceData: item,
                                                                  isIncomingInvoice: currentPath.contains('/invoice/incoming'),
                                                                ),
                                                              ),
                                                            );
                                                          } else if (currentPath == '/finance/reimbursement') {
                                                            // 报销查看
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ReimbursementFormScreen(reimbursementData: item),
                                                              ),
                                                            );
                                                          } else if (currentPath == '/finance/income/other') {
                                                            // 其他收入查看
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => OtherIncomeFormScreen(incomeData: item),
                                                              ),
                                                            );
                                                          } else if (currentPath == '/finance/expense/other') {
                                                            // 其他支出查看 - 弹出模态窗口
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => OtherExpenseModal(
                                                                expenseData: item,
                                                                isViewMode: true,
                                                              ),
                                                            );
                                                          } else {
                                                            // 应收查看
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ReceivableDetailScreen(receivableData: item),
                                                              ),
                                                            );
                                                          }
                                                        } else if (button == '收款') {
                                                          // 收款
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ReceivableCollectScreen(receivableData: item),
                                                            ),
                                                          );
                                                        } else if (button == '付款') {
                                                          // 付款
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => PayablePayScreen(payableData: item),
                                                            ),
                                                          );
                                                        } else if (button == '付款申请单') {
                                                          // 付款申请单
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => PayableApplicationScreen(payableData: item),
                                                            ),
                                                          );
                                                        } else if (button == '上传') {
                                                          // 上传发票
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => InvoiceUploadScreen(invoiceData: item),
                                                            ),
                                                          );
                                                        } else if (button == '录入') {
                                                          // 录入发票
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => const InvoiceInputScreen(),
                                                            ),
                                                          );
                                                        } else if (button == '编辑') {
                                                          if (currentPath == '/finance/income/other') {
                                                            // 编辑其他收入
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => OtherIncomeFormScreen(incomeData: item),
                                                              ),
                                                            );
                                                          } else if (currentPath == '/finance/invoice/outgoing') {
                                                            // 编辑销项发票
                                                            print('编辑销项发票: ${item['发票号']}');
                                                          } else if (currentPath == '/finance/reimbursement') {
                                                            // 编辑报销
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ReimbursementFormScreen(reimbursementData: item),
                                                              ),
                                                            );
                                                          } else if (currentPath == '/finance/expense/other') {
                                                            // 编辑其他支出 - 弹出模态窗口
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => OtherExpenseModal(
                                                                expenseData: item,
                                                              ),
                                                            );
                                                          }
                                                        } else if (button == '开票') {
                                                          // 开票
                                                          print('开票: ${item['申请单号']}');
                                                          // 显示成功消息
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: const Text('已接入第三方开票平台，开始生成电子发票'),
                                                              backgroundColor: Colors.green,
                                                            ),
                                                          );
                                                        } else if (button == '撤回') {
                                                          // 撤回
                                                          print('撤回: ${item['关联单号']}');
                                                          // 显示成功消息
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: const Text('撤回成功，状态已更新'),
                                                              backgroundColor: Colors.green,
                                                            ),
                                                          );
                                                        } else if (button == '删除') {
                                                          // 删除
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text('删除确认'),
                                                              content: const Text('确定要删除此记录吗？此操作不可撤销。'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: const Text('取消'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    if (dataType != null && item.containsKey('id')) {
                                                                      try {
                                                                        // 执行删除
                                                                        await financeNotifier.deleteFinanceData(dataType!, item['id']);
                                                                        Navigator.pop(context);
                                                                         
                                                                        // 显示成功消息
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: const Text('删除成功'),
                                                                            backgroundColor: Colors.green,
                                                                            duration: const Duration(seconds: 2),
                                                                          ),
                                                                        );
                                                                      } catch (e) {
                                                                        Navigator.pop(context);
                                                                        // 显示错误消息
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text('删除失败: $e'),
                                                                            backgroundColor: Colors.red,
                                                                            duration: const Duration(seconds: 2),
                                                                          ),
                                                                        );
                                                                      }
                                                                    } else {
                                                                      Navigator.pop(context);
                                                                      // 显示错误消息
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          content: const Text('删除失败: 数据无效'),
                                                                          backgroundColor: Colors.red,
                                                                          duration: const Duration(seconds: 2),
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  child: const Text('确定'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: button == '查看' ? const Color(0xFF003366) :
                                                                     button == '收款' || button == '付款' ? const Color(0xFF107C10) :
                                                                     button == '修改' || button == '编辑' ? const Color(0xFF003366) :
                                                                     button == '上传' || button == '录入' ? const Color(0xFF003366) :
                                                                     button == '开票' ? const Color(0xFF003366) :
                                                                     button == '撤回' ? const Color(0xFFFFA000) :
                                                                     button == '删除' ? const Color(0xFFD32F2F) :
                                                                     button == '付款申请单' ? const Color(0xFF003366) :
                                                                     const Color(0xFF003366),
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        textStyle: const TextStyle(fontSize: 12),
                                                      ),
                                                      child: Text(button),
                                                    )).toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                    ),
                    // 如果没有数据，显示提示信息
                    if (currentData.isEmpty && !isLoading) 
                      Expanded(
                        child: Center(
                          child: Text(
                            '暂无数据',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );

    // 使用MainLayout包裹内容
    return MainLayout(
      title: pageTitle,
      showBackButton: true,
      child: content,
    );
  }
}