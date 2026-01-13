import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';

import '../models/product/product.dart';
import '../models/order/order.dart';
import '../models/crm/customer.dart';
import '../models/crm/customer_category.dart';
import '../models/crm/customer_tag.dart';
import '../models/crm/customer_contact_log.dart';
import '../models/crm/sales_opportunity.dart';
import '../models/crm/contact_record.dart';
import '../models/business/business.dart';
import '../models/settings/operation_log.dart';
import '../models/settings/system_parameter.dart';
import '../models/settings/data_dictionary.dart';
import '../models/approval/approval.dart';
import '../models/agent/agent_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './app_database.dart';

/// 审批相关的本地存储操作
late Box<Approval> _approvalsBox;

/// 智能体相关的本地存储操作
late Box<Agent> _agentsBox;
late Box<AgentConfig> _agentConfigBox;

/// 本地存储服务，用于处理离线数据存储和同步
class LocalStorageService {
  // 单例模式
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // 初始化标记
  bool _isInitialized = false;

  // Drift数据库实例
  late AppDatabase _database;

  /// 初始化本地存储服务
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // 初始化简化的数据库服务
      _database = AppDatabase();
      await _database.init();
      
      // 打开Hive Boxes
      _logisticsDeliveryBox = await Hive.openBox<Map<String, dynamic>>('logisticsDeliveryBox');
      _operationLogBox = await Hive.openBox<OperationLog>('operationLogBox');
      _systemParameterBox = await Hive.openBox<SystemParameter>('systemParameterBox');
      _dataDictionaryBox = await Hive.openBox<DataDictionary>('dataDictionaryBox');
      _approvalsBox = await Hive.openBox<Approval>('approvalsBox');
      _agentsBox = await Hive.openBox<Agent>('agentsBox');
      _agentConfigBox = await Hive.openBox<AgentConfig>('agentConfigBox');
      
