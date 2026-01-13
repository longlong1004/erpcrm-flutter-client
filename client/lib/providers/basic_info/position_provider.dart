import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/position.dart';
import 'package:erpcrm_client/services/api_service.dart';

class PositionState {
  final List<Position> positions;
  final bool isLoading;
  final String? error;

  const PositionState({
    this.positions = const [],
    this.isLoading = false,
    this.error,
  });

  PositionState copyWith({
    List<Position>? positions,
    bool? isLoading,
    String? error,
  }) {
    return PositionState(
      positions: positions ?? this.positions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PositionNotifier extends StateNotifier<PositionState> {
  final Box positionBox;
  final ApiService apiService;

  PositionNotifier(this.positionBox, this.apiService) : super(const PositionState()) {
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    state = state.copyWith(isLoading: true);
    try {
      // 尝试从API获取数据
      final positionsData = await apiService.getPositions();
      final positions = positionsData.map((data) => Position.fromJson(data as Map<String, dynamic>)).toList();
      
      // 将数据同步到本地Hive
      await positionBox.put('positions', positions.map((p) => p.toJson()).toList());
      
      state = state.copyWith(
        positions: positions,
        isLoading: false,
      );
    } catch (e) {
      // API调用失败，从本地Hive读取数据
      print('从API获取职位信息失败，尝试从本地读取: $e');
      try {
        final positionsJson = positionBox.get('positions', defaultValue: <Map<String, dynamic>>[]);
        final positions = (positionsJson as List).map((json) => Position.fromJson(json as Map<String, dynamic>)).toList();
        state = state.copyWith(
          positions: positions,
          isLoading: false,
        );
      } catch (hiveError) {
        state = state.copyWith(
          isLoading: false,
          error: '加载职位信息失败: $hiveError',
        );
      }
    }
  }

  Future<void> addPosition(Position position) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API创建职位
      final createdPositionData = await apiService.createPosition(position.toJson());
      final createdPosition = Position.fromJson(createdPositionData);
      
      // 更新本地Hive数据
      final updatedPositions = <Position>[...state.positions, createdPosition];
      await positionBox.put('positions', updatedPositions.map((p) => p.toJson()).toList());
      
      state = state.copyWith(
        positions: updatedPositions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加职位信息失败: $e',
      );
    }
  }

  Future<void> updatePosition(Position position) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API更新职位
      final updatedPositionData = await apiService.updatePosition(position.id.toString(), position.toJson());
      final updatedPosition = Position.fromJson(updatedPositionData);
      
      // 更新本地Hive数据
      final updatedPositions = <Position>[];
      for (var p in state.positions) {
        if (p.id == position.id) {
          updatedPositions.add(updatedPosition);
        } else {
          updatedPositions.add(p);
        }
      }
      await positionBox.put('positions', updatedPositions.map((p) => p.toJson()).toList());
      
      state = state.copyWith(
        positions: updatedPositions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新职位信息失败: $e',
      );
    }
  }

  Future<void> deletePosition(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API删除职位
      await apiService.deletePosition(id.toString());
      
      // 更新本地Hive数据
      final updatedPositions = <Position>[];
      for (var p in state.positions) {
        if (p.id != id) {
          updatedPositions.add(p);
        }
      }
      await positionBox.put('positions', updatedPositions.map((p) => p.toJson()).toList());
      
      state = state.copyWith(
        positions: updatedPositions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除职位信息失败: $e',
      );
    }
  }
}

final positionBoxProvider = Provider<Box>((ref) {
  return Hive.box('position_box');
});

final positionProvider = StateNotifierProvider<PositionNotifier, PositionState>((ref) {
  final box = ref.watch(positionBoxProvider);
  final apiService = ref.watch(apiServiceProvider);
  return PositionNotifier(box, apiService);
});
