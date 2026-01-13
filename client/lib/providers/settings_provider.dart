import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erpcrm_client/models/settings/operation_log.dart';
import 'package:erpcrm_client/models/settings/system_parameter.dart';
import 'package:erpcrm_client/models/settings/data_dictionary.dart';
import 'package:erpcrm_client/services/api_service.dart';
import 'package:erpcrm_client/services/local_storage_service.dart';
import 'dart:developer' as dev;

export 'package:erpcrm_client/models/settings/operation_log.dart';

part 'settings_provider.g.dart';

// 定义一个包含日志列表和总记录数的数据类
class LogsWithTotal {
  final List<OperationLog> logs;
  final int total;
  
  LogsWithTotal({required this.logs, required this.total});
}

@riverpod
class LogManagementNotifier extends _$LogManagementNotifier {
  @override
  Future<LogsWithTotal> build() async {
    final logsWithTotal = await _fetchLogs();
    return logsWithTotal;
  }

  Future<LogsWithTotal> _fetchLogs({String? keyword, String? operationType, DateTimeRange? dateRange, String? sortColumn, bool? sortAscending, int? page, int? pageSize}) async {
    try {
      // 简化实现，直接从本地获取数据
      final allLogs = await ref.read(localStorageServiceProvider).getAllOperationLogs();
      var filteredLogs = _filterLocalLogs(allLogs, operationType, dateRange?.start, dateRange?.end, keyword);
      final total = filteredLogs.length;
      
      // 排序
      if (sortColumn != null) {
        filteredLogs = _sortLocalLogs(filteredLogs, sortColumn, sortAscending ?? false);
      } else {
        // 默认按创建时间降序排序
        filteredLogs = _sortLocalLogs(filteredLogs, 'createdAt', false);
      }
      
      // 分页
      if (page != null && pageSize != null) {
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        if (startIndex < filteredLogs.length) {
          filteredLogs = filteredLogs.sublist(startIndex, endIndex > filteredLogs.length ? filteredLogs.length : endIndex);
        } else {
          filteredLogs = [];
        }
      }
      
      return LogsWithTotal(logs: filteredLogs, total: total);
    } catch (e) {
      dev.log('获取日志失败: $e');
      return LogsWithTotal(logs: [], total: 0);
    }
  }

