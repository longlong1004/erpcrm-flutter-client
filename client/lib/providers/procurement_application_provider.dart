import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/procurement/procurement_application.dart';

class ProcurementApplicationNotifier extends StateNotifier<List<ProcurementApplication>> {
  final Box procurementBox;

  ProcurementApplicationNotifier(this.procurementBox) : super([]) {
    _loadApplications();
  }

  // 从本地存储加载采购申请数据
  void _loadApplications() {
    final applicationsJson = procurementBox.get('procurement_applications') as List?;
    if (applicationsJson != null) {
      final applications = applicationsJson
          .map((json) => ProcurementApplication.fromJson(json as Map<String, dynamic>))
          .toList();
      state = applications;
    } else {
      // 添加一些默认数据用于测试
      final defaultApplications = [
        ProcurementApplication(
          id: 1,
          salesman: '张三',
          company: '国铁科技有限公司',
          materialName: '压力传感器',
          model: 'PT100',
          quantity: 10,
          unitPrice: 100.00,
          unit: '个',
          amount: 1000.00,
          status: '已批准',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ProcurementApplication(
          id: 2,
          salesman: '李四',
          company: '国铁科技有限公司',
          materialName: '温度传感器',
          model: 'TC100',
          quantity: 20,
          unitPrice: 150.00,
          unit: '个',
          amount: 3000.00,
          status: '待审批',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ProcurementApplication(
          id: 3,
          salesman: '王五',
          company: '国铁科技有限公司',
          materialName: '湿度传感器',
          model: 'HM200',
          quantity: 15,
          unitPrice: 80.00,
          unit: '个',
          amount: 1200.00,
          status: '已拒绝',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      state = defaultApplications;
      _saveApplications(defaultApplications);
    }
  }

  // 保存采购申请数据到本地存储
  void _saveApplications(List<ProcurementApplication> applications) {
    final applicationsJson = applications.map((app) => app.toJson()).toList();
    procurementBox.put('procurement_applications', applicationsJson);
    state = applications;
  }

  // 新增采购申请
  void addApplication(ProcurementApplication application) {
    final updatedApplications = [...state, application];
    _saveApplications(updatedApplications);
  }

  // 撤回采购申请
  void withdrawApplication(int id) {
    final updatedApplications = state.map((application) {
      if (application.id == id) {
        return ProcurementApplication(
          id: application.id,
          salesman: application.salesman,
          company: application.company,
          materialName: application.materialName,
          model: application.model,
          quantity: application.quantity,
          unitPrice: application.unitPrice,
          unit: application.unit,
          amount: application.amount,
          status: '已撤回',
          createdAt: application.createdAt,
        );
      }
      return application;
    }).toList();
    _saveApplications(updatedApplications);
  }

  // 获取单个采购申请详情
  ProcurementApplication? getApplicationById(int id) {
    try {
      return state.firstWhere((application) => application.id == id);
    } catch (e) {
      return null;
    }
  }
}

// 创建采购申请的Provider
final procurementApplicationProvider = StateNotifierProvider<ProcurementApplicationNotifier, List<ProcurementApplication>>((ref) {
  final procurementBox = Hive.box('procurement_box');
  return ProcurementApplicationNotifier(procurementBox);
});
