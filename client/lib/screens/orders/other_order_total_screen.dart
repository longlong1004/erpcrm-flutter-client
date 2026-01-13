import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order/order.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';

/// 其它订单总表屏幕
class OtherOrderTotalScreen extends ConsumerStatefulWidget {
  const OtherOrderTotalScreen({super.key});

  @override
  ConsumerState<OtherOrderTotalScreen> createState() => _OtherOrderTotalScreenState();
}

class _OtherOrderTotalScreenState extends ConsumerState<OtherOrderTotalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPaymentStatus;
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
    };
    if (_searchController.text.isNotEmpty) {
      params['keyword'] = _searchController.text;
    }
    if (_selectedStatus != null) {
      params['status'] = _selectedStatus;
    }
    if (_selectedPaymentStatus != null) {
      params['paymentStatus'] = _selectedPaymentStatus;
    }

    ref.read(ordersProvider.notifier).fetchOrders(params: params);
    setState(() {
      _currentPage = 0;
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedStatus = null;
    _selectedPaymentStatus = null;
    ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other'});
    setState(() {
      _currentPage = 0;
    });
  }

  void _viewOrderDetails(int orderId) {
    // 导航到订单详情页面
    context.push('/orders/$orderId');
  }

  void _importOrders() {
    // 实现导入功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能已触发')),
    );
  }

  void _deleteSelectedOrders() {
    // 实现删除功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('删除功能已触发')),
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

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'UNPAID':
        return '未支付';
      case 'PAID':
        return '已支付';
      case 'REFUNDED':
        return '已退款';
      case 'PARTIALLY_REFUNDED':
        return '部分退款';
      default:
        return status ?? '未知';
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'UNPAID':
        return Colors.red;
      case 'PAID':
        return Colors.green;
      case 'REFUNDED':
        return Colors.redAccent;
      case 'PARTIALLY_REFUNDED':
        return Colors.orange;
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
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _importOrders,
                icon: const Icon(Icons.upload_file),
                label: const Text('导入'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _deleteSelectedOrders,
                icon: const Icon(Icons.delete),
                label: const Text('删除'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),

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
                        for (final status in ['UNPAID', 'PAID', 'REFUNDED', 'PARTIALLY_REFUNDED'])
                          DropdownMenuItem(
                            value: status,
                            child: Text(_getPaymentStatusText(status)),
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
            onRefresh: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other'}),
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(params: {'orderType': 'other'}),
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
                    child: Text('暂无其它订单数据'),
                  );
                }

                // 转换为表格所需的格式
                final tableOrders = otherOrders.map((order) => {
                  'id': order.id,
                  'checked': false,
                  'salesperson': '业务员1', // 模拟数据
                  'orderType': '其它订单', // 模拟数据
                  'orderNumber': order.orderNumber,
                  'submittedDate': order.formattedCreatedAt.split(' ')[0],
                  'approvedDate': order.formattedUpdatedAt.split(' ')[0],
                  'consigneeName': '收货人', // 模拟数据
                  'consigneePhone': '13800138000', // 模拟数据
                  'shippingAddress': order.shippingAddress ?? '',
                  'railwayBureau': '北京局', // 模拟数据
                  'station': '北京站', // 模拟数据
                  'companyName': '公司名称', // 模拟数据
                  'brand': '品牌', // 模拟数据
                  'productCode': 'PROD-000001', // 模拟数据
                  'railwayName': order.orderItems.isNotEmpty ? order.orderItems[0].productName : '',
                  'railwayModel': '型号', // 模拟数据
                  'orderQuantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity),
                  'railwayPrice': order.orderItems.isNotEmpty ? order.orderItems[0].unitPrice : 0.0,
                  'railwayAmount': order.totalAmount ?? 0.0,
                  'invoiceApplyTime': order.formattedCreatedAt.split(' ')[0], // 模拟数据
                  'paymentReceivedTime': order.formattedUpdatedAt.split(' ')[0], // 模拟数据
                  'paymentTime': order.formattedUpdatedAt.split(' ')[0], // 模拟数据
                  'supplier': '供应商', // 模拟数据
                  'actualName': order.orderItems.isNotEmpty ? order.orderItems[0].productName : '',
                  'actualModel': '型号', // 模拟数据
                  'purchasePrice': order.orderItems.isNotEmpty ? (order.orderItems[0].unitPrice * 0.9) : 0.0, // 模拟数据
                  'actualQuantity': order.orderItems.fold(0, (sum, item) => sum + item.quantity),
                  'unit': '件', // 模拟数据
                  'purchaseAmount': (order.totalAmount ?? 0.0) * 0.9, // 模拟数据
                  'notes': order.notes ?? '',
                  'paymentMethod': order.paymentMethod ?? '',
                  'invoiceType': '增值税专用发票', // 模拟数据
                  'inputInvoiceTime': order.formattedUpdatedAt.split(' ')[0], // 模拟数据
                  'shippingFee': 10.0, // 模拟数据
                  'supplementType': '', // 模拟数据
                  'supplementName': '', // 模拟数据
                  'supplementAmount': 0.0, // 模拟数据
                  'handlingFee': 0.0, // 模拟数据
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
                                          _sortColumn == 'submittedDate' ? 4 :
                                          _sortColumn == 'railwayAmount' ? 17 : null,
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
                              const DataColumn(label: Text('订单类型')),
                              DataColumn(
                                label: const Text('订单编号'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['orderNumber'] as String, 'orderNumber');
                                },
                              ),
                              DataColumn(
                                label: const Text('提交日期'),
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['submittedDate'] as String, 'submittedDate');
                                },
                              ),
                              const DataColumn(label: Text('审批日期')),
                              const DataColumn(label: Text('收货人姓名')),
                              const DataColumn(label: Text('收货人电话')),
                              const DataColumn(label: Text('收货地址')),
                              const DataColumn(label: Text('所属路局')),
                              const DataColumn(label: Text('站段')),
                              const DataColumn(label: Text('公司名称')),
                              const DataColumn(label: Text('品牌')),
                              const DataColumn(label: Text('单品编码')),
                              const DataColumn(label: Text('国铁名称')),
                              const DataColumn(label: Text('国铁型号')),
                              const DataColumn(label: Text('下单数量'), numeric: true),
                              const DataColumn(label: Text('国铁单价'), numeric: true),
                              DataColumn(
                                label: const Text('国铁金额'),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _sort((order) => order['railwayAmount'] as double, 'railwayAmount');
                                },
                              ),
                              const DataColumn(label: Text('发票申请时间')),
                              const DataColumn(label: Text('回款时间')),
                              const DataColumn(label: Text('付款时间')),
                              const DataColumn(label: Text('供应商')),
                              const DataColumn(label: Text('实发名称')),
                              const DataColumn(label: Text('实发型号')),
                              const DataColumn(label: Text('采购单价'), numeric: true),
                              const DataColumn(label: Text('实发数量'), numeric: true),
                              const DataColumn(label: Text('单位')),
                              const DataColumn(label: Text('采购金额'), numeric: true),
                              const DataColumn(label: Text('备注')),
                              const DataColumn(label: Text('付款方式')),
                              const DataColumn(label: Text('发票类型')),
                              const DataColumn(label: Text('进项发票时间')),
                              const DataColumn(label: Text('运费'), numeric: true),
                              const DataColumn(label: Text('补发货类型')),
                              const DataColumn(label: Text('补发货名称')),
                              const DataColumn(label: Text('补发货金额'), numeric: true),
                              const DataColumn(label: Text('办理费用'), numeric: true),
                              const DataColumn(label: Text('操作')),
                            ],
                            rows: paginatedOrders.map((order) => DataRow(cells: [
                              DataCell(Checkbox(
                                value: order['checked'] as bool,
                                onChanged: (value) {
                                  // 更新选中状态
                                  setState(() {
                                    order['checked'] = value ?? false;
                                  });
                                },
                              )),
                              DataCell(Text(order['salesperson'] as String)),
                              DataCell(Text(order['orderNumber'] as String)),
                              DataCell(Text(order['orderType'] as String)),
                              DataCell(Text(order['orderNumber'] as String)),
                              DataCell(Text(order['submittedDate'] as String)),
                              DataCell(Text(order['approvedDate'] as String)),
                              DataCell(Text(order['consigneeName'] as String)),
                              DataCell(Text(order['consigneePhone'] as String)),
                              DataCell(Text(order['shippingAddress'] as String)),
                              DataCell(Text(order['railwayBureau'] as String)),
                              DataCell(Text(order['station'] as String)),
                              DataCell(Text(order['companyName'] as String)),
                              DataCell(Text(order['brand'] as String)),
                              DataCell(Text(order['productCode'] as String)),
                              DataCell(Text(order['railwayName'] as String)),
                              DataCell(Text(order['railwayModel'] as String)),
                              DataCell(Text((order['orderQuantity'] as int).toString())),
                              DataCell(Text((order['railwayPrice'] as double).toStringAsFixed(2))),
                              DataCell(Text((order['railwayAmount'] as double).toStringAsFixed(2))),
                              DataCell(Text(order['invoiceApplyTime'] as String)),
                              DataCell(Text(order['paymentReceivedTime'] as String)),
                              DataCell(Text(order['paymentTime'] as String)),
                              DataCell(Text(order['supplier'] as String)),
                              DataCell(Text(order['actualName'] as String)),
                              DataCell(Text(order['actualModel'] as String)),
                              DataCell(Text((order['purchasePrice'] as double).toStringAsFixed(2))),
                              DataCell(Text((order['actualQuantity'] as int).toString())),
                              DataCell(Text(order['unit'] as String)),
                              DataCell(Text((order['purchaseAmount'] as double).toStringAsFixed(2))),
                              DataCell(Text(order['notes'] as String)),
                              DataCell(Text(order['paymentMethod'] as String)),
                              DataCell(Text(order['invoiceType'] as String)),
                              DataCell(Text(order['inputInvoiceTime'] as String)),
                              DataCell(Text((order['shippingFee'] as double).toStringAsFixed(2))),
                              DataCell(Text(order['supplementType'] as String)),
                              DataCell(Text(order['supplementName'] as String)),
                              DataCell(Text((order['supplementAmount'] as double).toStringAsFixed(2))),
                              DataCell(Text((order['handlingFee'] as double).toStringAsFixed(2))),
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
