import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/tax_category.dart';

class TaxCategoryState {
  final List<TaxCategory> taxCategories;
  final bool isLoading;
  final String? error;

  const TaxCategoryState({
    this.taxCategories = const [],
    this.isLoading = false,
    this.error,
  });

  TaxCategoryState copyWith({
    List<TaxCategory>? taxCategories,
    bool? isLoading,
    String? error,
  }) {
    return TaxCategoryState(
      taxCategories: taxCategories ?? this.taxCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TaxCategoryNotifier extends StateNotifier<TaxCategoryState> {
  final Box taxCategoryBox;

  TaxCategoryNotifier(this.taxCategoryBox) : super(const TaxCategoryState()) {
    _loadTaxCategories();
  }

  Future<void> _loadTaxCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      final taxCategoriesJson = taxCategoryBox.get('tax_categories', defaultValue: <Map<String, dynamic>>[]);
      final taxCategories = (taxCategoriesJson as List).map((json) => TaxCategory.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        taxCategories: taxCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载税收分类信息失败: $e',
      );
    }
  }

  Future<void> addTaxCategory(TaxCategory taxCategory) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTaxCategories = <TaxCategory>[...state.taxCategories, taxCategory.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )];
      await taxCategoryBox.put('tax_categories', updatedTaxCategories.map((t) => t.toJson()).toList());
      state = state.copyWith(
        taxCategories: updatedTaxCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加税收分类信息失败: $e',
      );
    }
  }

  Future<void> updateTaxCategory(TaxCategory taxCategory) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTaxCategories = <TaxCategory>[];
      for (var t in state.taxCategories) {
        if (t.id == taxCategory.id) {
          updatedTaxCategories.add(taxCategory.copyWith(updatedAt: DateTime.now()));
        } else {
          updatedTaxCategories.add(t);
        }
      }
      await taxCategoryBox.put('tax_categories', updatedTaxCategories.map((t) => t.toJson()).toList());
      state = state.copyWith(
        taxCategories: updatedTaxCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新税收分类信息失败: $e',
      );
    }
  }

  Future<void> deleteTaxCategory(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTaxCategories = <TaxCategory>[];
      for (var t in state.taxCategories) {
        if (t.id != id) {
          updatedTaxCategories.add(t);
        }
      }
      await taxCategoryBox.put('tax_categories', updatedTaxCategories.map((t) => t.toJson()).toList());
      state = state.copyWith(
        taxCategories: updatedTaxCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除税收分类信息失败: $e',
      );
    }
  }
}

final taxCategoryBoxProvider = Provider<Box>((ref) {
  return Hive.box('tax_category_box');
});

final taxCategoryProvider = StateNotifierProvider<TaxCategoryNotifier, TaxCategoryState>((ref) {
  final box = ref.watch(taxCategoryBoxProvider);
  return TaxCategoryNotifier(box);
});
