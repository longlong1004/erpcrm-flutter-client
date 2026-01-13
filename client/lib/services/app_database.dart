// 简化的数据库实现，暂时只支持基本的CRUD操作
// 后续会添加完整的drift支持
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';

import '../models/product/product.dart';
import '../models/order/order.dart';
import '../models/order/order_item.dart';
import '../models/crm/customer.dart';
import '../models/crm/customer_category.dart';
import '../models/crm/customer_tag.dart';
import '../models/crm/customer_contact_log.dart';
import '../models/crm/sales_opportunity.dart';
import '../models/crm/contact_record.dart';
import '../models/business/business.dart';
import '../models/approval_delegate_rule.dart';
import '../models/settings/operation_log.dart';
import '../models/settings/system_parameter.dart';
import '../models/settings/data_dictionary.dart';

/// 简化的数据库服务，使用Hive作为统一的存储方案
  /// 后续会迁移到完整的drift实现
  class AppDatabase {
    // 单例模式
    static final AppDatabase _instance = AppDatabase._internal();
    factory AppDatabase() => _instance;
    AppDatabase._internal();
    bool _isInitialized = false;

    // Hive Boxes
    late Box<Product> _productBox;
    late Box<Order> _orderBox;
    late Box<Customer> _customerBox;
    late Box<CustomerCategory> _customerCategoryBox;
    late Box<CustomerTag> _customerTagBox;
    late Box<CustomerContactLog> _customerContactLogBox;
    late Box<SalesOpportunity> _salesOpportunityBox;
    late Box<ContactRecord> _contactRecordBox;
    late Box<Business> _businessBox;
    late Box<Map> _approvalDelegateRuleBox;
    late Box<OperationLog> _operationLogBox;
    late Box<SystemParameter> _systemParameterBox;
    late Box<DataDictionary> _dataDictionaryBox;

  /// 初始化数据库
  Future<void> init() async {
    if (_isInitialized) return;
    
    // 注册Hive适配器（检查是否已注册）
    try {
      Hive.registerAdapter(ProductAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(OrderItemAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(OrderAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(CustomerAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(CustomerCategoryAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(CustomerTagAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(CustomerContactLogAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(SalesOpportunityAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(ContactRecordAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(BusinessAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(OperationLogAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(SystemParameterAdapter());
    } catch (_) {
      // 适配器已注册
    }
    try {
      Hive.registerAdapter(DataDictionaryAdapter());
    } catch (_) {
      // 适配器已注册
    }
    
    // 打开Hive Boxes
    _productBox = await Hive.openBox<Product>('products');
    _orderBox = await Hive.openBox<Order>('orders');
    _customerBox = await Hive.openBox<Customer>('customers');
    _customerCategoryBox = await Hive.openBox<CustomerCategory>('customer_categories');
    _customerTagBox = await Hive.openBox<CustomerTag>('customer_tags');
    _customerContactLogBox = await Hive.openBox<CustomerContactLog>('customer_contact_logs');
    _salesOpportunityBox = await Hive.openBox<SalesOpportunity>('sales_opportunities');
    _contactRecordBox = await Hive.openBox<ContactRecord>('contact_records');
    _businessBox = await Hive.openBox<Business>('businesses');
    _approvalDelegateRuleBox = await Hive.openBox<Map>('approval_delegate_rules');
    _operationLogBox = await Hive.openBox<OperationLog>('operation_logs');
    _systemParameterBox = await Hive.openBox<SystemParameter>('system_parameters');
    _dataDictionaryBox = await Hive.openBox<DataDictionary>('data_dictionaries');
    
    _isInitialized = true;
  }
  


  // 产品相关操作
  Future<List<Product>> getAllProducts() async {
    return _productBox.values.toList();
  }

  Future<Product?> getProductById(int id) async {
    return _productBox.get(id);
  }

  Future<void> insertProduct(Product product) async {
    await _productBox.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product);
  }

  Future<void> deleteProduct(int id) async {
    await _productBox.delete(id);
  }

  // 订单相关操作
  Future<List<Order>> getAllOrders() async {
    if (!_isInitialized) {
      await init();
    }
    return _orderBox.values.toList();
  }

  Future<Order?> getOrderById(int id) async {
    return _orderBox.get(id);
  }

  Future<void> insertOrder(Order order) async {
    await _orderBox.put(order.id, order);
  }

  Future<void> updateOrder(Order order) async {
    await _orderBox.put(order.id, order);
  }

  Future<void> deleteOrder(int id) async {
    await _orderBox.delete(id);
  }

  // 订单项相关操作
  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    // 简化实现，返回空列表
    // 实际应用中，订单项应该作为独立的表存储
    return [];
  }

  Future<void> insertOrderItem(OrderItem orderItem) async {
    // 简化实现，不做任何操作
    // 实际应用中，订单项应该作为独立的表存储
  }

  // 客户相关操作
  Future<List<Customer>> getAllCustomers() async {
    return _customerBox.values.toList();
  }

  Future<Customer?> getCustomerById(int customerId) async {
    return _customerBox.get(customerId);
  }

  Future<void> insertCustomer(Customer customer) async {
    await _customerBox.put(customer.customerId, customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customerBox.put(customer.customerId, customer);
  }

  Future<void> deleteCustomer(int customerId) async {
    await _customerBox.delete(customerId);
  }

  // 客户分类相关操作
  Future<List<CustomerCategory>> getAllCustomerCategories() async {
    return _customerCategoryBox.values.toList();
  }

  Future<CustomerCategory?> getCustomerCategoryById(int categoryId) async {
    return _customerCategoryBox.get(categoryId);
  }

  Future<void> insertCustomerCategory(CustomerCategory category) async {
    await _customerCategoryBox.put(category.categoryId, category);
  }

  Future<void> updateCustomerCategory(CustomerCategory category) async {
    await _customerCategoryBox.put(category.categoryId, category);
  }

  Future<void> deleteCustomerCategory(int categoryId) async {
    await _customerCategoryBox.delete(categoryId);
  }

  // 客户标签相关操作
  Future<List<CustomerTag>> getAllCustomerTags() async {
    return _customerTagBox.values.toList();
  }

  Future<CustomerTag?> getCustomerTagById(int tagId) async {
    return _customerTagBox.get(tagId);
  }

  Future<void> insertCustomerTag(CustomerTag tag) async {
    await _customerTagBox.put(tag.tagId, tag);
  }

  Future<void> updateCustomerTag(CustomerTag tag) async {
    await _customerTagBox.put(tag.tagId, tag);
  }

  Future<void> deleteCustomerTag(int tagId) async {
    await _customerTagBox.delete(tagId);
  }

  // 客户联系日志相关操作
  Future<List<CustomerContactLog>> getAllCustomerContactLogs() async {
    return _customerContactLogBox.values.toList();
  }

  Future<List<CustomerContactLog>> getCustomerContactLogsByCustomerId(int customerId) async {
    return _customerContactLogBox.values.where((log) => log.customerId == customerId).toList();
  }

  Future<CustomerContactLog?> getCustomerContactLogById(int logId) async {
    return _customerContactLogBox.get(logId);
  }

  Future<void> insertCustomerContactLog(CustomerContactLog log) async {
    await _customerContactLogBox.put(log.contactLogId, log);
  }

  Future<void> updateCustomerContactLog(CustomerContactLog log) async {
    await _customerContactLogBox.put(log.contactLogId, log);
  }

  Future<void> deleteCustomerContactLog(int logId) async {
    await _customerContactLogBox.delete(logId);
  }

  // 销售机会相关操作
  Future<List<SalesOpportunity>> getAllSalesOpportunities() async {
    return _salesOpportunityBox.values.toList();
  }

  Future<List<SalesOpportunity>> getSalesOpportunitiesByCustomerId(int customerId) async {
    return _salesOpportunityBox.values.where((opp) => opp.customerId == customerId).toList();
  }

  Future<SalesOpportunity?> getSalesOpportunityById(int opportunityId) async {
    return _salesOpportunityBox.get(opportunityId);
  }

  Future<void> insertSalesOpportunity(SalesOpportunity opportunity) async {
    await _salesOpportunityBox.put(opportunity.opportunityId, opportunity);
  }

  Future<void> updateSalesOpportunity(SalesOpportunity opportunity) async {
    await _salesOpportunityBox.put(opportunity.opportunityId, opportunity);
  }

  Future<void> deleteSalesOpportunity(int opportunityId) async {
    await _salesOpportunityBox.delete(opportunityId);
  }

  // 联系记录相关操作
  Future<List<ContactRecord>> getAllContactRecords() async {
    return _contactRecordBox.values.toList();
  }

  Future<List<ContactRecord>> getContactRecordsByCustomerId(int customerId) async {
    return _contactRecordBox.values.where((record) => record.customerId == customerId).toList();
  }

  Future<ContactRecord?> getContactRecordById(int recordId) async {
    return _contactRecordBox.get(recordId);
  }

  Future<void> insertContactRecord(ContactRecord record) async {
    await _contactRecordBox.put(record.recordId, record);
  }

  Future<void> updateContactRecord(ContactRecord record) async {
    await _contactRecordBox.put(record.recordId, record);
  }

  Future<void> deleteContactRecord(int recordId) async {
    await _contactRecordBox.delete(recordId);
  }

  // 业务相关操作
  Future<List<Business>> getAllBusinesses() async {
    return _businessBox.values.toList();
  }

  Future<Business?> getBusinessById(int id) async {
    return _businessBox.get(id);
  }

  Future<void> insertBusiness(Business business) async {
    await _businessBox.put(business.id, business);
  }

  Future<void> updateBusiness(Business business) async {
    await _businessBox.put(business.id, business);
  }

  Future<void> deleteBusiness(int id) async {
    await _businessBox.delete(id);
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_isInitialized) {
      await _productBox.close();
      await _orderBox.close();
      await _customerBox.close();
      await _customerCategoryBox.close();
      await _customerTagBox.close();
      await _customerContactLogBox.close();
      await _salesOpportunityBox.close();
      await _contactRecordBox.close();
      await _businessBox.close();
      await _approvalDelegateRuleBox.close();
      await Hive.close();
      _isInitialized = false;
    }
  }

  /// 清除所有产品数据
  Future<void> clearProducts() async {
    await _productBox.clear();
  }

  /// 清除所有订单数据
  Future<void> clearOrders() async {
    await _orderBox.clear();
  }

  /// 清除所有客户数据
  Future<void> clearCustomers() async {
    await _customerBox.clear();
  }

  /// 清除所有客户分类数据
  Future<void> clearCustomerCategories() async {
    await _customerCategoryBox.clear();
  }

  /// 清除所有客户标签数据
  Future<void> clearCustomerTags() async {
    await _customerTagBox.clear();
  }

  /// 清除所有客户联系日志数据
  Future<void> clearCustomerContactLogs() async {
    await _customerContactLogBox.clear();
  }

  /// 清除所有销售机会数据
  Future<void> clearSalesOpportunities() async {
    await _salesOpportunityBox.clear();
  }

  /// 清除所有联系记录数据
  Future<void> clearContactRecords() async {
    await _contactRecordBox.clear();
  }

  /// 清除所有业务数据
  Future<void> clearBusinesses() async {
    await _businessBox.clear();
  }

  // 操作日志相关操作
  Future<List<OperationLog>> getAllOperationLogs() async {
    return _operationLogBox.values.toList();
  }

  Future<OperationLog?> getOperationLogById(int id) async {
    return _operationLogBox.get(id);
  }

  Future<void> insertOperationLog(OperationLog log) async {
    await _operationLogBox.put(log.id ?? DateTime.now().millisecondsSinceEpoch, log);
  }

  Future<void> deleteOperationLog(int id) async {
    await _operationLogBox.delete(id);
  }

  Future<void> clearOperationLogs() async {
    await _operationLogBox.clear();
  }

  // 系统参数相关操作
  Future<List<SystemParameter>> getAllSystemParameters() async {
    return _systemParameterBox.values.toList();
  }

  Future<SystemParameter?> getSystemParameterById(int id) async {
    return _systemParameterBox.get(id);
  }

  Future<SystemParameter?> getSystemParameterByKey(String key) async {
    return _systemParameterBox.values.firstWhereOrNull((param) => param.parameterKey == key);
  }

  Future<void> insertSystemParameter(SystemParameter parameter) async {
    await _systemParameterBox.put(parameter.id ?? DateTime.now().millisecondsSinceEpoch, parameter);
  }

  Future<void> updateSystemParameter(SystemParameter parameter) async {
    if (parameter.id != null) {
      await _systemParameterBox.put(parameter.id, parameter);
    }
  }

  Future<void> deleteSystemParameter(int id) async {
    await _systemParameterBox.delete(id);
  }

  Future<void> clearSystemParameters() async {
    await _systemParameterBox.clear();
  }

  // 数据字典相关操作
  Future<List<DataDictionary>> getAllDataDictionaries() async {
    return _dataDictionaryBox.values.toList();
  }

  Future<List<DataDictionary>> getDataDictionariesByType(String dictType) async {
    return _dataDictionaryBox.values.where((dict) => dict.dictType == dictType).toList();
  }

  Future<DataDictionary?> getDataDictionaryById(int id) async {
    return _dataDictionaryBox.get(id);
  }

  Future<DataDictionary?> getDataDictionaryByCode(String dictType, String dictCode) async {
    return _dataDictionaryBox.values.firstWhereOrNull(
      (dict) => dict.dictType == dictType && dict.dictCode == dictCode
    );
  }

  Future<void> insertDataDictionary(DataDictionary dictionary) async {
    await _dataDictionaryBox.put(dictionary.id ?? DateTime.now().millisecondsSinceEpoch, dictionary);
  }

  Future<void> updateDataDictionary(DataDictionary dictionary) async {
    if (dictionary.id != null) {
      await _dataDictionaryBox.put(dictionary.id, dictionary);
    }
  }

  Future<void> deleteDataDictionary(int id) async {
    await _dataDictionaryBox.delete(id);
  }

  Future<void> clearDataDictionaries() async {
    await _dataDictionaryBox.clear();
  }

  // 审批人代理规则相关操作
  Future<List<ApprovalDelegateRule>> getAllApprovalDelegateRules() async {
    final rules = <ApprovalDelegateRule>[];
    for (final map in _approvalDelegateRuleBox.values) {
      rules.add(ApprovalDelegateRule.fromJson(map.cast<String, dynamic>()));
    }
    return rules;
  }

  Future<ApprovalDelegateRule?> getApprovalDelegateRuleById(int id) async {
    final map = _approvalDelegateRuleBox.get(id);
    if (map != null) {
      return ApprovalDelegateRule.fromJson(map.cast<String, dynamic>());
    }
    return null;
  }

  Future<void> insertApprovalDelegateRule(ApprovalDelegateRule rule) async {
    final key = rule.id ?? DateTime.now().millisecondsSinceEpoch;
    await _approvalDelegateRuleBox.put(key, rule.toJson());
  }

  Future<void> updateApprovalDelegateRule(ApprovalDelegateRule rule) async {
    if (rule.id != null) {
      await _approvalDelegateRuleBox.put(rule.id, rule.toJson());
    }
  }

  /// 初始化示例数据
  Future<void> initSampleData() async {
    // 初始化操作日志
    if (_operationLogBox.isEmpty) {
      final logs = [
        OperationLog(
          id: 1,
          userId: 1,
          userName: 'admin',
          operationModule: '用户管理',
          operationType: '登录',
          operationContent: '用户登录系统',
          operationResult: '成功',
          errorMessage: '',
          clientIp: '127.0.0.1',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isSynced: true,
        ),
        OperationLog(
          id: 2,
          userId: 1,
          userName: 'admin',
          operationModule: '产品管理',
          operationType: '新增',
          operationContent: '新增产品：铁路零部件A',
          operationResult: '成功',
          errorMessage: '',
          clientIp: '127.0.0.1',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          isSynced: true,
        ),
        OperationLog(
          id: 3,
          userId: 1,
          userName: 'admin',
          operationModule: '订单管理',
          operationType: '修改',
          operationContent: '修改订单状态为已发货',
          operationResult: '成功',
          errorMessage: '',
          clientIp: '127.0.0.1',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          isSynced: true,
        ),
      ];
      for (final log in logs) {
        await insertOperationLog(log);
      }
    }

    // 初始化系统参数
    if (_systemParameterBox.isEmpty) {
      final params = [
        SystemParameter(
          id: 1,
          parameterKey: 'SYSTEM_NAME',
          parameterValue: '国铁商城ERP+CRM系统',
          parameterDescription: '系统名称',
          parameterType: 'system',
          defaultValue: '国铁商城ERP+CRM系统',
          isEditable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        SystemParameter(
          id: 2,
          parameterKey: 'SYSTEM_VERSION',
          parameterValue: '1.0.0',
          parameterDescription: '系统版本',
          parameterType: 'system',
          defaultValue: '1.0.0',
          isEditable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        SystemParameter(
          id: 3,
          parameterKey: 'MAX_LOGIN_ATTEMPTS',
          parameterValue: '5',
          parameterDescription: '最大登录尝试次数',
          parameterType: 'system',
          defaultValue: '5',
          isEditable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        SystemParameter(
          id: 4,
          parameterKey: 'DEFAULT_CURRENCY',
          parameterValue: 'CNY',
          parameterDescription: '默认货币',
          parameterType: 'system',
          defaultValue: 'CNY',
          isEditable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        SystemParameter(
          id: 5,
          parameterKey: 'PAGE_SIZE',
          parameterValue: '20',
          parameterDescription: '默认分页大小',
          parameterType: 'system',
          defaultValue: '20',
          isEditable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
      ];
      for (final param in params) {
        await insertSystemParameter(param);
      }
    }

    // 初始化数据字典
    if (_dataDictionaryBox.isEmpty) {
      final now = DateTime.now();
      final dictionaries = [
        // 产品状态
        DataDictionary(
          id: 1,
          dictType: 'PRODUCT_STATUS',
          dictCode: 'ACTIVE',
          dictName: '有效',
          dictValue: '1',
          description: '产品有效状态',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 2,
          dictType: 'PRODUCT_STATUS',
          dictCode: 'INACTIVE',
          dictName: '无效',
          dictValue: '0',
          description: '产品无效状态',
          sortOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        // 订单状态
        DataDictionary(
          id: 3,
          dictType: 'ORDER_STATUS',
          dictCode: 'PENDING',
          dictName: '待处理',
          dictValue: '0',
          description: '订单待处理状态',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 4,
          dictType: 'ORDER_STATUS',
          dictCode: 'PROCESSING',
          dictName: '处理中',
          dictValue: '1',
          description: '订单处理中状态',
          sortOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 5,
          dictType: 'ORDER_STATUS',
          dictCode: 'SHIPPED',
          dictName: '已发货',
          dictValue: '2',
          description: '订单已发货状态',
          sortOrder: 3,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 6,
          dictType: 'ORDER_STATUS',
          dictCode: 'COMPLETED',
          dictName: '已完成',
          dictValue: '3',
          description: '订单已完成状态',
          sortOrder: 4,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 7,
          dictType: 'ORDER_STATUS',
          dictCode: 'CANCELLED',
          dictName: '已取消',
          dictValue: '4',
          description: '订单已取消状态',
          sortOrder: 5,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        // 客户等级
        DataDictionary(
          id: 8,
          dictType: 'CUSTOMER_LEVEL',
          dictCode: 'VIP',
          dictName: 'VIP客户',
          dictValue: '1',
          description: 'VIP客户等级',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 9,
          dictType: 'CUSTOMER_LEVEL',
          dictCode: 'PLATINUM',
          dictName: '铂金客户',
          dictValue: '2',
          description: '铂金客户等级',
          sortOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 10,
          dictType: 'CUSTOMER_LEVEL',
          dictCode: 'GOLD',
          dictName: '黄金客户',
          dictValue: '3',
          description: '黄金客户等级',
          sortOrder: 3,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 11,
          dictType: 'CUSTOMER_LEVEL',
          dictCode: 'SILVER',
          dictName: '白银客户',
          dictValue: '4',
          description: '白银客户等级',
          sortOrder: 4,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 12,
          dictType: 'CUSTOMER_LEVEL',
          dictCode: 'BRONZE',
          dictName: '青铜客户',
          dictValue: '5',
          description: '青铜客户等级',
          sortOrder: 5,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        // 审批状态
        DataDictionary(
          id: 13,
          dictType: 'APPROVAL_STATUS',
          dictCode: 'PENDING',
          dictName: '待审批',
          dictValue: '0',
          description: '审批待处理状态',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 14,
          dictType: 'APPROVAL_STATUS',
          dictCode: 'APPROVED',
          dictName: '已审批',
          dictValue: '1',
          description: '审批通过状态',
          sortOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
        DataDictionary(
          id: 15,
          dictType: 'APPROVAL_STATUS',
          dictCode: 'REJECTED',
          dictName: '已拒绝',
          dictValue: '2',
          description: '审批拒绝状态',
          sortOrder: 3,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          isSynced: true,
        ),
      ];
      for (final dict in dictionaries) {
        await insertDataDictionary(dict);
      }
    }
  }

  Future<void> deleteApprovalDelegateRule(int id) async {
    await _approvalDelegateRuleBox.delete(id);
  }

  /// 清除所有审批人代理规则数据
  Future<void> clearApprovalDelegateRules() async {
    await _approvalDelegateRuleBox.clear();
  }
}

