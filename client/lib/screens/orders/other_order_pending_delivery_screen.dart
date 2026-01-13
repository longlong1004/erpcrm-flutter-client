import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order/order.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';

/// 其它订单待发货屏幕
class OtherOrderPendingDeliveryScreen extends ConsumerStatefulWidget {
  const OtherOrderPendingDeliveryScreen({super.key});

  @override
  ConsumerState<OtherOrderPendingDeliveryScreen> createState() => _OtherOrderPendingDeliveryScreenState();
}

class _OtherOrderPendingDeliveryScreenState extends ConsumerState<OtherOrderPendingDeliveryScreen> {
  final TextEditingController _searchController = TextEditingController();
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
      'orderType': 'other', // 其它订单类型
      'status': 'APPROVED', // 待发货状态
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
    ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other', 'status': 'APPROVED'});
    setState(() {
      _currentPage = 0;
    });
  }

  void _viewOrderDetails(int orderId) {
    // 导航到订单详情页面
    context.push('/orders/$orderId');
  }

  void _changeSalesperson(int orderId) {
    // 实现修改业务员功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改业务员'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择新的业务员'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '业务员',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
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
                // 处理业务员选择
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 保存修改
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已修改订单 $orderId 的业务员')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _shipOrder(int orderId) {
    // 实现发货功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发货'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('填写发货信息'),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: '物流公司',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: '物流单号',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 保存发货信息
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('订单 $orderId 已发货')),
              );
            },
            child: const Text('确认发货'),
          ),
        ],
      ),
    );
  }

  void _editOrder(int orderId) {
    // 实现编辑订单功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑订单 $orderId')),
    );
  }

  void _uploadShippingOrder(int orderId) {
    // 实现上传发货单功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('上传发货单功能已触发，订单ID: $orderId')),
    );
  }

  void _deleteOrder(int orderId) {
    // 实现删除订单功能
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

  void _sort(Comparable<dynamic> Function(dynamic order) getField, String columnName) {
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
        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.all(16),
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
            onRefresh: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other', 'status': 'APPROVED'}),
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other', 'status': 'APPROVED'}),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                // 过滤其它订单 - 优先使用orderType字段，兼容原有系统
                final otherOrders = orders.where((order) => 
                  order.orderType == 'other' || // 优先使用orderType字段
                  (order.orderType == null && // 兼容没有orderType的旧数据
                   !order.orderNumber.contains('MALL') && 
                   !order.orderNumber.contains('COLLECTOR'))
                ).toList();
                
                if (otherOrders.isEmpty) {
                  return const Center(
                    child: Text('暂无待发货订单数据'),
                  );
                }

                // 转换为表格所需的格式
                final tableOrders = otherOrders.map((order) => {
                  'id': order.id,
                  'salesperson': '业务员1', // 模拟数据
                  'status': order.status,
                  'orderType': '其它订单', // 模拟数据
                  'orderNumber': order.orderNumber,
                  'orderQuantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity),
                  'matchQuantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity), // 模拟数据
                  'consigneeName': '收货人', // 模拟数据
                  'consigneePhone': '13800138000', // 模拟数据
                  'shippingAddress': order.shippingAddress ?? '',
                  'railwayBureau': '北京局', // 模拟数据
                  'station': '北京站', // 模拟数据
                  'companyName': '公司名称', // 模拟数据
                  'logisticsCompany': '顺丰速运', // 模拟数据
                  'logisticsTrackingNumber': 'SF1234567890', // 模拟数据
                  'submittedDate': order.formattedCreatedAt.split(' ')[0],
                  'approvedDate': order.formattedUpdatedAt.split(' ')[0],
                  'matchedTime': order.formattedUpdatedAt,
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
                                          _sortColumn == 'submittedDate' ? 14 : null,
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
                              const DataColumn(label: Text('下单数量'), numeric: true),
                              const DataColumn(label: Text('匹配数量'), numeric: true),
                              const DataColumn(label: Text('收货人姓名')),
                              const DataColumn(label: Text('收货人电话')),
                              const DataColumn(label: Text('收货地址')),
                              const DataColumn(label: Text('所属路局')),
                              const DataColumn(label: Text('站段')),
                              const DataColumn(label: Text('公司名称')),
                              const DataColumn(label: Text('物流公司')),
                              const DataColumn(label: Text('物流单号')),
                              DataColumn(
                                label: const Text('提交日期'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['submittedDate'] as String, 'submittedDate');
                                },
                              ),
                              const DataColumn(label: Text('审批日期')),
                              const DataColumn(label: Text('匹配时间')),
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
                              DataCell(Text((order['orderQuantity'] as int).toString())),
                              DataCell(Text((order['matchQuantity'] as int).toString())),
                              DataCell(Text(order['consigneeName'] as String)),
                              DataCell(Text(order['consigneePhone'] as String)),
                              DataCell(Text(order['shippingAddress'] as String)),
                              DataCell(Text(order['railwayBureau'] as String)),
                              DataCell(Text(order['station'] as String)),
                              DataCell(Text(order['companyName'] as String)),
                              DataCell(Text(order['logisticsCompany'] as String)),
                              DataCell(Text(order['logisticsTrackingNumber'] as String)),
                              DataCell(Text(order['submittedDate'] as String)),
                              DataCell(Text(order['approvedDate'] as String)),
                              DataCell(Text(order['matchedTime'] as String)),
                              DataCell(Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _changeSalesperson(order['id'] as int),
                                    icon: const Icon(Icons.swap_horiz, size: 16),
                                    label: const Text('修改业务员'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
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
                                    onPressed: () => _editOrder(order['id'] as int),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('编辑'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _uploadShippingOrder(order['id'] as int),
                                    icon: const Icon(Icons.upload_file, size: 16),
                                    label: const Text('上传发货单'),
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
