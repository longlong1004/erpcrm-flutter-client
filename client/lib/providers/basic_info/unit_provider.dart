import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/unit.dart';

class UnitState {
  final List<Unit> units;
  final bool isLoading;
  final String? error;

  const UnitState({
    this.units = const [],
    this.isLoading = false,
    this.error,
  });

  UnitState copyWith({
    List<Unit>? units,
    bool? isLoading,
    String? error,
  }) {
    return UnitState(
      units: units ?? this.units,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UnitNotifier extends StateNotifier<UnitState> {
  final Box unitBox;

  UnitNotifier(this.unitBox) : super(const UnitState()) {
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    state = state.copyWith(isLoading: true);
    try {
      final unitsJson = unitBox.get('units', defaultValue: <Map<String, dynamic>>[]);
      final units = (unitsJson as List).map((json) => Unit.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        units: units,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载单位信息失败: $e',
      );
    }
  }

  Future<void> addUnit(Unit unit) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedUnits = [...state.units, unit.copyWith(id: DateTime.now().millisecondsSinceEpoch)];
      await unitBox.put('units', updatedUnits.map((u) => u.toJson()).toList());
      state = state.copyWith(
        units: updatedUnits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加单位失败: $e',
      );
    }
  }

  Future<void> updateUnit(Unit unit) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedUnits = state.units.map((u) => u.id == unit.id ? unit : u).toList();
      await unitBox.put('units', updatedUnits.map((u) => u.toJson()).toList());
      state = state.copyWith(
        units: updatedUnits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新单位失败: $e',
      );
    }
  }

  Future<void> deleteUnit(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedUnits = state.units.where((u) => u.id != id).toList();
      await unitBox.put('units', updatedUnits.map((u) => u.toJson()).toList());
      state = state.copyWith(
        units: updatedUnits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除单位失败: $e',
      );
    }
  }
}

final unitBoxProvider = Provider<Box>((ref) {
  return Hive.box('unit_box');
});

final unitProvider = StateNotifierProvider<UnitNotifier, UnitState>((ref) {
  final box = ref.watch(unitBoxProvider);
  return UnitNotifier(box);
});
