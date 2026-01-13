import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/warehouse/warehouse.dart';
import 'package:erpcrm_client/services/api_service.dart';
import 'package:hive/hive.dart';

class WarehouseState {
  final bool isLoading;
  final String? errorMessage;
  final List<Warehouse> warehouses;
  final List<Inventory> inventories;
  final List<StockRecord> stockRecords;
  final bool hasFetchedWarehouses;
  final bool hasFetchedInventories;
  final bool hasFetchedStockRecords;

  WarehouseState({
    this.isLoading = false,
    this.errorMessage,
    this.warehouses = const [],
    this.inventories = const [],
    this.stockRecords = const [],
    this.hasFetchedWarehouses = false,
    this.hasFetchedInventories = false,
    this.hasFetchedStockRecords = false,
  });

  WarehouseState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Warehouse>? warehouses,
    List<Inventory>? inventories,
    List<StockRecord>? stockRecords,
    bool? hasFetchedWarehouses,
    bool? hasFetchedInventories,
    bool? hasFetchedStockRecords,
  }) {
    return WarehouseState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      warehouses: warehouses ?? this.warehouses,
      inventories: inventories ?? this.inventories,
      stockRecords: stockRecords ?? this.stockRecords,
      hasFetchedWarehouses: hasFetchedWarehouses ?? this.hasFetchedWarehouses,
      hasFetchedInventories: hasFetchedInventories ?? this.hasFetchedInventories,
      hasFetchedStockRecords: hasFetchedStockRecords ?? this.hasFetchedStockRecords,
    );
  }
}

class WarehouseNotifier extends StateNotifier<WarehouseState> {
  final ApiService _apiService;
  final Box<Warehouse> _warehouseBox;
  final Box<Inventory> _inventoryBox;
  final Box<StockRecord> _stockRecordBox;

  WarehouseNotifier(
    this._apiService,
    this._warehouseBox,
    this._inventoryBox,
    this._stockRecordBox,
  ) : super(WarehouseState());

  Future<void> loadWarehouses() async {
    if (state.hasFetchedWarehouses) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getWarehouses();

      if (result is List<dynamic>) {
        final warehouses = result
            .map((item) => Warehouse.fromJson(item as Map<String, dynamic>))
            .toList();

        await _warehouseBox.clear();
        for (final warehouse in warehouses) {
          await _warehouseBox.put(warehouse.id, warehouse);
        }

        state = state.copyWith(
          isLoading: false,
          warehouses: warehouses,
          hasFetchedWarehouses: true,
        );
      }
    } catch (e) {
      final localWarehouses = _warehouseBox.values.toList();
      state = state.copyWith(
        isLoading: false,
        warehouses: localWarehouses,
        hasFetchedWarehouses: localWarehouses.isNotEmpty,
      );
    }
  }

  Future<void> loadInventories({int? warehouseId}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getInventories(warehouseId: warehouseId);

      if (result is List<dynamic>) {
        final inventories = result
            .map((item) => Inventory.fromJson(item as Map<String, dynamic>))
            .toList();

        await _inventoryBox.clear();
        for (final inventory in inventories) {
          await _inventoryBox.put(inventory.id, inventory);
        }

        state = state.copyWith(
          isLoading: false,
          inventories: inventories,
          hasFetchedInventories: true,
        );
      }
    } catch (e) {
      final localInventories = _inventoryBox.values.toList();
      if (warehouseId != null) {
        state = state.copyWith(
          isLoading: false,
          inventories: localInventories.where((i) => i.warehouseId == warehouseId).toList(),
          hasFetchedInventories: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          inventories: localInventories,
          hasFetchedInventories: localInventories.isNotEmpty,
        );
      }
    }
  }

  Future<void> loadStockRecords({
    String? type,
    int? warehouseId,
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getStockRecords(
        type: type,
        warehouseId: warehouseId,
        startDate: startDate,
        endDate: endDate,
      );

      if (result is List<dynamic>) {
        final stockRecords = result
            .map((item) => StockRecord.fromJson(item as Map<String, dynamic>))
            .toList();

        await _stockRecordBox.clear();
        for (final record in stockRecords) {
          await _stockRecordBox.put(record.id, record);
        }

        state = state.copyWith(
          isLoading: false,
          stockRecords: stockRecords,
          hasFetchedStockRecords: true,
        );
      }
    } catch (e) {
      final localRecords = _stockRecordBox.values.toList();
      state = state.copyWith(
        isLoading: false,
        stockRecords: localRecords,
        hasFetchedStockRecords: localRecords.isNotEmpty,
      );
    }
  }

  Future<bool> createWarehouse(Warehouse warehouse) async {
    try {
      await _warehouseBox.put(warehouse.id, warehouse);
      final updatedWarehouses = [...state.warehouses, warehouse];
      state = state.copyWith(warehouses: updatedWarehouses);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateWarehouse(Warehouse warehouse) async {
    try {
      await _warehouseBox.put(warehouse.id, warehouse);
      final updatedWarehouses = state.warehouses.map((w) =>
          w.id == warehouse.id ? warehouse : w).toList();
      state = state.copyWith(warehouses: updatedWarehouses);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteWarehouse(int warehouseId) async {
    try {
      await _warehouseBox.delete(warehouseId);
      final updatedWarehouses = state.warehouses.where((w) => w.id != warehouseId).toList();
      state = state.copyWith(warehouses: updatedWarehouses);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> createStockRecord(StockRecord record) async {
    try {
      await _stockRecordBox.put(record.id, record);
      final updatedRecords = [...state.stockRecords, record];
      state = state.copyWith(stockRecords: updatedRecords);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  List<Inventory> getLowStockInventories() {
    return state.inventories.where((inv) => inv.isLowStock).toList();
  }
}

final warehouseBoxProvider = FutureProvider<Box<Warehouse>>((ref) async {
  return await Hive.openBox<Warehouse>('warehouses');
});

final inventoryBoxProvider = FutureProvider<Box<Inventory>>((ref) async {
  return await Hive.openBox<Inventory>('inventories');
});

final stockRecordBoxProvider = FutureProvider<Box<StockRecord>>((ref) async {
  return await Hive.openBox<StockRecord>('stock_records');
});

final warehouseNotifierProvider = StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final warehouseBox = ref.watch(warehouseBoxProvider).value;
  final inventoryBox = ref.watch(inventoryBoxProvider).value;
  final stockRecordBox = ref.watch(stockRecordBoxProvider).value;

  if (warehouseBox == null || inventoryBox == null || stockRecordBox == null) {
    throw Exception('Warehouse boxes not initialized');
  }

  return WarehouseNotifier(apiService, warehouseBox, inventoryBox, stockRecordBox);
});
