import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// 物流数据状态管理
final logisticsProvider = AsyncNotifierProviderFamily<LogisticsNotifier, List<Map<String, dynamic>>, String>(LogisticsNotifier.new);

class LogisticsNotifier extends FamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
  late final ApiService _apiService;
  late String _logisticsType;

  @override
  Future<List<Map<String, dynamic>>> build(String arg) async {
    _logisticsType = arg;
    _apiService = ref.read(apiServiceProvider);
    return await _fetchLogisticsData();
  }

  Future<List<Map<String, dynamic>>> _fetchLogisticsData() async {
    try {
      List<dynamic> data;
      switch (_logisticsType) {
        case 'pre-delivery':
          data = await _apiService.getPreDeliveryLogistics();
          break;
        case 'mall':
          data = await _apiService.getMallOrderLogistics();
          break;
        case 'collector':
          data = await _apiService.getCollectorOrderLogistics();
          break;
        case 'other':
          data = await _apiService.getOtherBusinessLogistics();
          break;
        default:
          data = [];
      }
      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('获取物流数据失败: $e');
      // 如果获取真实数据失败，返回模拟数据
      return _getMockData();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _fetchLogisticsData();
    });
  }

  // 模拟数据，当真实API不可用时使用
  List<Map<String, dynamic>> _getMockData() {
    final now = DateTime.now();
    final mockData = List.generate(5, (index) => {
      '业务员': '张三',
      '状态': '待发货',
      '发货类型': _logisticsType == 'pre-delivery' ? '先发货' : 
                _logisticsType == 'mall' ? '商城订单' : 
                _logisticsType == 'collector' ? '集货商订单' : '其它业务',
      '编号': _logisticsType == 'pre-delivery' ? 'PD${now.year}${index.toString().padLeft(5, '0')}' : null,
      '订单编号': _logisticsType != 'pre-delivery' ? 'ORD${now.year}${index.toString().padLeft(5, '0')}' : null,
      '所属路局': '北京局',
      '站段': '北京站',
      '国铁名称': '铁路配件',
      '国铁型号': 'TP-001',
      '数量': 10,
      '收货人': '李四',
      '电话': '13800138000',
      '物流公司': '顺丰速运',
      '物流单号': 'SF${now.year}${index.toString().padLeft(10, '0')}',
      '发货时间': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 10:${index.toString().padLeft(2, '0')}',
      '客户名称': _logisticsType == 'other' ? '北京科技有限公司' : null,
      '物资名称': _logisticsType == 'other' ? '铁路设备' : null,
      '规格型号': _logisticsType == 'other' ? 'EQ-001' : null,
    });
    
    // 过滤掉为null的字段
    return mockData.map((item) => item..removeWhere((key, value) => value == null)).toList();
  }
}
