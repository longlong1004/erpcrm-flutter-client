import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/railway_station.dart';

class RailwayStationState {
  final List<RailwayStation> stations;
  final bool isLoading;
  final String? error;

  const RailwayStationState({
    this.stations = const [],
    this.isLoading = false,
    this.error,
  });

  RailwayStationState copyWith({
    List<RailwayStation>? stations,
    bool? isLoading,
    String? error,
  }) {
    return RailwayStationState(
      stations: stations ?? this.stations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RailwayStationNotifier extends StateNotifier<RailwayStationState> {
  final Box railwayStationBox;

  RailwayStationNotifier(this.railwayStationBox) : super(const RailwayStationState()) {
    _loadStations();
  }

  Future<void> _loadStations() async {
    state = state.copyWith(isLoading: true);
    try {
      final stationsJson = railwayStationBox.get('railway_stations', defaultValue: <Map<String, dynamic>>[]);
      final stations = (stationsJson as List).map((json) => RailwayStation.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        stations: stations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载路局站段失败: $e',
      );
    }
  }

  Future<void> addStation(RailwayStation station) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedStations = [...state.stations, station.copyWith(id: DateTime.now().millisecondsSinceEpoch)];
      await railwayStationBox.put('railway_stations', updatedStations.map((s) => s.toJson()).toList());
      state = state.copyWith(
        stations: updatedStations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加路局站段失败: $e',
      );
    }
  }

  Future<void> updateStation(RailwayStation station) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedStations = state.stations.map((s) => s.id == station.id ? station : s).toList();
      await railwayStationBox.put('railway_stations', updatedStations.map((s) => s.toJson()).toList());
      state = state.copyWith(
        stations: updatedStations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新路局站段失败: $e',
      );
    }
  }

  Future<void> deleteStation(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedStations = state.stations.where((s) => s.id != id).toList();
      await railwayStationBox.put('railway_stations', updatedStations.map((s) => s.toJson()).toList());
      state = state.copyWith(
        stations: updatedStations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除路局站段失败: $e',
      );
    }
  }
}

final railwayStationBoxProvider = Provider<Box>((ref) {
  return Hive.box('railway_station_box');
});

final railwayStationProvider = StateNotifierProvider<RailwayStationNotifier, RailwayStationState>((ref) {
  final box = ref.watch(railwayStationBoxProvider);
  return RailwayStationNotifier(box);
});
