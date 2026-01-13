import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/category.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final Box categoryBox;

  CategoryNotifier(this.categoryBox) : super(const CategoryState()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      var categoriesJson = categoryBox.get('categories', defaultValue: <Map<String, dynamic>>[]);
      
      // 如果本地没有数据，生成示例数据
      if ((categoriesJson as List).isEmpty) {
        categoriesJson = _generateSampleCategories();
        await categoryBox.put('categories', categoriesJson);
      }
      
      final categories = (categoriesJson as List).map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载分类信息失败: $e',
      );
    }
  }
  
  // 生成示例分类数据
  List<Map<String, dynamic>> _generateSampleCategories() {
    final now = DateTime.now();
    return [
      {
        'id': 1,
        'name': '【分类示例1】铁路设备',
        'companyName': '北京铁路设备有限公司',
        'parentId': null,
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 2,
        'name': '【分类示例2】信号设备',
        'companyName': '北京铁路设备有限公司',
        'parentId': '1',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 3,
        'name': '【分类示例3】通信设备',
        'companyName': '北京铁路设备有限公司',
        'parentId': '1',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 4,
        'name': '【分类示例4】轨道设备',
        'companyName': '北京铁路设备有限公司',
        'parentId': '1',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 5,
        'name': '【分类示例5】机车车辆',
        'companyName': '上海轨道交通股份有限公司',
        'parentId': null,
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 6,
        'name': '【分类示例6】高速列车',
        'companyName': '上海轨道交通股份有限公司',
        'parentId': '5',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 7,
        'name': '【分类示例7】普通列车',
        'companyName': '上海轨道交通股份有限公司',
        'parentId': '5',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 8,
        'name': '【分类示例8】地铁车辆',
        'companyName': '上海轨道交通股份有限公司',
        'parentId': '5',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 9,
        'name': '【分类示例9】物流设备',
        'companyName': '广州铁路集团有限公司',
        'parentId': null,
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 10,
        'name': '【分类示例10】集装箱',
        'companyName': '广州铁路集团有限公司',
        'parentId': '9',
        'createdAt': now.toIso8601String(),
      },
    ];
  }

  Future<void> addCategory(Category category) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedCategories = <Category>[...state.categories, category.copyWith(id: DateTime.now().millisecondsSinceEpoch)];
      await categoryBox.put('categories', updatedCategories.map((c) => c.toJson()).toList());
      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加分类信息失败: $e',
      );
    }
  }

  Future<void> updateCategory(Category category) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedCategories = <Category>[];
      for (var c in state.categories) {
        if (c.id == category.id) {
          updatedCategories.add(category);
        } else {
          updatedCategories.add(c);
        }
      }
      await categoryBox.put('categories', updatedCategories.map((c) => c.toJson()).toList());
      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新分类信息失败: $e',
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedCategories = <Category>[];
      for (var c in state.categories) {
        if (c.id != id) {
          updatedCategories.add(c);
        }
      }
      await categoryBox.put('categories', updatedCategories.map((c) => c.toJson()).toList());
      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除分类信息失败: $e',
      );
    }
  }
}

final categoryBoxProvider = Provider<Box>((ref) {
  return Hive.box('category_box');
});

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final box = ref.watch(categoryBoxProvider);
  return CategoryNotifier(box);
});
