import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/models/process/process_models.dart';
import 'package:erpcrm_client/models/auth/employee.dart';
import 'package:erpcrm_client/widgets/employee_selector.dart';

// 流程设计向导页面
class ProcessWizardScreen extends ConsumerStatefulWidget {
  const ProcessWizardScreen({super.key});

  @override
  ConsumerState<ProcessWizardScreen> createState() => _ProcessWizardScreenState();
}

class _ProcessWizardScreenState extends ConsumerState<ProcessWizardScreen> {
  // 向导步骤
  int _currentStep = 0;
  // 流程名称控制器
  final TextEditingController _processNameController = TextEditingController();
  // 流程描述控制器
  final TextEditingController _processDescriptionController = TextEditingController();
  // 选中的路径
  List<String> _selectedPath = [];
  // 关联页面路由
  String _selectedPageRoute = '';
  // 关联页面名称
  String _selectedPageName = '';
  // 流程状态
  ProcessWizardState _wizardState = ProcessWizardState();

  // 导航栏层级数据
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'name': '订单管理',
      'children': [
        {
          'name': '国铁订单',
          'children': [
            {
              'name': '商城订单',
              'route': '/orders/mall/total',
            },
            {
              'name': '集货商订单',
              'route': '/orders/collector/total',
            },
            {
              'name': '其它订单',
              'route': '/orders/other/total',
            },
            {
              'name': '补发货（退换货）',
              'route': '/orders/replenishment',
            },
          ],
        },
        {
          'name': '对外业务订单',
          'route': '/orders/external',
        },
      ],
    },
    {
      'name': '业务管理',
      'children': [
        {
          'name': '国铁信息专区',
          'children': [
            {
              'name': '批量采购',
              'route': '/businesses/batch-purchase/participable',
            },
            {
              'name': '招标信息',
              'route': '/businesses/bidding',
            },
            {
              'name': '竞价信息',
              'route': '/businesses/auction',
            },
          ],
        },
        {
          'name': '先发货管理',
          'route': '/businesses/pre-delivery',
        },
      ],
    },
    {
      'name': '商品管理',
      'children': [
        {
          'name': '申请上架',
          'route': '/products/apply',
        },
        {
          'name': '已上架',
          'route': '/products/approved',
        },
        {
          'name': '回收站',
          'route': '/products/recycle',
        },
      ],
    },
    {
      'name': '采购管理',
      'children': [
        {
          'name': '采购单',
          'route': '/procurement/orders',
        },
        {
          'name': '采购申请',
          'route': '/procurement/applications',
        },
      ],
    },
    {
      'name': '审批管理',
      'children': [
        {
          'name': '待审核',
          'route': '/approval/pending',
        },
        {
          'name': '已审核',
          'route': '/approval/approved',
        },
      ],
    },
  ];

  // 当前选中的层级项
  List<Map<String, dynamic>> _currentLevelItems = [];

  @override
  void initState() {
    super.initState();
    // 初始化当前层级项为第一级导航项
    _currentLevelItems = _navigationItems;
  }

  @override
  void dispose() {
    _processNameController.dispose();
    _processDescriptionController.dispose();
    super.dispose();
  }

  // 处理下一步
  void _handleNext() {
    if (_currentStep == 0) {
      // 验证流程名称
      if (_processNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入流程名称')),
        );
        return;
      }
      // 更新向导状态
      _wizardState = _wizardState.copyWith(
        processName: _processNameController.text.trim(),
        processDescription: _processDescriptionController.text.trim(),
      );
    } else if (_currentStep == 1) {
      // 验证是否选择了页面
      if (_selectedPageRoute.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择关联页面')),
        );
        return;
      }
      // 更新向导状态
      _wizardState = _wizardState.copyWith(
        selectedPageRoute: _selectedPageRoute,
        selectedPageName: _selectedPageName,
        selectedPath: _selectedPath,
      );
    }

    setState(() {
      _currentStep++;
    });
  }

  // 处理上一步
  void _handleBack() {
    setState(() {
      _currentStep--;
    });
  }

  // 处理层级选择
  void _handleLevelSelect(Map<String, dynamic> item) {
    setState(() {
      if (item.containsKey('children')) {
        // 有子项，进入下一级
        _selectedPath.add(item['name']);
        _currentLevelItems = item['children'] as List<Map<String, dynamic>>;
        // 显示审核人配置提示
        _showApproverConfigHint(item['name']);
      } else {
        // 无子项，选择该页面
        _selectedPath.add(item['name']);
        _selectedPageRoute = item['route'] as String;
        _selectedPageName = item['name'];
        // 显示审核人配置提示
        _showApproverConfigHint(item['name']);
      }
    });
  }

  // 处理返回上一级
  void _handleBackToParent() {
    setState(() {
      if (_selectedPath.isNotEmpty) {
        _selectedPath.removeLast();
        // 重新构建当前层级
        if (_selectedPath.isEmpty) {
          // 返回第一级
          _currentLevelItems = _navigationItems;
        } else {
          // 找到当前层级的父级
          var parentItems = _navigationItems;
          Map<String, dynamic>? currentItem;
          for (var pathName in _selectedPath) {
            currentItem = parentItems.firstWhere((item) => item['name'] == pathName);
            if (currentItem.containsKey('children')) {
              parentItems = currentItem['children'] as List<Map<String, dynamic>>;
            } else {
              break;
            }
          }
          _currentLevelItems = parentItems;
        }
      }
    });
  }

  // 显示审核人配置提示
  void _showApproverConfigHint(String itemName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('审核人配置提示'),
          content: Text(
            '选择了 [$itemName]，您需要在流程设计中为该节点配置以下审批规则：\n\n' 
            '1. 单人审批：指定单个审批负责人\n' 
            '2. 会签（AND）：需所有指定审批人同意方可通过\n' 
            '3. 或签（OR）：任意一名指定审批人同意即可通过\n' 
            '4. 依次审批：节点内按预设顺序依次流转审批\n',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
  }

  // 完成向导
  void _handleComplete() {
    // 跳转到流程设计器页面
    GoRouter.of(context).go(
      '/settings/process-design/create',
      extra: {
        'processName': _wizardState.processName,
        'processDescription': _wizardState.processDescription,
        'associatedPageRoute': _wizardState.selectedPageRoute,
        'associatedPageName': _wizardState.selectedPageName,
      },
    );
  }
  
  // 审核人配置状态
  List<Employee> _selectedApprovers = [];
  ApprovalMode _approvalMode = ApprovalMode.sequential;
  ApprovalRuleType _approvalRuleType = ApprovalRuleType.single;

  // 显示审核人配置对话框
  void _showApproverConfigDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('审核人配置'),
          content: SizedBox(
            width: 800,
            height: 500,
            child: EmployeeSelector(
              mode: _approvalRuleType == ApprovalRuleType.single
                  ? SelectionMode.single
                  : SelectionMode.multiple,
              initialSelected: _selectedApprovers,
              onSelectionChanged: (employees) {
                setState(() {
                  _selectedApprovers = employees;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 保存审核人配置
                if (_selectedApprovers.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已选择 ${_selectedApprovers.length} 个审核人')),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  
  // 显示审核方式配置对话框
  void _showApprovalMethodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('审核方式配置'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 审批流程走向
                  const Text(
                    '审批流程走向',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: ApprovalMode.values.map((mode) {
                      return RadioListTile<ApprovalMode>(
                        title: Text(_getApprovalModeName(mode)),
                        subtitle: Text(_getApprovalModeDescription(mode)),
                        value: mode,
                        groupValue: _approvalMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _approvalMode = value;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // 审批处理规则
                  const Text(
                    '审批处理规则',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: ApprovalRuleType.values.map((rule) {
                      return RadioListTile<ApprovalRuleType>(
                        title: Text(_getApprovalRuleName(rule)),
                        subtitle: Text(_getApprovalRuleDescription(rule)),
                        value: rule,
                        groupValue: _approvalRuleType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _approvalRuleType = value;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 保存审核方式配置
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已保存审核方式配置')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  
  // 获取审批模式名称
  String _getApprovalModeName(ApprovalMode mode) {
    switch (mode) {
      case ApprovalMode.sequential:
        return '串行审批';
      case ApprovalMode.parallel:
        return '并行审批';
      case ApprovalMode.conditional:
        return '条件分支审批';
      case ApprovalMode.competitive:
        return '抢占/竞争审批';
      case ApprovalMode.directManager:
        return '直属主管审批';
    }
  }
  
  // 获取审批模式描述
  String _getApprovalModeDescription(ApprovalMode mode) {
    switch (mode) {
      case ApprovalMode.sequential:
        return '按预设顺序逐一进行审批，适用于层级明确的固定流程';
      case ApprovalMode.parallel:
        return '多位审批人同时处理任务，适用于多部门会签场景';
      case ApprovalMode.conditional:
        return '根据金额、类型等规则自动选择不同路径，实现差异化流程';
      case ApprovalMode.competitive:
        return '多个审批人抢占处理，适用于紧急任务或灵活分配场景';
      case ApprovalMode.directManager:
        return '自动按组织架构向上提交，常用于费用报销等场景';
    }
  }
  
  // 获取审批规则名称
  String _getApprovalRuleName(ApprovalRuleType rule) {
    switch (rule) {
      case ApprovalRuleType.single:
        return '单人审批';
      case ApprovalRuleType.andSign:
        return '会签（全部同意）';
      case ApprovalRuleType.orSign:
        return '或签（任意同意）';
      case ApprovalRuleType.sequential:
        return '依次审批';
    }
  }
  
  // 获取审批规则描述
  String _getApprovalRuleDescription(ApprovalRuleType rule) {
    switch (rule) {
      case ApprovalRuleType.single:
        return '指定单人处理日常事务，简单高效';
      case ApprovalRuleType.andSign:
        return '节点内所有审批人必须全部同意，用于重要决策';
      case ApprovalRuleType.orSign:
        return '节点内任意一人同意即可通过，提升效率避免阻塞';
      case ApprovalRuleType.sequential:
        return '节点内审批人按顺序处理，适用于部门内多级审核';
    }
  }
  
  // 处理继续选择关联页面
  void _handleContinueSelectPage() {
    setState(() {
      // 重置选择状态，允许用户重新选择关联页面
      _selectedPath.clear();
      _selectedPageRoute = '';
      _selectedPageName = '';
      _currentLevelItems = _navigationItems;
    });
    
    // 显示重新选择提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已重置关联页面选择，您可以重新选择')),
    );
  }
  
  // 处理闭环流程
  void _handleCloseLoop() {
    // 验证流程配置
    if (_wizardState.processName == null || _wizardState.processName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入流程名称')),
      );
      return;
    }
    
    if (_selectedPageRoute.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择关联页面')),
      );
      return;
    }
    
    // 更新向导状态
    _wizardState = _wizardState.copyWith(
      selectedPageRoute: _selectedPageRoute,
      selectedPageName: _selectedPageName,
      selectedPath: _selectedPath,
    );
    
    // 跳转到最后一步，完成流程创建
    setState(() {
      _currentStep = 2;
    });
    
    // 显示闭环流程提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('流程已闭环，您可以完成流程创建')),
    );
  }

  // 构建第一步：流程基本信息
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '流程基本信息',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _processNameController,
          decoration: const InputDecoration(
            labelText: '流程名称 *',
            border: OutlineInputBorder(),
            hintText: '例如：订单采购审批流程',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _processDescriptionController,
          decoration: const InputDecoration(
            labelText: '流程描述',
            border: OutlineInputBorder(),
            hintText: '描述流程的用途和适用场景',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        const Text(
          '请输入流程的基本信息，包括名称和描述，这些信息将用于流程管理和识别。',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // 构建第二步：选择关联页面
  Widget _buildStep2() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择关联页面',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // 路径显示
          if (_selectedPath.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _handleBackToParent,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回上一级'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPath.join(' > '),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 层级列表 - 固定高度，避免在Stepper中使用Expanded导致布局问题
          SizedBox(
            height: 250, // 减小高度，避免底部溢出
            child: ListView.builder(
              itemCount: _currentLevelItems.length,
              itemBuilder: (context, index) {
                final item = _currentLevelItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name']),
                    trailing: item.containsKey('children')
                        ? const Icon(Icons.arrow_forward)
                        : const Icon(Icons.check_circle_outline),
                    onTap: () => _handleLevelSelect(item),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '请选择流程关联的页面，流程将在该页面触发。选择过程中，系统会提示您需要配置的审核规则。',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 构建第三步：完成
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '流程创建完成',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '流程信息',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('流程名称', _wizardState.processName ?? ''),
                _buildInfoRow('流程描述', _wizardState.processDescription ?? ''),
                _buildInfoRow('关联页面', _wizardState.selectedPageName ?? ''),
                _buildInfoRow('关联页面路由', _wizardState.selectedPageRoute ?? ''),
                _buildInfoRow('选择路径', _wizardState.selectedPath.join(' > ')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '流程创建完成！点击「完成」按钮进入流程设计器，开始配置流程的审批节点和规则。',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建流程向导'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/settings/process-design');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _handleNext,
              onStepCancel: _currentStep > 0 ? _handleBack : null,
              onStepTapped: (step) {
                setState(() {
                  _currentStep = step;
                });
              },
              steps: [
                Step(
                  title: const Text('流程基本信息'),
                  content: _buildStep1(),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('选择关联页面'),
                  content: _buildStep2(),
                  isActive: _currentStep >= 1,
                  state: _currentStep >= 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('完成'),
                  content: _buildStep3(),
                  isActive: _currentStep >= 2,
                  state: _currentStep >= 2 ? StepState.complete : StepState.indexed,
                ),
              ],
              controlsBuilder: (context, details) {
                // 步骤2：选择关联页面时，显示完整的操作按钮
                if (_currentStep == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        // 主要操作按钮：上一步、下一步
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: details.onStepCancel,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('上一步'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF003366),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 16),
                            if (_currentStep < 2)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: details.onStepContinue,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('下一步'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF003366),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 功能按钮：审核人、审核方式、继续选择关联页面、闭环流程
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _showApproverConfigDialog();
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('审核人'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showApprovalMethodDialog();
                              },
                              icon: const Icon(Icons.settings),
                              label: const Text('审核方式'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                _handleContinueSelectPage();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('继续选择关联页面'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF003366),
                                side: BorderSide(color: const Color(0xFF003366)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _handleCloseLoop();
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('闭环流程'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                
                // 其他步骤显示默认按钮
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: details.onStepCancel,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('上一步'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF003366),
                            ),
                          ),
                        ),
                      if (_currentStep < 2)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: details.onStepContinue,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('下一步'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleComplete,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('完成'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
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
    );
  }
}