      _isInitialized = true;
      print('本地存储服务初始化成功');
    } catch (e) {
      print('本地存储服务初始化失败: $e');
      // 初始化失败，设置一个标志，后续操作会返回默认值
      _isInitialized = false;
      rethrow;
    }
  }

  // 私有方法：确保数据库已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        await init();
        _isInitialized = true;
      } catch (e) {
        print('初始化本地存储失败: $e');
        _isInitialized = false;
        // 初始化失败时，抛出异常，让调用者知道
        rethrow;
      }
    }
  }

  // Product 相关操作
  Future<void> saveProducts(List<Product> products) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      for (var product in products) {
        await _database.insertProduct(product);
      }
    } catch (e) {
      print('保存产品数据失败: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    await _ensureInitialized();
    if (!_isInitialized) return [];
    
    try {
      return await _database.getAllProducts();
    } catch (e) {
      print('获取产品数据失败: $e');
      return [];
    }
  }

  Future<Product?> getProductById(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return null;
    
    try {
      return await _database.getProductById(id);
    } catch (e) {
      print('获取单个产品数据失败: $e');
      return null;
    }
  }

  Future<void> deleteProduct(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _database.deleteProduct(id);
    } catch (e) {
      print('删除产品数据失败: $e');
    }
  }

  Future<void> saveProduct(Product product) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _database.insertProduct(product);
    } catch (e) {
      print('保存单个产品数据失败: $e');
    }
  }

  Future<void> clearProducts() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      // 清除所有产品数据
      await _database.clearProducts();
    } catch (e) {
      print('清除产品数据失败: $e');
    }
  }

  // Order 相关操作
  Future<void> saveOrders(List<Order> orders) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      for (var order in orders) {
        await _database.insertOrder(order);
      }
    } catch (e) {
      print('保存订单数据失败: $e');
    }
  }

  Future<List<Order>> getOrders() async {
    await _ensureInitialized();
    if (!_isInitialized) return [];
    
    try {
      return await _database.getAllOrders();
    } catch (e) {
      print('获取订单数据失败: $e');
      return [];
    }
  }

  Future<Order?> getOrderById(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return null;
    
    try {
      return await _database.getOrderById(id);
    } catch (e) {
      print('获取单个订单数据失败: $e');
      return null;
    }
  }

  Future<void> deleteOrder(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _database.deleteOrder(id);
    } catch (e) {
      print('删除订单数据失败: $e');
    }
  }

  Future<void> clearOrders() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      // 清除所有订单数据
      await _database.clearOrders();
    } catch (e) {
      print('清除订单数据失败: $e');
    }
  }

  // Customer 相关操作
  Future<void> saveCustomers(List<Customer> customers) async {
    for (var customer in customers) {
      await _database.insertCustomer(customer);
    }
  }

  Future<List<Customer>> getCustomers() async {
    return await _database.getAllCustomers();
  }

  Future<Customer?> getCustomerById(int customerId) async {
    return await _database.getCustomerById(customerId);
  }

  Future<void> deleteCustomer(int customerId) async {
    await _database.deleteCustomer(customerId);
  }

  Future<void> clearCustomers() async {
    // 清除所有客户数据
    await _database.clearCustomers();
  }

  // Customer Category 相关操作
  Future<void> saveCustomerCategories(List<CustomerCategory> categories) async {
    for (var category in categories) {
      await _database.insertCustomerCategory(category);
    }
  }

  Future<List<CustomerCategory>> getCustomerCategories() async {
    return await _database.getAllCustomerCategories();
  }

  Future<CustomerCategory?> getCustomerCategoryById(int categoryId) async {
    return await _database.getCustomerCategoryById(categoryId);
  }

  Future<void> deleteCustomerCategory(int categoryId) async {
    await _database.deleteCustomerCategory(categoryId);
  }

  Future<void> clearCustomerCategories() async {
    // 清除所有客户分类数据
    await _database.clearCustomerCategories();
  }

  // Customer Tag 相关操作
  Future<void> saveCustomerTags(List<CustomerTag> tags) async {
    for (var tag in tags) {
      await _database.insertCustomerTag(tag);
    }
  }

  Future<List<CustomerTag>> getCustomerTags() async {
    return await _database.getAllCustomerTags();
  }

  Future<CustomerTag?> getCustomerTagById(int tagId) async {
    return await _database.getCustomerTagById(tagId);
  }

  Future<void> deleteCustomerTag(int tagId) async {
    await _database.deleteCustomerTag(tagId);
  }

  Future<void> clearCustomerTags() async {
    // 清除所有客户标签数据
    await _database.clearCustomerTags();
  }

  // Customer Contact Log 相关操作
  Future<void> saveCustomerContactLogs(List<CustomerContactLog> logs) async {
    for (var log in logs) {
      await _database.insertCustomerContactLog(log);
    }
  }

  Future<List<CustomerContactLog>> getCustomerContactLogs() async {
    return await _database.getAllCustomerContactLogs();
  }

  Future<List<CustomerContactLog>> getCustomerContactLogsByCustomerId(int customerId) async {
    return await _database.getCustomerContactLogsByCustomerId(customerId);
  }

  Future<CustomerContactLog?> getCustomerContactLogById(int logId) async {
    return await _database.getCustomerContactLogById(logId);
  }

  Future<void> deleteCustomerContactLog(int logId) async {
    await _database.deleteCustomerContactLog(logId);
  }

  Future<void> clearCustomerContactLogs() async {
    // 清除所有客户联系日志数据
    await _database.clearCustomerContactLogs();
  }

  // Sales Opportunity 相关操作
  Future<void> saveSalesOpportunities(List<SalesOpportunity> opportunities) async {
    for (var opportunity in opportunities) {
      await _database.insertSalesOpportunity(opportunity);
    }
  }

  Future<List<SalesOpportunity>> getSalesOpportunities() async {
    return await _database.getAllSalesOpportunities();
  }

  Future<List<SalesOpportunity>> getSalesOpportunitiesByCustomerId(int customerId) async {
    return await _database.getSalesOpportunitiesByCustomerId(customerId);
  }

  Future<SalesOpportunity?> getSalesOpportunityById(int opportunityId) async {
    return await _database.getSalesOpportunityById(opportunityId);
  }

  Future<void> deleteSalesOpportunity(int opportunityId) async {
    await _database.deleteSalesOpportunity(opportunityId);
  }

  Future<void> clearSalesOpportunities() async {
    // 清除所有销售机会数据
    await _database.clearSalesOpportunities();
  }

  // Contact Record 相关操作
  Future<void> saveContactRecords(List<ContactRecord> records) async {
    for (var record in records) {
      await _database.insertContactRecord(record);
    }
  }

  Future<List<ContactRecord>> getContactRecords() async {
    return await _database.getAllContactRecords();
  }

  Future<List<ContactRecord>> getContactRecordsByCustomerId(int customerId) async {
    return await _database.getContactRecordsByCustomerId(customerId);
  }

  Future<ContactRecord?> getContactRecordById(int recordId) async {
    return await _database.getContactRecordById(recordId);
  }

  Future<void> deleteContactRecord(int recordId) async {
    await _database.deleteContactRecord(recordId);
  }

  Future<void> clearContactRecords() async {
    // 清除所有联系记录数据
    await _database.clearContactRecords();
  }

  // Business 相关操作
  Future<void> saveBusinesses(List<Business> businesses) async {
    for (var business in businesses) {
      await _database.insertBusiness(business);
    }
  }

  Future<List<Business>> getBusinesses() async {
    return await _database.getAllBusinesses();
  }

  Future<Business?> getBusinessById(int id) async {
    return await _database.getBusinessById(id);
  }

  Future<void> deleteBusiness(int id) async {
    await _database.deleteBusiness(id);
  }

  Future<void> clearBusinesses() async {
    // 清除所有业务数据
    await _database.clearBusinesses();
  }

  // 物流发货数据相关操作
  late Box<Map<String, dynamic>> _logisticsDeliveryBox;

  // 初始化物流发货数据存储
  Future<void> initLogisticsDeliveryBox() async {
    _logisticsDeliveryBox = await Hive.openBox<Map<String, dynamic>>('logisticsDeliveryBox');
  }

  // 保存物流发货数据
  Future<void> saveLogisticsDeliveryData(Map<String, dynamic> data) async {
    await _logisticsDeliveryBox.put(data['id'], data);
  }

  // 获取物流发货数据
  Future<Map<String, dynamic>?> getLogisticsDeliveryData(int id) async {
    return _logisticsDeliveryBox.get(id);
  }

  // 获取所有物流发货数据
  Future<List<Map<String, dynamic>>> getAllLogisticsDeliveryData() async {
    return _logisticsDeliveryBox.values.toList();
  }

  // 删除物流发货数据
  Future<void> deleteLogisticsDeliveryData(int id) async {
    await _logisticsDeliveryBox.delete(id);
  }

  // 清除所有物流发货数据
  Future<void> clearLogisticsDeliveryData() async {
    await _logisticsDeliveryBox.clear();
  }



  // 日志管理相关操作
  late Box<OperationLog> _operationLogBox;

  // 初始化日志管理数据存储
  Future<void> initOperationLogBox() async {
    _operationLogBox = await Hive.openBox<OperationLog>('operationLogBox');
  }

  // 保存操作日志
  Future<void> saveOperationLog(OperationLog log) async {
    await _operationLogBox.put(log.id ?? DateTime.now().millisecondsSinceEpoch, log);
  }

  // 获取操作日志
  Future<OperationLog?> getOperationLog(int id) async {
    return _operationLogBox.get(id);
  }

  // 获取所有操作日志
  Future<List<OperationLog>> getAllOperationLogs() async {
    return _operationLogBox.values.toList();
  }

  // 按条件搜索操作日志
  Future<List<OperationLog>> searchOperationLogs({
    String? keyword,
    String? operationType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var logs = _operationLogBox.values.toList();
    
    if (keyword != null && keyword.isNotEmpty) {
      logs = logs.where((log) => 
        log.userName.contains(keyword) ||
        log.operationModule.contains(keyword) ||
        log.operationContent.contains(keyword)
      ).toList();
    }
    
    if (operationType != null && operationType.isNotEmpty) {
      logs = logs.where((log) => log.operationType == operationType).toList();
    }
    
    if (startDate != null) {
      logs = logs.where((log) => log.createdAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      logs = logs.where((log) => log.createdAt.isBefore(endDate)).toList();
    }
    
    return logs;
  }

  // 删除操作日志
  Future<void> deleteOperationLog(int id) async {
    await _operationLogBox.delete(id);
  }

  // 清除所有操作日志
  Future<void> clearOperationLogs() async {
    await _operationLogBox.clear();
  }

  // 系统参数相关操作
  late Box<SystemParameter> _systemParameterBox;

  // 初始化系统参数数据存储
  Future<void> initSystemParameterBox() async {
    _systemParameterBox = await Hive.openBox<SystemParameter>('systemParameterBox');
  }

  // 保存系统参数
  Future<void> saveSystemParameter(SystemParameter parameter) async {
    await _systemParameterBox.put(parameter.id ?? DateTime.now().millisecondsSinceEpoch, parameter);
  }

  // 获取系统参数
  Future<SystemParameter?> getSystemParameter(int id) async {
    return _systemParameterBox.get(id);
  }
  
  // 根据ID获取系统参数
  Future<SystemParameter?> getSystemParameterById(int id) async {
    return _systemParameterBox.get(id);
  }
  
  // 批量保存系统参数
  Future<void> saveSystemParameters(List<SystemParameter> parameters) async {
    final Map<dynamic, SystemParameter> paramsMap = {};
    for (final parameter in parameters) {
      paramsMap[parameter.id ?? DateTime.now().millisecondsSinceEpoch] = parameter;
    }
    await _systemParameterBox.putAll(paramsMap);
  }

  // 根据参数键获取系统参数
  Future<SystemParameter?> getSystemParameterByKey(String key) async {
    return _systemParameterBox.values.firstWhereOrNull((param) => param.parameterKey == key);
  }

  // 获取所有系统参数
  Future<List<SystemParameter>> getAllSystemParameters() async {
    return _systemParameterBox.values.toList();
  }

  // 按条件搜索系统参数
  Future<List<SystemParameter>> searchSystemParameters({
    String? keyword,
    String? parameterType,
  }) async {
    var parameters = _systemParameterBox.values.toList();
    
    if (keyword != null && keyword.isNotEmpty) {
      parameters = parameters.where((param) => 
        param.parameterKey.contains(keyword) ||
        param.parameterDescription.contains(keyword)
      ).toList();
    }
    
    if (parameterType != null && parameterType.isNotEmpty) {
      parameters = parameters.where((param) => param.parameterType == parameterType).toList();
    }
    
    return parameters;
  }

  // 删除系统参数
  Future<void> deleteSystemParameter(int id) async {
    await _systemParameterBox.delete(id);
  }

  // 清除所有系统参数
  Future<void> clearSystemParameters() async {
    await _systemParameterBox.clear();
  }

  // 数据字典相关操作
  late Box<DataDictionary> _dataDictionaryBox;

  // 初始化数据字典数据存储
  Future<void> initDataDictionaryBox() async {
    _dataDictionaryBox = await Hive.openBox<DataDictionary>('dataDictionaryBox');
  }

  // 保存数据字典
  Future<void> saveDataDictionary(DataDictionary dictionary) async {
    await _dataDictionaryBox.put(dictionary.id ?? DateTime.now().millisecondsSinceEpoch, dictionary);
  }

  // 获取数据字典
  Future<DataDictionary?> getDataDictionary(int id) async {
    return _dataDictionaryBox.get(id);
  }
  
  // 根据ID获取数据字典
  Future<DataDictionary?> getDataDictionaryById(int id) async {
    return _dataDictionaryBox.get(id);
  }
  
  // 批量保存数据字典
  Future<void> saveDataDictionaries(List<DataDictionary> dictionaries) async {
    final Map<dynamic, DataDictionary> dictMap = {};
    for (final dictionary in dictionaries) {
      dictMap[dictionary.id ?? DateTime.now().millisecondsSinceEpoch] = dictionary;
    }
    await _dataDictionaryBox.putAll(dictMap);
  }

  // 根据字典类型和键获取数据字典
  Future<DataDictionary?> getDataDictionaryByTypeAndCode(String dictType, String dictCode) async {
    return _dataDictionaryBox.values.firstWhereOrNull((dict) => 
      dict.dictType == dictType && dict.dictCode == dictCode
    );
  }

  // 根据字典类型获取数据字典列表
  Future<List<DataDictionary>> getDataDictionariesByType(String dictType) async {
    return _dataDictionaryBox.values
        .where((dict) => dict.dictType == dictType && dict.isActive)
        .toList();
  }

  // 获取所有数据字典
  Future<List<DataDictionary>> getAllDataDictionaries() async {
    return _dataDictionaryBox.values.toList();
  }

  // 按条件搜索数据字典
  Future<List<DataDictionary>> searchDataDictionaries({
    String? keyword,
    String? dictType,
  }) async {
    var dictionaries = _dataDictionaryBox.values.toList();
    
    if (keyword != null && keyword.isNotEmpty) {
      dictionaries = dictionaries.where((dict) => 
        dict.dictCode.contains(keyword) ||
        dict.dictName.contains(keyword) ||
        (dict.description != null && dict.description!.contains(keyword))
      ).toList();
    }
    
    if (dictType != null && dictType.isNotEmpty) {
      dictionaries = dictionaries.where((dict) => dict.dictType == dictType).toList();
    }
    
    return dictionaries;
  }

  // 删除数据字典
  Future<void> deleteDataDictionary(int id) async {
    await _dataDictionaryBox.delete(id);
  }

  // 清除所有数据字典
  Future<void> clearDataDictionaries() async {
    await _dataDictionaryBox.clear();
  }

  // 审批相关操作
  Future<void> saveApprovals(List<Approval> approvals) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      // 保存新数据
      for (var approval in approvals) {
        await _approvalsBox.put(approval.approvalId.toString(), approval);
      }
    } catch (e) {
      print('保存审批数据失败: $e');
    }
  }

  Future<List<Approval>> getApprovals() async {
    await _ensureInitialized();
    if (!_isInitialized) return [];
    
    try {
      return _approvalsBox.values.toList();
    } catch (e) {
      print('获取审批数据失败: $e');
      return [];
    }
  }

  Future<Approval?> getApprovalById(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return null;
    
    try {
      return _approvalsBox.get(id.toString());
    } catch (e) {
      print('根据ID获取审批数据失败: $e');
      return null;
    }
  }

  Future<void> saveApproval(Approval approval) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _approvalsBox.put(approval.approvalId.toString(), approval);
    } catch (e) {
      print('保存单个审批数据失败: $e');
    }
  }

  Future<void> deleteApproval(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _approvalsBox.delete(id.toString());
    } catch (e) {
      print('删除审批数据失败: $e');
    }
  }

  Future<void> clearApprovals() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _approvalsBox.clear();
    } catch (e) {
      print('清除审批数据失败: $e');
    }
  }

  // 智能体相关操作
  // 保存智能体列表
  Future<void> saveAgents(List<Agent> agents) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      for (var agent in agents) {
        await _agentsBox.put(agent.id, agent);
      }
    } catch (e) {
      print('保存智能体数据失败: $e');
    }
  }

  // 获取所有智能体
  Future<List<Agent>> getAgents() async {
    await _ensureInitialized();
    if (!_isInitialized) return [];
    
    try {
      return _agentsBox.values.toList();
    } catch (e) {
      // TODO: 替换为日志框架，避免生产环境直接使用 print
      // print('获取智能体数据失败: $e');
      return [];
    }
  }

  // 根据ID获取智能体
  Future<Agent?> getAgentById(String id) async {
    await _ensureInitialized();
    if (!_isInitialized) return null;
    
    try {
      return _agentsBox.get(id);
    } catch (e) {
      print('根据ID获取智能体数据失败: $e');
      return null;
    }
  }

  // 保存单个智能体
  Future<void> saveAgent(Agent agent) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _agentsBox.put(agent.id, agent);
    } catch (e) {
      print('保存单个智能体数据失败: $e');
    }
  }

  // 删除智能体
  Future<void> deleteAgent(String id) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _agentsBox.delete(id);
    } catch (e) {
      print('删除智能体数据失败: $e');
    }
  }

  // 清除所有智能体
  Future<void> clearAgents() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _agentsBox.clear();
    } catch (e) {
      print('清除智能体数据失败: $e');
    }
  }

  // 智能体配置相关操作
  // 保存智能体配置
  Future<void> saveAgentConfig(AgentConfig config) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _agentConfigBox.put('default', config);
    } catch (e) {
      print('保存智能体配置失败: $e');
    }
  }

  // 获取智能体配置
  Future<AgentConfig?> getAgentConfig() async {
    await _ensureInitialized();
    if (!_isInitialized) return null;
    
    try {
      return _agentConfigBox.get('default');
    } catch (e) {
      print('获取智能体配置失败: $e');
      return null;
    }
  }

  // 删除智能体配置
  Future<void> deleteAgentConfig() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    
    try {
      await _agentConfigBox.delete('default');
    } catch (e) {
      print('删除智能体配置失败: $e');
    }
  }

  // 通用操作
  Future<void> clearAllData() async {
    await clearProducts();
    await clearOrders();
    await clearCustomers();
    await clearCustomerCategories();
    await clearCustomerTags();
    await clearCustomerContactLogs();
    await clearSalesOpportunities();
    await clearContactRecords();
    await clearBusinesses();
    await clearLogisticsDeliveryData();
    await clearOperationLogs();
    await clearSystemParameters();
    await clearDataDictionaries();
    await clearApprovals();
  }
}

/// 本地存储服务提供者
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
