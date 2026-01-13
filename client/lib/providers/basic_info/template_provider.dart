import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/template.dart';

class TemplateState {
  final List<Template> templates;
  final bool isLoading;
  final String? error;

  const TemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  TemplateState copyWith({
    List<Template>? templates,
    bool? isLoading,
    String? error,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TemplateNotifier extends StateNotifier<TemplateState> {
  final Box templateBox;

  TemplateNotifier(this.templateBox) : super(const TemplateState()) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    state = state.copyWith(isLoading: true);
    try {
      final templatesJson = templateBox.get('templates', defaultValue: <Map<String, dynamic>>[]);
      final templates = (templatesJson as List).map((json) => Template.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        templates: templates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载模板信息失败: $e',
      );
    }
  }

  Future<void> addTemplate(Template template) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTemplates = <Template>[...state.templates, template.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )];
      await templateBox.put('templates', updatedTemplates.map((t) => t.toJson()).toList());
      state = state.copyWith(
        templates: updatedTemplates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加模板信息失败: $e',
      );
    }
  }

  Future<void> updateTemplate(Template template) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTemplates = <Template>[];
      for (var t in state.templates) {
        if (t.id == template.id) {
          updatedTemplates.add(template.copyWith(updatedAt: DateTime.now()));
        } else {
          updatedTemplates.add(t);
        }
      }
      await templateBox.put('templates', updatedTemplates.map((t) => t.toJson()).toList());
      state = state.copyWith(
        templates: updatedTemplates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新模板信息失败: $e',
      );
    }
  }

  Future<void> deleteTemplate(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedTemplates = <Template>[];
      for (var t in state.templates) {
        if (t.id != id) {
          updatedTemplates.add(t);
        }
      }
      await templateBox.put('templates', updatedTemplates.map((t) => t.toJson()).toList());
      state = state.copyWith(
        templates: updatedTemplates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除模板信息失败: $e',
      );
    }
  }
}

final templateBoxProvider = Provider<Box>((ref) {
  return Hive.box('template_box');
});

final templateProvider = StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  final box = ref.watch(templateBoxProvider);
  return TemplateNotifier(box);
});
