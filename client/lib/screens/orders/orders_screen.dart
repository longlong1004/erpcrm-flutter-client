import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order/order.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/two_level_tab_layout.dart';
import './collector_order_total_screen.dart';
import './collector_order_import_screen.dart';
import './collector_order_pending_delivery_screen.dart';
import './mall_order_total_screen.dart';
import './mall_order_total_screen_enhanced.dart';
import './mall_order_import_screen.dart';
import './mall_order_pending_delivery_screen.dart';
import './other_order_total_screen.dart';
import './other_order_import_screen.dart';
import './other_order_pending_delivery_screen.dart';

/// 订单管理屏幕
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 商城订单
      TabConfig(
        title: '商城订单',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '商城订单总表',
            content: const MallOrderTotalScreen(),
          ),
          SecondLevelTabConfig(
            title: '商城订单总表（增强版）',
            content: const MallOrderTotalScreenEnhanced(),
          ),
          SecondLevelTabConfig(
            title: '导入信息',
            content: const MallOrderImportScreen(),
          ),
          SecondLevelTabConfig(
            title: '待发货',
            content: const MallOrderPendingDeliveryScreen(),
          ),
        ],
      ),
      // 集货商订单
      TabConfig(
        title: '集货商订单',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '集货商订单总表',
            content: const CollectorOrderTotalScreen(),
          ),
          SecondLevelTabConfig(
            title: '导入信息',
            content: const CollectorOrderImportScreen(),
          ),
          SecondLevelTabConfig(
            title: '待发货',
            content: const CollectorOrderPendingDeliveryScreen(),
          ),
        ],
      ),
      // 其它订单
      TabConfig(
        title: '其它订单',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '其它订单总表',
            content: const OtherOrderTotalScreen(),
          ),
          SecondLevelTabConfig(
            title: '导入信息',
            content: const OtherOrderImportScreen(),
          ),
          SecondLevelTabConfig(
            title: '待发货',
            content: const OtherOrderPendingDeliveryScreen(),
          ),
        ],
      ),
      // 补发货（退换货）
      TabConfig(
        title: '补发货（退换货）',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '补发货订单',
            content: const SupplementOrderScreen(),
          ),
        ],
      ),
      // 办理
      TabConfig(
        title: '办理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '办理订单',
            content: const SupplementOrderScreen(),
          ),
        ],
      ),
      // 对外业务订单
      TabConfig(
        title: '对外业务订单',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '对外业务订单',
            content: const SupplementOrderScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '订单管理',
    );
  }
}

/// 补发货（退换货）屏幕
class SupplementOrderScreen extends ConsumerStatefulWidget {
  const SupplementOrderScreen({super.key});

  @override
  ConsumerState<SupplementOrderScreen> createState() => _SupplementOrderScreenState();
}

class _SupplementOrderScreenState extends ConsumerState<SupplementOrderScreen> {
    final _searchController = TextEditingController();
    String? _selectedStatus;
    String? _selectedOrderType;
    String? _selectedPaymentMethod;
    String? _selectedPaymentStatus;
    DateTime? _startDate;
    DateTime? _endDate;
    String? _selectedSalesperson;
    bool _showFilterPanel = false;
    int _currentPage = 0;
    final int _rowsPerPage = 10;
    String? _sortColumn;
    bool _sortAscending = true;
    List<String> _selectedColumns = [
      'salesperson', 'status', 'orderType', 'orderNumber', 'companyName', 
      'railwayBureau', 'station', 'consigneeName', 'consigneePhone', 
      'shippingAddress', 'notes', 'createdAt', 'operation'
    ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final params = <String, dynamic>{
      'orderType': 'supplement', // 补发货订单类型
    };
    if (_searchController.text.isNotEmpty) {
      params['keyword'] = _searchController.text;
    }
    if (_selectedStatus != null) {
      params['status'] = _selectedStatus;
    }
    if (_selectedOrderType != null) {
      params['orderType'] = _selectedOrderType;
    }
    if (_selectedPaymentMethod != null) {
      params['paymentMethod'] = _selectedPaymentMethod;
    }
    if (_selectedPaymentStatus != null) {
      params['paymentStatus'] = _selectedPaymentStatus;
    }
    if (_startDate != null) {
      params['startDate'] = _startDate?.toIso8601String();
    }
    if (_endDate != null) {
      params['endDate'] = _endDate?.toIso8601String();
    }
    if (_selectedSalesperson != null) {
      params['salesperson'] = _selectedSalesperson;
    }

    ref.read(ordersProvider.notifier).fetchOrders(params: params);
    setState(() {
      _currentPage = 0;
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedStatus = null;
    _selectedOrderType = null;
    _selectedPaymentMethod = null;
    _selectedPaymentStatus = null;
    _startDate = null;
    _endDate = null;
    _selectedSalesperson = null;
    ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'supplement'});
    setState(() {
      _currentPage = 0;
      _showFilterPanel = false;
    });
  }

