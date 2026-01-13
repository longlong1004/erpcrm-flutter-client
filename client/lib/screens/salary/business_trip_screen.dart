import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/models/salary/business_trip.dart';
import 'package:erpcrm_client/providers/business_trip_provider.dart';

class BusinessTripScreen extends ConsumerWidget {
  const BusinessTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(businessTripProvider);
    final tripList = tripState.businessTripList;
    final isLoading = tripState.status == BusinessTripStatus.loading;

    return MainLayout(
      title: '出差',
      topContent: const SalaryMenu(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '出差',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showApplyBusinessTripDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('申请'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(businessTripProvider.notifier).refreshBusinessTripList();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('业务员')),
                            DataColumn(label: Text('状态')),
                            DataColumn(label: Text('出差时间')),
                            DataColumn(label: Text('出差站段')),
                            DataColumn(label: Text('出差地点')),
                            DataColumn(label: Text('操作')),
                          ],
                          rows: tripList.map((trip) {
                            return DataRow(cells: [
                              DataCell(Text(trip.employeeName)),
                              DataCell(
                                Chip(
                                  label: Text(_getStatusLabel(trip.status)),
                                  backgroundColor: _getStatusColor(trip.status),
                                  labelStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(Text('${trip.startTime.toString().substring(0, 16)} - ${trip.endTime.toString().substring(0, 16)}')),
                              DataCell(Text(trip.railwayStation)),
                              DataCell(Text(trip.location)),
                              DataCell(Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _showBusinessTripDetailDialog(context, trip);
                                    },
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _showWithdrawConfirmDialog(context, ref, trip.id!);
                                    },
                                    child: const Text('撤回'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _showDeleteConfirmDialog(context, ref, trip.id!);
                                    },
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyBusinessTripDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final railwayStationController = TextEditingController();
    final locationController = TextEditingController();
    final purposeController = TextEditingController();

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    startTimeController.text = now.toString().substring(0, 16);
    endTimeController.text = tomorrow.toString().substring(0, 16);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('申请出差'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: employeeNameController,
                    decoration: const InputDecoration(labelText: '业务员'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入业务员姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: startTimeController,
                    decoration: const InputDecoration(labelText: '开始时间'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          startTimeController.text = dateTime.toString().substring(0, 16);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: endTimeController,
                    decoration: const InputDecoration(labelText: '结束时间'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tomorrow,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          endTimeController.text = dateTime.toString().substring(0, 16);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: railwayStationController,
                    decoration: const InputDecoration(labelText: '出差站段'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入出差站段';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: '出差地点'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入出差地点';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: purposeController,
                    decoration: const InputDecoration(labelText: '出差事由'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入出差事由';
                      }
                      return null;
                    },
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
                if (formKey.currentState?.validate() ?? false) {
                  final trip = BusinessTrip(
                    employeeName: employeeNameController.text,
                    status: '待审核',
                    startTime: DateTime.parse(startTimeController.text),
                    endTime: DateTime.parse(endTimeController.text),
                    railwayStation: railwayStationController.text,
                    location: locationController.text,
                    purpose: purposeController.text,
                  );
                  ref.read(businessTripProvider.notifier).createBusinessTrip(trip);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('提交申请'),
            ),
          ],
        );
      },
    );
  }

  void _showBusinessTripDetailDialog(BuildContext context, BusinessTrip trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('出差详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('业务员', trip.employeeName),
                _buildDetailItem('状态', _getStatusLabel(trip.status)),
                _buildDetailItem('出差地点', trip.location),
                _buildDetailItem('开始时间', trip.startTime.toString()),
                _buildDetailItem('结束时间', trip.endTime.toString()),
                _buildDetailItem('出差站段', trip.railwayStation),
                _buildDetailItem('出差事由', trip.purpose),
                _buildDetailItem('审批意见', trip.approvalComment ?? '-'),
                _buildDetailItem('创建时间', trip.createdAt.toString()),
                _buildDetailItem('更新时间', trip.updatedAt.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawConfirmDialog(BuildContext context, WidgetRef ref, int tripId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认撤回'),
          content: const Text('确定要撤回这条出差申请吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(businessTripProvider.notifier).withdrawBusinessTrip(tripId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('撤回'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int tripId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条出差申请吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(businessTripProvider.notifier).deleteBusinessTrip(tripId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case '待审核':
        return '待审核';
      case '已通过':
        return '已通过';
      case '已拒绝':
        return '已拒绝';
      case '已撤回':
        return '已撤回';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return Colors.yellow;
      case '已通过':
        return Colors.green;
      case '已拒绝':
        return Colors.red;
      case '已撤回':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}