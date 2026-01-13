import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/supplier_info.dart';

class SupplierInfoState {
  final List<SupplierInfo> suppliers;
  final bool isLoading;
  final String? error;

  const SupplierInfoState({
    this.suppliers = const [],
    this.isLoading = false,
    this.error,
  });

  SupplierInfoState copyWith({
    List<SupplierInfo>? suppliers,
    bool? isLoading,
    String? error,
  }) {
    return SupplierInfoState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SupplierInfoNotifier extends StateNotifier<SupplierInfoState> {
  final Box supplierInfoBox;

  SupplierInfoNotifier(this.supplierInfoBox) : super(const SupplierInfoState()) {
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    state = state.copyWith(isLoading: true);
    try {
      final suppliersJson = supplierInfoBox.get('supplier_infos', defaultValue: <Map<String, dynamic>>[]);
      final suppliers = (suppliersJson as List).map((json) => SupplierInfo.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        suppliers: suppliers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载供应商信息失败: $e',
      );
    }
  }

  Future<void> addSupplier(SupplierInfo supplier) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedSuppliers = [...state.suppliers, supplier.copyWith(id: DateTime.now().millisecondsSinceEpoch)];
      await supplierInfoBox.put('supplier_infos', updatedSuppliers.map((s) => s.toJson()).toList());
      state = state.copyWith(
        suppliers: updatedSuppliers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加供应商信息失败: $e',
      );
    }
  }

  Future<void> updateSupplier(SupplierInfo supplier) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedSuppliers = state.suppliers.map((s) => s.id == supplier.id ? supplier : s).toList();
      await supplierInfoBox.put('supplier_infos', updatedSuppliers.map((s) => s.toJson()).toList());
      state = state.copyWith(
        suppliers: updatedSuppliers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新供应商信息失败: $e',
      );
    }
  }

  Future<void> deleteSupplier(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedSuppliers = state.suppliers.where((s) => s.id != id).toList();
      await supplierInfoBox.put('supplier_infos', updatedSuppliers.map((s) => s.toJson()).toList());
      state = state.copyWith(
        suppliers: updatedSuppliers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除供应商信息失败: $e',
      );
    }
  }
}

final supplierInfoBoxProvider = Provider<Box>((ref) {
  return Hive.box('supplier_info_box');
});

final supplierInfoProvider = StateNotifierProvider<SupplierInfoNotifier, SupplierInfoState>((ref) {
  final box = ref.watch(supplierInfoBoxProvider);
  return SupplierInfoNotifier(box);
});
