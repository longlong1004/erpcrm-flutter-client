import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 哈希服务，用于计算数据的哈希值，优化数据同步
class HashService {
  static final HashService _instance = HashService._internal();
  factory HashService() => _instance;
  HashService._internal();

  /// 计算数据的SHA-256哈希值
  String calculateHash(dynamic data) {
    if (data == null) {
      return _sha256('null');
    }

    if (data is String) {
      return _sha256(data);
    }

    if (data is Map || data is List) {
      // 转换为排序后的JSON字符串，确保相同数据生成相同哈希值
      final jsonString = _getSortedJsonString(data);
      return _sha256(jsonString);
    }

    if (data is num || data is bool) {
      return _sha256(data.toString());
    }

    // 其他类型转换为字符串
    return _sha256(data.toString());
  }

  /// 计算字符串的SHA-256哈希值
  String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 将数据转换为排序后的JSON字符串
  String _getSortedJsonString(dynamic data) {
    if (data is Map) {
      // 对Map的键进行排序
      final sortedMap = <String, dynamic>{};
      final keys = data.keys.toList()..sort();
      for (final key in keys) {
        sortedMap[key] = data[key];
      }
      return json.encode(sortedMap);
    } else if (data is List) {
      // 对List中的每个元素递归处理
      final sortedList = data.map((item) => _getSortedJsonString(item)).toList();
      return json.encode(sortedList);
    }
    return json.encode(data);
  }

  /// 比较两个数据的哈希值是否相同
  bool compareHashes(dynamic data1, dynamic data2) {
    final hash1 = calculateHash(data1);
    final hash2 = calculateHash(data2);
    return hash1 == hash2;
  }

  /// 批量计算数据的哈希值
  Map<String, String> calculateHashes(Map<String, dynamic> dataMap) {
    final hashes = <String, String>{};
    dataMap.forEach((key, value) {
      hashes[key] = calculateHash(value);
    });
    return hashes;
  }

  /// 比较两组哈希值，返回差异的键
  Set<String> compareHashMaps(Map<String, String> hashMap1, Map<String, String> hashMap2) {
    final differences = <String>{};
    
    // 检查hashMap1中存在但hashMap2中不存在或值不同的键
    for (final key in hashMap1.keys) {
      if (!hashMap2.containsKey(key) || hashMap1[key] != hashMap2[key]) {
        differences.add(key);
      }
    }
    
    // 检查hashMap2中存在但hashMap1中不存在的键
    for (final key in hashMap2.keys) {
      if (!hashMap1.containsKey(key)) {
        differences.add(key);
      }
    }
    
    return differences;
  }
}

/// 哈希服务提供者
final hashServiceProvider = Provider<HashService>((ref) => HashService());