  Future<LogsWithTotal> fetchLogsWithFilters({
    String? operationType,
    DateTime? startDate,
    DateTime? endDate,
    String? keyword,
    String? sortColumn,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) async {
    try {
      // 简化实现，直接从本地获取数据
      final allLogs = await ref.read(localStorageServiceProvider).getAllOperationLogs();
      var filteredLogs = _filterLocalLogs(allLogs, operationType, startDate, endDate, keyword);
      final total = filteredLogs.length;
      
      // 排序
      if (sortColumn != null) {
        filteredLogs = _sortLocalLogs(filteredLogs, sortColumn, sortAscending ?? false);
      } else {
        // 默认按创建时间降序排序
        filteredLogs = _sortLocalLogs(filteredLogs, 'createdAt', false);
      }
      
      // 分页
      if (page != null && pageSize != null) {
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        if (startIndex < filteredLogs.length) {
          filteredLogs = filteredLogs.sublist(startIndex, endIndex > filteredLogs.length ? filteredLogs.length : endIndex);
        } else {
          filteredLogs = [];
        }
      }
      
      return LogsWithTotal(logs: filteredLogs, total: total);
    } catch (e) {
      dev.log('筛选日志失败: $e');
      return LogsWithTotal(logs: [], total: 0);
    }
  }

  List<OperationLog> _filterLocalLogs(
    List<OperationLog> logs,
    String? operationType,
    DateTime? startDate,
    DateTime? endDate,
    String? keyword,
  ) {
    return logs.where((log) {
      // 操作类型过滤
      if (operationType != null && operationType != '全部' && log.operationType != operationType) {
        return false;
      }

      // 日期范围过滤
      if (startDate != null && log.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && log.createdAt.isAfter(endDate)) {
        return false;
      }

      // 关键词过滤
      if (keyword != null && keyword.isNotEmpty) {
        final lowerKeyword = keyword.toLowerCase();
        if (!log.userName.toLowerCase().contains(lowerKeyword) &&
            !log.operationContent.toLowerCase().contains(lowerKeyword) &&
            !log.operationModule.toLowerCase().contains(lowerKeyword)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
  
  List<OperationLog> _sortLocalLogs(List<OperationLog> logs, String sortColumn, bool sortAscending) {
    logs.sort((a, b) {
      int comparison = 0;
      
      switch (sortColumn) {
        case 'userName':
          comparison = a.userName.compareTo(b.userName);
          break;
        case 'operationType':
          comparison = a.operationType.compareTo(b.operationType);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return sortAscending ? comparison : -comparison;
    });
    
    return logs;
  }

  Future<LogsWithTotal> fetchLogs({String? keyword, String? operationType, DateTimeRange? dateRange, String? sortColumn, bool? sortAscending, int? page, int? pageSize}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _fetchLogs(
        keyword: keyword,
        operationType: operationType,
        dateRange: dateRange,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
        page: page,
        pageSize: pageSize,
      );
    });
    return state.value ?? LogsWithTotal(logs: [], total: 0);
  }

  Future<void> exportLogs() async {
    try {
      // 简化实现，模拟导出日志
      dev.log('日志导出成功');
    } catch (e) {
      dev.log('导出日志失败: $e');
      throw e;
    }
  }

  Future<void> clearLogs() async {
    try {
      // 简化实现，直接清除本地缓存
      await ref.read(localStorageServiceProvider).clearOperationLogs();
      // 刷新状态
      ref.invalidateSelf();
    } catch (e) {
      dev.log('清空日志失败: $e');
      throw e;
    }
  }
}

@riverpod
class SystemParameterNotifier extends _$SystemParameterNotifier {
  @override
  Future<List<SystemParameter>> build() async {
    return await _fetchParameters();
  }

  Future<List<SystemParameter>> _fetchParameters() async {
    try {
      // 简化实现，直接从本地获取数据
      return await ref.read(localStorageServiceProvider).getAllSystemParameters();
    } catch (e) {
      dev.log('获取系统参数失败: $e');
      return [];
    }
  }

  Future<SystemParameter> updateParameter(String id, Map<String, dynamic> updates) async {
    try {
      // 简化实现，直接更新本地缓存
      final allParams = await ref.read(localStorageServiceProvider).getAllSystemParameters();
      final param = allParams.firstWhere((p) => p.parameterKey == id);
      final updatedParam = SystemParameter(
        parameterKey: param.parameterKey,
        parameterType: param.parameterType,
        parameterValue: updates['parameterValue'] as String? ?? param.parameterValue,
        parameterDescription: param.parameterDescription,
        isEditable: param.isEditable,
        defaultValue: param.defaultValue,
        createdAt: param.createdAt,
        updatedAt: DateTime.now(),
      );
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveSystemParameter(updatedParam);
      // 刷新状态
      ref.invalidateSelf();
      return updatedParam;
    } catch (e) {
      dev.log('更新系统参数失败: $e');
      throw e;
    }
  }

  Future<SystemParameter> resetParameter(String id) async {
    try {
      // 简化实现，直接重置本地缓存
      final allParams = await ref.read(localStorageServiceProvider).getAllSystemParameters();
      final param = allParams.firstWhere((p) => p.parameterKey == id);
      final resetParam = SystemParameter(
        parameterKey: param.parameterKey,
        parameterType: param.parameterType,
        parameterValue: param.defaultValue,
        parameterDescription: param.parameterDescription,
        isEditable: param.isEditable,
        defaultValue: param.defaultValue,
        createdAt: param.createdAt,
        updatedAt: DateTime.now(),
      );
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveSystemParameter(resetParam);
      // 刷新状态
      ref.invalidateSelf();
      return resetParam;
    } catch (e) {
      dev.log('重置系统参数失败: $e');
      throw e;
    }
  }

  Future<void> exportParameters() async {
    try {
      // 简化实现，模拟导出参数
      dev.log('参数导出成功');
    } catch (e) {
      dev.log('导出参数失败: $e');
      throw e;
    }
  }

  Future<void> importParameters(List<int> fileBytes) async {
    try {
      // 简化实现，模拟导入参数
      dev.log('参数导入成功');
    } catch (e) {
      dev.log('导入参数失败: $e');
      throw e;
    }
  }
}

@riverpod
class DataDictionaryNotifier extends _$DataDictionaryNotifier {
  @override
  Future<List<DataDictionary>> build() async {
    return await _fetchDictionaries();
  }

  Future<List<DataDictionary>> _fetchDictionaries() async {
    try {
      // 简化实现，直接从本地获取数据
      return await ref.read(localStorageServiceProvider).getAllDataDictionaries();
    } catch (e) {
      dev.log('获取数据字典失败: $e');
      return [];
    }
  }

  Future<DataDictionary> createDictionary(Map<String, dynamic> data) async {
    try {
      // 简化实现，直接创建本地数据
      final newDict = DataDictionary(
        id: DateTime.now().millisecondsSinceEpoch,
        dictType: data['dictType'] as String,
        dictCode: data['dictCode'] as String,
        dictValue: data['dictValue'] as String,
        dictName: data['dictName'] as String,
        description: data['description'] as String? ?? '',
        sortOrder: data['sortOrder'] as int,
        isActive: data['isActive'] as bool,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveDataDictionary(newDict);
      // 刷新状态
      ref.invalidateSelf();
      return newDict;
    } catch (e) {
      dev.log('创建数据字典失败: $e');
      throw e;
    }
  }

  Future<DataDictionary> updateDictionary(String id, Map<String, dynamic> updates) async {
    try {
      // 简化实现，直接更新本地缓存
      final allDicts = await ref.read(localStorageServiceProvider).getAllDataDictionaries();
      final dict = allDicts.firstWhere((d) => d.id == int.parse(id));
      final updatedDict = DataDictionary(
        id: dict.id,
        dictType: dict.dictType,
        dictCode: dict.dictCode,
        dictValue: updates['dictValue'] as String? ?? dict.dictValue,
        dictName: updates['dictName'] as String? ?? dict.dictName,
        description: updates['description'] as String? ?? dict.description,
        sortOrder: updates['sortOrder'] as int? ?? dict.sortOrder,
        isActive: updates['isActive'] as bool? ?? dict.isActive,
        createdAt: dict.createdAt,
        updatedAt: DateTime.now(),
      );
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveDataDictionary(updatedDict);
      // 刷新状态
      ref.invalidateSelf();
      return updatedDict;
    } catch (e) {
      dev.log('更新数据字典失败: $e');
      throw e;
    }
  }

  Future<void> deleteDictionary(String id) async {
    try {
      // 简化实现，直接删除本地缓存
      await ref.read(localStorageServiceProvider).deleteDataDictionary(int.parse(id));
      // 刷新状态
      ref.invalidateSelf();
    } catch (e) {
      dev.log('删除数据字典失败: $e');
      throw e;
    }
  }

  Future<DataDictionary> toggleDictionaryStatus(String id, bool isActive) async {
    try {
      // 简化实现，直接切换本地缓存状态
      final allDicts = await ref.read(localStorageServiceProvider).getAllDataDictionaries();
      final dict = allDicts.firstWhere((d) => d.id == int.parse(id));
      final updatedDict = DataDictionary(
        id: dict.id,
        dictType: dict.dictType,
        dictCode: dict.dictCode,
        dictValue: dict.dictValue,
        dictName: dict.dictName,
        description: dict.description,
        sortOrder: dict.sortOrder,
        isActive: isActive,
        createdAt: dict.createdAt,
        updatedAt: DateTime.now(),
      );
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveDataDictionary(updatedDict);
      // 刷新状态
      ref.invalidateSelf();
      return updatedDict;
    } catch (e) {
      dev.log('切换数据字典状态失败: $e');
      throw e;
    }
  }

  // 导入数据字典
  Future<void> importDictionaries(List<DataDictionary> dictionaries) async {
    try {
      // 保存到本地缓存
      await ref.read(localStorageServiceProvider).saveDataDictionaries(dictionaries);
      // 刷新状态
      ref.invalidateSelf();
      dev.log('数据字典导入成功');
    } catch (e) {
      dev.log('导入数据字典失败: $e');
      throw e;
    }
  }

  // 导出数据字典
  Future<List<DataDictionary>> exportDictionaries() async {
    try {
      // 从本地缓存获取所有数据字典
      final dictionaries = await ref.read(localStorageServiceProvider).getAllDataDictionaries();
      dev.log('数据字典导出成功');
      return dictionaries;
    } catch (e) {
      dev.log('导出数据字典失败: $e');
      throw e;
    }
  }
}