  void _viewOrderDetails(int orderId) {
    // 导航到订单详情页面
    context.push('/orders/$orderId');
  }

  void _editOrder(int orderId) {
    final orders = ref.read(ordersProvider).value ?? [];
    final order = orders.firstWhere((o) => o.id == orderId, orElse: () => orders.first);
    
    final orderNumberController = TextEditingController(text: order.orderNumber);
    final shippingAddressController = TextEditingController(text: order.shippingAddress ?? '');
    final notesController = TextEditingController(text: order.notes ?? '');
    final statusController = TextEditingController(text: order.status);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑订单'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: orderNumberController,
                    decoration: const InputDecoration(
                      labelText: '订单编号',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: shippingAddressController,
                    decoration: const InputDecoration(
                      labelText: '收货地址',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: statusController.text,
                    decoration: const InputDecoration(
                      labelText: '订单状态',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('待审核')),
                      DropdownMenuItem(value: 'APPROVED', child: Text('已通过')),
                      DropdownMenuItem(value: 'PROCESSING', child: Text('处理中')),
                      DropdownMenuItem(value: 'SHIPPED', child: Text('已发货')),
                      DropdownMenuItem(value: 'DELIVERED', child: Text('已送达')),
                      DropdownMenuItem(value: 'COMPLETED', child: Text('已完成')),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('已取消')),
                      DropdownMenuItem(value: 'REFUNDED', child: Text('已退款')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        statusController.text = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await ref.read(orderServiceProvider).updateOrder(orderId, {
                    'shippingAddress': shippingAddressController.text,
                    'status': statusController.text,
                    'notes': notesController.text,
                  });
                  ref.read(ordersProvider.notifier).refresh();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('订单更新成功'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('更新失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(int orderId) {
    // 删除订单
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除订单'),
        content: const Text('确定要删除该订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderServiceProvider).deleteOrder(orderId);
                ref.read(ordersProvider.notifier).refresh();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('订单已删除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _addNewSupplementOrder() {
    final orderNumberController = TextEditingController(text: 'SUPPLEMENT-${DateTime.now().millisecondsSinceEpoch}');
    final shippingAddressController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增补发货订单'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: orderNumberController,
                    decoration: const InputDecoration(
                      labelText: '订单编号',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入订单编号';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: shippingAddressController,
                    decoration: const InputDecoration(
                      labelText: '收货地址',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入收货地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final newOrder = await ref.read(orderServiceProvider).createOrder({
                    'orderNumber': orderNumberController.text,
                    'userId': 1001,
                    'orderItems': [
                      {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'productId': 1,
                        'productName': '补发货商品',
                        'quantity': 1,
                        'unitPrice': 100.0,
                        'subtotal': 100.0,
                      }
                    ],
                    'totalAmount': 100.0,
                    'status': 'PENDING',
                    'paymentMethod': '微信支付',
                    'paymentStatus': 'UNPAID',
                    'shippingAddress': shippingAddressController.text,
                    'billingAddress': shippingAddressController.text,
                    'shippingMethod': '快递',
                    'notes': notesController.text,
                    'orderType': 'supplement',
                  });
                  ref.read(ordersProvider.notifier).refresh();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('订单创建成功'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('创建失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '已通过';
      case 'PROCESSING':
        return '处理中';
      case 'SHIPPED':
        return '已发货';
      case 'DELIVERED':
        return '已送达';
      case 'COMPLETED':
        return '已完成';
      case 'CANCELLED':
        return '已取消';
      case 'REFUNDED':
        return '已退款';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.purple;
      case 'SHIPPED':
        return Colors.teal;
      case 'DELIVERED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }

  void _sort<T>(Comparable<T> Function(dynamic order) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
    });
  }
  
  // 显示列选择对话框
  void _showColumnSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择显示列'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 列选择列表
                CheckboxListTile(
                  title: const Text('业务员'),
                  value: _selectedColumns.contains('salesperson'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('salesperson');
                      } else {
                        _selectedColumns.remove('salesperson');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('状态'),
                  value: _selectedColumns.contains('status'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('status');
                      } else {
                        _selectedColumns.remove('status');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('订单类型'),
                  value: _selectedColumns.contains('orderType'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('orderType');
                      } else {
                        _selectedColumns.remove('orderType');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('订单编号'),
                  value: _selectedColumns.contains('orderNumber'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('orderNumber');
                      } else {
                        _selectedColumns.remove('orderNumber');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('公司名称'),
                  value: _selectedColumns.contains('companyName'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('companyName');
                      } else {
                        _selectedColumns.remove('companyName');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('所属路局'),
                  value: _selectedColumns.contains('railwayBureau'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('railwayBureau');
                      } else {
                        _selectedColumns.remove('railwayBureau');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('所属站段'),
                  value: _selectedColumns.contains('station'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('station');
                      } else {
                        _selectedColumns.remove('station');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('收货人姓名'),
                  value: _selectedColumns.contains('consigneeName'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('consigneeName');
                      } else {
                        _selectedColumns.remove('consigneeName');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('收货人电话'),
                  value: _selectedColumns.contains('consigneePhone'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('consigneePhone');
                      } else {
                        _selectedColumns.remove('consigneePhone');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('收货地址'),
                  value: _selectedColumns.contains('shippingAddress'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('shippingAddress');
                      } else {
                        _selectedColumns.remove('shippingAddress');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('备注'),
                  value: _selectedColumns.contains('notes'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('notes');
                      } else {
                        _selectedColumns.remove('notes');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('创建时间'),
                  value: _selectedColumns.contains('createdAt'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('createdAt');
                      } else {
                        _selectedColumns.remove('createdAt');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('操作'),
                  value: _selectedColumns.contains('operation'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedColumns.add('operation');
                      } else {
                        _selectedColumns.remove('operation');
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 显示日期范围选择器
  void _showDateRangePicker() {
    // 简单的日期范围选择实现
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择日期范围'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_startDate != null ? _formatDate(_startDate!) : '选择开始日期'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_endDate != null ? _formatDate(_endDate!) : '选择结束日期'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _addNewSupplementOrder,
                icon: const Icon(Icons.add),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),

        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 搜索框
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索订单号、客户名称、收货人等',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
              
              // 筛选按钮和列选择
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFilterPanel = !_showFilterPanel;
                          });
                        },
                        icon: Icon(_showFilterPanel ? Icons.filter_alt : Icons.filter_alt_outlined),
                        label: Text(_showFilterPanel ? '收起筛选' : '高级筛选'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showFilterPanel ? const Color(0xFF003366) : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // 显示列选择对话框
                          _showColumnSelectionDialog();
                        },
                        icon: const Icon(Icons.grid_view),
                        label: const Text('选择列'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('重置'),
                      ),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('筛选'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 高级筛选面板
              if (_showFilterPanel)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _showFilterPanel ? null : 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // 第一行筛选
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '订单状态',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value: _selectedStatus,
                                hint: const Text('选择状态'),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('全部状态'),
                                  ),
                                  for (final status in ['PENDING', 'APPROVED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'COMPLETED', 'CANCELLED', 'REFUNDED'])
                                    DropdownMenuItem(
                                      value: status,
                                      child: Text(_getStatusText(status)),
                                    ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '订单类型',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value: _selectedOrderType,
                                hint: const Text('选择订单类型'),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('全部类型'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'supplement',
                                    child: Text('补发货'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'refund',
                                    child: Text('退款'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'return',
                                    child: Text('退货'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOrderType = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 第二行筛选
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '支付方式',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value: _selectedPaymentMethod,
                                hint: const Text('选择支付方式'),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('全部支付方式'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'wechat',
                                    child: Text('微信支付'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'alipay',
                                    child: Text('支付宝'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'bank',
                                    child: Text('银行转账'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'cash',
                                    child: Text('现金'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '支付状态',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value: _selectedPaymentStatus,
                                hint: const Text('选择支付状态'),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('全部支付状态'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'PAID',
                                    child: Text('已支付'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'UNPAID',
                                    child: Text('未支付'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'PARTIALLY_PAID',
                                    child: Text('部分支付'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'REFUNDED',
                                    child: Text('已退款'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentStatus = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 第三行筛选
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '业务员',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value: _selectedSalesperson,
                                hint: const Text('选择业务员'),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('全部业务员'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'salesperson1',
                                    child: Text('业务员1'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'salesperson2',
                                    child: Text('业务员2'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'salesperson3',
                                    child: Text('业务员3'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSalesperson = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // 显示日期选择对话框
                                  _showDateRangePicker();
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _startDate != null && _endDate != null
                                      ? '${_formatDate(_startDate!)} 至 ${_formatDate(_endDate!)}'
                                      : '选择日期范围',
                                ),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 订单列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'supplement'}),
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'supplement'}),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                // 过滤补发货（退换货）订单 - 优先使用orderType字段，兼容原有系统
                final supplementOrders = orders.where((order) => 
                  order.orderType == 'supplement' || // 优先使用orderType字段
                  order.status.contains('REFUND') || // 兼容旧系统的状态过滤
                  order.status.contains('RETURN') || 
                  order.status.contains('SUPPLEMENT') ||
                  order.orderNumber.contains('SUPPLEMENT')
                ).toList();
                
                if (supplementOrders.isEmpty) {
                  return const Center(
                    child: Text('暂无补发货（退换货）订单数据'),
                  );
                }

                // 转换为表格所需的格式
                final tableOrders = supplementOrders.map((order) => {
                  'id': order.id,
                  'salesperson': '业务员1', // 模拟数据
                  'orderNumber': order.orderNumber,
                  'companyName': '公司名称', // 模拟数据
                  'railwayBureau': '北京局', // 模拟数据
                  'station': '北京站', // 模拟数据
                  'consigneeName': '收货人', // 模拟数据
                  'consigneePhone': '13800138000', // 模拟数据
                  'shippingAddress': order.shippingAddress ?? '',
                  'orderType': order.orderType ?? 'supplement',
                  'status': order.status,
                  'notes': order.notes ?? '',
                  'createdAt': order.formattedCreatedAt,
                }).toList();

                // 排序处理
                if (_sortColumn != null) {
                  tableOrders.sort((a, b) {
                    final aValue = a[_sortColumn] as Comparable;
                    final bValue = b[_sortColumn] as Comparable;
                    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                }

                // 分页处理
                final startIndex = _currentPage * _rowsPerPage;
                final endIndex = startIndex + _rowsPerPage;
                final paginatedOrders = startIndex < tableOrders.length
                    ? tableOrders.sublist(startIndex, endIndex > tableOrders.length ? tableOrders.length : endIndex)
                    : [];

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF003366)),
                            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            dataRowColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.grey.withOpacity(0.1);
                              }
                              return null;
                            }),
                            sortColumnIndex: _sortColumn == 'orderNumber' ? 3 :
                                          _sortColumn == 'createdAt' ? 11 : null,
                            sortAscending: _sortAscending,
                            columns: [
                              const DataColumn(label: Text('业务员')),
                              const DataColumn(label: Text('状态')),
                              const DataColumn(label: Text('订单类型')),
                              DataColumn(
                                label: const Text('订单编号'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['orderNumber'] as String, 'orderNumber');
                                },
                              ),
                              const DataColumn(label: Text('公司名称')),
                              const DataColumn(label: Text('所属路局')),
                              const DataColumn(label: Text('所属站段')),
                              const DataColumn(label: Text('收货人姓名')),
                              const DataColumn(label: Text('收货人电话')),
                              const DataColumn(label: Text('收货地址')),
                              const DataColumn(label: Text('备注')),
                              DataColumn(
                                label: const Text('创建时间'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['createdAt'] as String, 'createdAt');
                                },
                              ),
                              const DataColumn(label: Text('操作')),
                            ],
                            rows: paginatedOrders.map((order) => DataRow(cells: [
                              DataCell(Text(order['salesperson'] as String)),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order['status'] as String),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(order['status'] as String),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )),
                              DataCell(Text(order['orderType'] as String)),
                              DataCell(Text(order['orderNumber'] as String)),
                              DataCell(Text(order['companyName'] as String)),
                              DataCell(Text(order['railwayBureau'] as String)),
                              DataCell(Text(order['station'] as String)),
                              DataCell(Text(order['consigneeName'] as String)),
                              DataCell(Text(order['consigneePhone'] as String)),
                              DataCell(Text(order['shippingAddress'] as String)),
                              DataCell(Text(order['notes'] as String)),
                              DataCell(Text(order['createdAt'] as String)),
                              DataCell(Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _viewOrderDetails(order['id'] as int),
                                    icon: const Icon(Icons.visibility, size: 16),
                                    label: const Text('查看'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _editOrder(order['id'] as int),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('编辑'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteOrder(order['id'] as int),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text('删除'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              )),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                    // 分页控制
                    if (tableOrders.length > _rowsPerPage)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _currentPage > 0
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              child: const Text('上一页'),
                            ),
                            Text('第 ${_currentPage + 1} 页，共 ${(tableOrders.length / _rowsPerPage).ceil()} 页'),
                            TextButton(
                              onPressed: (endIndex < tableOrders.length)
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                              child: const Text('下一页'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 办理订单屏幕
class HandleOrderScreen extends ConsumerStatefulWidget {
  const HandleOrderScreen({super.key});

  @override
  ConsumerState<HandleOrderScreen> createState() => _HandleOrderScreenState();
}

class _HandleOrderScreenState extends ConsumerState<HandleOrderScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String? _sortColumn;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final params = <String, dynamic>{
      'orderType': 'handle', // 办理订单类型
    };
    if (_searchController.text.isNotEmpty) {
      params['keyword'] = _searchController.text;
    }
    if (_selectedStatus != null) {
      params['status'] = _selectedStatus;
    }

    ref.read(ordersProvider.notifier).fetchOrders(params: params);
    setState(() {
      _currentPage = 0;
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedStatus = null;
    ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'handle'});
    setState(() {
      _currentPage = 0;
    });
  }

  void _viewOrderDetails(int orderId) {
    // 导航到订单详情页面
    context.push('/orders/$orderId');
  }

  void _startHandleProcess(int orderId) {
    // 触发办理流程
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始办理订单 $orderId')),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '已通过';
      case 'PROCESSING':
        return '处理中';
      case 'SHIPPED':
        return '已发货';
      case 'DELIVERED':
        return '已送达';
      case 'COMPLETED':
        return '已完成';
      case 'CANCELLED':
        return '已取消';
      case 'REFUNDED':
        return '已退款';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.purple;
      case 'SHIPPED':
        return Colors.teal;
      case 'DELIVERED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }

  void _sort<T>(Comparable<T> Function(dynamic order) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('办理流程已触发')),
                ),
                icon: const Icon(Icons.handshake),
                label: const Text('办理'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),

        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索订单号或相关信息',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '订单状态',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedStatus,
                      hint: const Text('选择状态'),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: const Text('全部状态'),
                        ),
                        for (final status in ['PENDING', 'APPROVED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'COMPLETED', 'CANCELLED', 'REFUNDED'])
                          DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('筛选'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 订单列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'handle'}),
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'handle'}),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                // 过滤需要办理的订单 - 优先使用orderType字段，兼容原有系统
                final handleOrders = orders.where((order) => 
                  order.orderType == 'handle' || // 优先使用orderType字段
                  order.status == 'PENDING' || // 兼容旧系统的状态过滤
                  order.status == 'APPROVED' || 
                  order.status == 'PROCESSING' ||
                  order.paymentStatus == 'UNPAID'
                ).toList();
                
                if (handleOrders.isEmpty) {
                  return const Center(
                    child: Text('暂无需要办理的订单数据'),
                  );
                }

                // 转换为表格所需的格式
                final tableOrders = handleOrders.map((order) => {
                  'id': order.id,
                  'salesperson': '业务员1', // 模拟数据
                  'orderNumber': order.orderNumber,
                  'brand': '品牌', // 模拟数据
                  'railwayBureau': '北京局', // 模拟数据
                  'station': '北京站', // 模拟数据
                  'productCode': 'PROD-000001', // 模拟数据
                  'railwayName': order.orderItems.isNotEmpty ? order.orderItems[0].productName : '',
                  'railwayModel': '型号', // 模拟数据
                  'unit': '件', // 模拟数据
                  'quantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity),
                  'price': order.orderItems.isNotEmpty ? order.orderItems[0].unitPrice : 0.0,
                  'total': order.totalAmount ?? 0.0,
                  'profit': (order.totalAmount ?? 0.0) * 0.2, // 模拟利润
                  'handlePercentage': 75.5, // 模拟办理百分比
                  'handleAmount': (order.totalAmount ?? 0.0) * 0.755, // 模拟办理金额
                  'status': order.status,
                  'supplier': '供应商', // 模拟数据
                  'contractNumber': 'CONTRACT-000001', // 模拟数据
                  'time': order.formattedCreatedAt,
                }).toList();

                // 排序处理
                if (_sortColumn != null) {
                  tableOrders.sort((a, b) {
                    final aValue = a[_sortColumn] as Comparable;
                    final bValue = b[_sortColumn] as Comparable;
                    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                }

                // 分页处理
                final startIndex = _currentPage * _rowsPerPage;
                final endIndex = startIndex + _rowsPerPage;
                final paginatedOrders = startIndex < tableOrders.length
                    ? tableOrders.sublist(startIndex, endIndex > tableOrders.length ? tableOrders.length : endIndex)
                    : [];

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF003366)),
                            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            dataRowColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.grey.withOpacity(0.1);
                              }
                              return null;
                            }),
                            sortColumnIndex: _sortColumn == 'orderNumber' ? 2 :
                                          _sortColumn == 'total' ? 11 :
                                          _sortColumn == 'profit' ? 12 :
                                          _sortColumn == 'handlePercentage' ? 13 :
                                          _sortColumn == 'handleAmount' ? 14 : null,
                            sortAscending: _sortAscending,
                            columns: [
                              const DataColumn(label: Text('勾选'), numeric: true),
                              const DataColumn(label: Text('业务员')),
                              DataColumn(
                                label: const Text('订单编号'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['orderNumber'] as String, 'orderNumber');
                                },
                              ),
                              const DataColumn(label: Text('品牌')),
                              const DataColumn(label: Text('所属路局')),
                              const DataColumn(label: Text('站段')),
                              const DataColumn(label: Text('单品编码')),
                              const DataColumn(label: Text('国铁名称')),
                              const DataColumn(label: Text('国铁型号')),
                              const DataColumn(label: Text('单位')),
                              const DataColumn(label: Text('数量'), numeric: true),
                              const DataColumn(label: Text('单价'), numeric: true),
                              DataColumn(
                                label: const Text('合计'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['total'] as double, 'total');
                                },
                              ),
                              DataColumn(
                                label: const Text('利润'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['profit'] as double, 'profit');
                                },
                              ),
                              DataColumn(
                                label: const Text('办理百分比'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['handlePercentage'] as double, 'handlePercentage');
                                },
                              ),
                              DataColumn(
                                label: const Text('办理金额'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['handleAmount'] as double, 'handleAmount');
                                },
                              ),
                              const DataColumn(label: Text('状态')),
                              const DataColumn(label: Text('供应商')),
                              const DataColumn(label: Text('合同编号')),
                              const DataColumn(label: Text('时间')),
                              const DataColumn(label: Text('操作')),
                            ],
                            rows: paginatedOrders.map((order) => DataRow(cells: [
                              DataCell(Checkbox(
                                value: false,
                                onChanged: (value) {
                                  // 更新选中状态
                                },
                              )),
                              DataCell(Text(order['salesperson'] as String)),
                              DataCell(Text(order['orderNumber'] as String)),
                              DataCell(Text(order['brand'] as String)),
                              DataCell(Text(order['railwayBureau'] as String)),
                              DataCell(Text(order['station'] as String)),
                              DataCell(Text(order['productCode'] as String)),
                              DataCell(Text(order['railwayName'] as String)),
                              DataCell(Text(order['railwayModel'] as String)),
                              DataCell(Text(order['unit'] as String)),
                              DataCell(Text((order['quantity'] as int).toString())),
                              DataCell(Text((order['price'] as double).toStringAsFixed(2))),
                              DataCell(Text((order['total'] as double).toStringAsFixed(2))),
                              DataCell(Text((order['profit'] as double).toStringAsFixed(2))),
                              DataCell(Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: (order['handlePercentage'] as double) / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${order['handlePercentage']}%'),
                                ],
                              )),
                              DataCell(Text((order['handleAmount'] as double).toStringAsFixed(2))),
                              DataCell(Text(_getStatusText(order['status'] as String))),
                              DataCell(Text(order['supplier'] as String)),
                              DataCell(Text(order['contractNumber'] as String)),
                              DataCell(Text(order['time'] as String)),
                              DataCell(TextButton.icon(
                                onPressed: () => _startHandleProcess(order['id'] as int),
                                icon: const Icon(Icons.handshake, size: 16),
                                label: const Text('办理'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  backgroundColor: const Color(0xFF003366),
                                  foregroundColor: Colors.white,
                                ),
                              )),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                    // 分页控制
                    if (tableOrders.length > _rowsPerPage)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _currentPage > 0
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              child: const Text('上一页'),
                            ),
                            Text('第 ${_currentPage + 1} 页，共 ${(tableOrders.length / _rowsPerPage).ceil()} 页'),
                            TextButton(
                              onPressed: (endIndex < tableOrders.length)
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                              child: const Text('下一页'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 对外业务订单屏幕
class ExternalOrderScreen extends ConsumerStatefulWidget {
  const ExternalOrderScreen({super.key});

  @override
  ConsumerState<ExternalOrderScreen> createState() => _ExternalOrderScreenState();
}

class _ExternalOrderScreenState extends ConsumerState<ExternalOrderScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  double? _minAmount;
  double? _maxAmount;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String? _sortColumn;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final params = <String, dynamic>{
      'orderType': 'external', // 对外业务订单类型
    };
    if (_searchController.text.isNotEmpty) {
      params['keyword'] = _searchController.text;
    }
    if (_selectedStatus != null) {
      params['status'] = _selectedStatus;
    }
    if (_minAmount != null) {
      params['minAmount'] = _minAmount;
    }
    if (_maxAmount != null) {
      params['maxAmount'] = _maxAmount;
    }

    ref.read(ordersProvider.notifier).fetchOrders(params: params);
    setState(() {
      _currentPage = 0;
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedStatus = null;
    _minAmount = null;
    _maxAmount = null;
    ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'external'});
    setState(() {
      _currentPage = 0;
    });
  }

  void _sort<T>(Comparable<T> Function(dynamic order) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
    });
  }

  void _viewOrderDetails(int orderId) {
    // 导航到订单详情页面
    context.push('/orders/$orderId');
  }

  void _shipOrder(int orderId) {
    // 发货操作
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('发货订单 $orderId')),
    );
  }

  void _deleteOrder(int orderId) {
    // 删除订单
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除订单'),
        content: const Text('确定要删除该订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderServiceProvider).deleteOrder(orderId);
                ref.read(ordersProvider.notifier).refresh();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('订单已删除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _addNewExternalOrder() {
    final orderNumberController = TextEditingController(text: 'EXTERNAL-${DateTime.now().millisecondsSinceEpoch}');
    final customerNameController = TextEditingController();
    final shippingAddressController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增对外业务订单'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: orderNumberController,
                    decoration: const InputDecoration(
                      labelText: '订单编号',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入订单编号';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: customerNameController,
                    decoration: const InputDecoration(
                      labelText: '客户公司名称',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入客户公司名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: shippingAddressController,
                    decoration: const InputDecoration(
                      labelText: '收货地址',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入收货地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await ref.read(ordersProvider.notifier).createOrder({
                    'orderNumber': orderNumberController.text,
                    'userId': 3001,
                    'orderItems': [
                      {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'productId': 4,
                        'productName': '对外业务商品',
                        'quantity': 1,
                        'unitPrice': 500.0,
                        'subtotal': 500.0,
                      }
                    ],
                    'totalAmount': 500.0,
                    'status': 'PENDING',
                    'paymentMethod': '微信支付',
                    'paymentStatus': 'UNPAID',
                    'shippingAddress': shippingAddressController.text,
                    'billingAddress': shippingAddressController.text,
                    'shippingMethod': '快递',
                    'notes': notesController.text,
                    'orderType': 'external',
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('订单创建成功'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('创建失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _importExternalOrders() {
    // 导入对外业务订单
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入对外业务订单功能已触发')),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '已通过';
      case 'PROCESSING':
        return '处理中';
      case 'SHIPPED':
        return '已发货';
      case 'DELIVERED':
        return '已送达';
      case 'COMPLETED':
        return '已完成';
      case 'CANCELLED':
        return '已取消';
      case 'REFUNDED':
        return '已退款';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.purple;
      case 'SHIPPED':
        return Colors.teal;
      case 'DELIVERED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _addNewExternalOrder,
                icon: const Icon(Icons.add),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _importExternalOrders,
                icon: const Icon(Icons.upload_file),
                label: const Text('导入'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),

        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索订单号或客户公司名称',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '订单状态',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedStatus,
                      hint: const Text('选择状态'),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: const Text('全部状态'),
                        ),
                        for (final status in ['PENDING', 'APPROVED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'COMPLETED', 'CANCELLED', 'REFUNDED'])
                          DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '最小金额',
                        prefixText: '¥',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _minAmount = value.isEmpty ? null : double.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '最大金额',
                        prefixText: '¥',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _maxAmount = value.isEmpty ? null : double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('筛选'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 订单列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'external'}),
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'external'}),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                // 过滤对外业务订单 - 优先使用orderType字段，兼容原有系统
                final externalOrders = orders.where((order) => 
                  order.orderType == 'external' || // 优先使用orderType字段
                  order.orderNumber.contains('EXTERNAL') || // 兼容旧系统的订单号前缀
                  (order.status == 'EXTERNAL' || order.status.contains('EXTERNAL'))
                ).toList();
                
                if (externalOrders.isEmpty) {
                  return const Center(
                    child: Text('暂无对外业务订单数据'),
                  );
                }

                // 转换为表格所需的格式
                final tableOrders = externalOrders.map((order) => {
                  'id': order.id,
                  'salesperson': '业务员1', // 模拟数据
                  'status': order.status,
                  'customerCompanyName': '客户公司', // 模拟数据
                  'companyName': '公司名称', // 模拟数据
                  'materialName': order.orderItems.isNotEmpty ? order.orderItems[0].productName : '',
                  'specificationModel': '规格型号', // 模拟数据
                  'unit': '件', // 模拟数据
                  'quantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity),
                  'amount': order.totalAmount ?? 0.0,
                }).toList();

                // 排序处理
                if (_sortColumn != null) {
                  tableOrders.sort((a, b) {
                    final aValue = a[_sortColumn] as Comparable;
                    final bValue = b[_sortColumn] as Comparable;
                    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                }

                // 分页处理
                final startIndex = _currentPage * _rowsPerPage;
                final endIndex = startIndex + _rowsPerPage;
                final paginatedOrders = startIndex < tableOrders.length
                    ? tableOrders.sublist(startIndex, endIndex > tableOrders.length ? tableOrders.length : endIndex)
                    : [];

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF003366)),
                            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            dataRowColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.grey.withOpacity(0.1);
                              }
                              return null;
                            }),
                            sortColumnIndex: _sortColumn == 'amount' ? 9 :
                                          _sortColumn == 'quantity' ? 8 : null,
                            sortAscending: _sortAscending,
                            columns: [
                              const DataColumn(label: Text('勾选'), numeric: true),
                              const DataColumn(label: Text('业务员')),
                              const DataColumn(label: Text('状态')),
                              const DataColumn(label: Text('客户公司名称')),
                              const DataColumn(label: Text('公司名称')),
                              const DataColumn(label: Text('物资名称')),
                              const DataColumn(label: Text('规格型号')),
                              const DataColumn(label: Text('单位')),
                              DataColumn(
                                label: const Text('数量'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['quantity'] as int, 'quantity');
                                },
                              ),
                              DataColumn(
                                label: const Text('金额'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['amount'] as double, 'amount');
                                },
                              ),
                              const DataColumn(label: Text('操作')),
                            ],
                            rows: paginatedOrders.map((order) => DataRow(cells: [
                              DataCell(Checkbox(
                                value: false,
                                onChanged: (value) {
                                  // 更新选中状态
                                },
                              )),
                              DataCell(Text(order['salesperson'] as String)),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order['status'] as String),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(order['status'] as String),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )),
                              DataCell(Text(order['customerCompanyName'] as String)),
                              DataCell(Text(order['companyName'] as String)),
                              DataCell(Text(order['materialName'] as String)),
                              DataCell(Text(order['specificationModel'] as String)),
                              DataCell(Text(order['unit'] as String)),
                              DataCell(Text((order['quantity'] as int).toString())),
                              DataCell(Text('¥${(order['amount'] as double).toStringAsFixed(2)}')),
                              DataCell(Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _viewOrderDetails(order['id'] as int),
                                    icon: const Icon(Icons.visibility, size: 16),
                                    label: const Text('查看'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _shipOrder(order['id'] as int),
                                    icon: const Icon(Icons.local_shipping, size: 16),
                                    label: const Text('发货'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteOrder(order['id'] as int),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text('删除'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              )),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                    // 分页控制
                    if (tableOrders.length > _rowsPerPage)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _currentPage > 0
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              child: const Text('上一页'),
                            ),
                            Text('第 ${_currentPage + 1} 页，共 ${(tableOrders.length / _rowsPerPage).ceil()} 页'),
                            TextButton(
                              onPressed: (endIndex < tableOrders.length)
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                              child: const Text('下一页'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}