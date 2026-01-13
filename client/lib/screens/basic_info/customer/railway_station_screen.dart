import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/railway_station.dart';
import 'package:erpcrm_client/providers/basic_info/railway_station_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class RailwayStationScreen extends ConsumerWidget {
  const RailwayStationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationState = ref.watch(railwayStationProvider);
    final stations = stationState.stations;

    return MainLayout(
      title: '路局站段',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '路局站段',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增路局站段操作
                    _showStationDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('序号')),
                    DataColumn(label: Text('路局')),
                    DataColumn(label: Text('站段')),
                    DataColumn(label: Text('未下单天数')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: stations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final station = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(station.railwayBureau)),
                      DataCell(Text(station.station)),
                      DataCell(Text('${station.daysWithoutOrder ?? 0}')),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showStationDetail(context, station);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              _showStationDialog(context, ref, station: station);
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteConfirm(context, ref, station);
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStationDetail(BuildContext context, RailwayStation station) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('路局站段详情'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('路局', station.railwayBureau),
                _buildDetailRow('站段', station.station),
                _buildDetailRow('未下单天数', '${station.daysWithoutOrder ?? 0}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStationDialog(BuildContext context, WidgetRef ref, {RailwayStation? station}) {
    final formKey = GlobalKey<FormState>();
    final railwayBureauController = TextEditingController(text: station?.railwayBureau ?? '');
    final stationController = TextEditingController(text: station?.station ?? '');
    final daysWithoutOrderController = TextEditingController(text: station?.daysWithoutOrder?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(station == null ? '新增路局站段' : '编辑路局站段'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: railwayBureauController,
                    decoration: const InputDecoration(labelText: '路局'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入路局';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: stationController,
                    decoration: const InputDecoration(labelText: '站段'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入站段';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: daysWithoutOrderController,
                    decoration: const InputDecoration(labelText: '未下单天数'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final days = int.tryParse(value);
                        if (days == null || days < 0) {
                          return '请输入有效的天数';
                        }
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
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newStation = RailwayStation(
                    id: station?.id,
                    railwayBureau: railwayBureauController.text,
                    station: stationController.text,
                    daysWithoutOrder: daysWithoutOrderController.text.isEmpty 
                        ? null 
                        : int.parse(daysWithoutOrderController.text),
                  );

                  if (station == null) {
                    ref.read(railwayStationProvider.notifier).addStation(newStation);
                  } else {
                    ref.read(railwayStationProvider.notifier).updateStation(newStation);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, RailwayStation station) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除路局站段 "${station.railwayBureau} - ${station.station}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(railwayStationProvider.notifier).deleteStation(station.id!);
                Navigator.pop(context);
              },
              child: const Text('删除'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}