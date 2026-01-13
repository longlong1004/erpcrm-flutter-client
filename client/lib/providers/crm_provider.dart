import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import 'package:erpcrm_client/models/crm/customer_category.dart';
import 'package:erpcrm_client/models/crm/customer_tag.dart';
import 'package:erpcrm_client/models/crm/contact_record.dart';
import 'package:erpcrm_client/models/crm/sales_opportunity.dart';
import 'package:erpcrm_client/services/crm_service.dart';

// CRM服务提供器
final crmServiceProvider = Provider<CrmService>((ref) {
  return CrmService();
});

// 客户列表状态管理（手动实现）
final customersProvider = AsyncNotifierProvider<CustomersNotifier, List<Customer>>(
  () => CustomersNotifier(),
);

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  late final CrmService _crmService;

  @override
  Future<List<Customer>> build() async {
    _crmService = ref.read(crmServiceProvider);
    return await _crmService.getCustomers();
  }

  Future<void> fetchCustomers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getCustomers();
    });
  }

  Future<void> searchCustomers(String keyword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.searchCustomers(keyword);
    });
  }

  Future<void> createCustomer(Map<String, dynamic> customerData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newCustomer = await _crmService.createCustomer(customerData);
      final currentCustomers = await future;
      return [...currentCustomers, newCustomer];
    });
  }

  Future<void> updateCustomer(int customerId, Map<String, dynamic> customerData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedCustomer = await _crmService.updateCustomer(customerId, customerData);
      final currentCustomers = await future;
      return currentCustomers.map((customer) =>
        customer.customerId == customerId ? updatedCustomer : customer
      ).toList();
    });
  }

  Future<void> deleteCustomer(int customerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _crmService.deleteCustomer(customerId);
      final currentCustomers = await future;
      return currentCustomers.where((customer) => customer.customerId != customerId).toList();
    });
  }
}

// 客户分类状态管理（手动实现）
final customerCategoriesProvider = AsyncNotifierProvider<CustomerCategoriesNotifier, List<CustomerCategory>>(
  () => CustomerCategoriesNotifier(),
);

class CustomerCategoriesNotifier extends AsyncNotifier<List<CustomerCategory>> {
  late final CrmService _crmService;

  @override
  Future<List<CustomerCategory>> build() async {
    _crmService = ref.read(crmServiceProvider);
    return await _crmService.getCustomerCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getCustomerCategories();
    });
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newCategory = await _crmService.createCustomerCategory(categoryData);
      final currentCategories = await future;
      return [...currentCategories, newCategory];
    });
  }

  Future<void> updateCategory(int categoryId, Map<String, dynamic> categoryData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedCategory = await _crmService.updateCustomerCategory(categoryId, categoryData);
      final currentCategories = await future;
      return currentCategories.map((category) =>
        category.categoryId == categoryId ? updatedCategory : category
      ).toList();
    });
  }

  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _crmService.deleteCustomerCategory(categoryId);
      final currentCategories = await future;
      return currentCategories.where((category) => category.categoryId != categoryId).toList();
    });
  }
}

// 联系记录状态管理（手动实现）
final contactRecordsProvider = AsyncNotifierProvider<ContactRecordsNotifier, List<ContactRecord>>(
  () => ContactRecordsNotifier(),
);

class ContactRecordsNotifier extends AsyncNotifier<List<ContactRecord>> {
  late final CrmService _crmService;

  @override
  Future<List<ContactRecord>> build() async {
    _crmService = ref.read(crmServiceProvider);
    return await _crmService.getContactRecords();
  }

  Future<void> fetchContactRecords() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getContactRecords();
    });
  }

  Future<void> getContactRecordsByCustomer(int customerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getContactRecordsByCustomer(customerId);
    });
  }

  Future<void> createContactRecord(Map<String, dynamic> recordData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newRecord = await _crmService.createContactRecord(recordData);
      final currentRecords = await future;
      return [...currentRecords, newRecord];
    });
  }

  Future<void> updateContactRecord(int recordId, Map<String, dynamic> recordData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedRecord = await _crmService.updateContactRecord(recordId, recordData);
      final currentRecords = await future;
      return currentRecords.map((record) =>
        record.recordId == recordId ? updatedRecord : record
      ).toList();
    });
  }

  Future<void> deleteContactRecord(int recordId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _crmService.deleteContactRecord(recordId);
      final currentRecords = await future;
      return currentRecords.where((record) => record.recordId != recordId).toList();
    });
  }
}

// 销售机会状态管理（手动实现）
final salesOpportunitiesProvider = AsyncNotifierProvider<SalesOpportunitiesNotifier, List<SalesOpportunity>>(
  () => SalesOpportunitiesNotifier(),
);

class SalesOpportunitiesNotifier extends AsyncNotifier<List<SalesOpportunity>> {
  late final CrmService _crmService;

  @override
  Future<List<SalesOpportunity>> build() async {
    _crmService = ref.read(crmServiceProvider);
    return await _crmService.getSalesOpportunities();
  }

  Future<void> fetchSalesOpportunities() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getSalesOpportunities();
    });
  }

  Future<void> getSalesOpportunitiesByCustomer(int customerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getSalesOpportunitiesByCustomer(customerId);
    });
  }

  Future<void> createSalesOpportunity(Map<String, dynamic> opportunityData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newOpportunity = await _crmService.createSalesOpportunity(opportunityData);
      final currentOpportunities = await future;
      return [...currentOpportunities, newOpportunity];
    });
  }

  Future<void> updateSalesOpportunity(int opportunityId, Map<String, dynamic> opportunityData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedOpportunity = await _crmService.updateSalesOpportunity(opportunityId, opportunityData);
      final currentOpportunities = await future;
      return currentOpportunities.map((opportunity) =>
        opportunity.opportunityId == opportunityId ? updatedOpportunity : opportunity
      ).toList();
    });
  }

  Future<void> deleteSalesOpportunity(int opportunityId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _crmService.deleteSalesOpportunity(opportunityId);
      final currentOpportunities = await future;
      return currentOpportunities.where((opportunity) => opportunity.opportunityId != opportunityId).toList();
    });
  }
}

// 单个客户状态管理
final customerProvider = AsyncNotifierProviderFamily<CustomerNotifier, Customer, int>(
  () => CustomerNotifier(),
);

class CustomerNotifier extends FamilyAsyncNotifier<Customer, int> {
  late final CrmService _crmService;

  @override
  Future<Customer> build(int customerId) async {
    _crmService = ref.read(crmServiceProvider);
    return await _crmService.getCustomerById(customerId);
  }

  Future<void> fetchCustomer() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _crmService.getCustomerById(arg);
    });
  }

  Future<void> updateCustomer(Map<String, dynamic> customerData) async {
    state = await AsyncValue.guard(() async {
      return await _crmService.updateCustomer(arg, customerData);
    });
  }
}

// 客户标签状态管理
final customerTagsProvider = AsyncNotifierProvider<CustomerTagsNotifier, List<CustomerTag>>(
  () => CustomerTagsNotifier(),
);

class CustomerTagsNotifier extends AsyncNotifier<List<CustomerTag>> {
  late final CrmService _crmService;

  @override
  Future<List<CustomerTag>> build() async {
    _crmService = ref.read(crmServiceProvider);
    // Return empty list for now, implement actual API call later
    return [];
  }

  Future<void> fetchTags() async {
    state = const AsyncValue.loading();
    // Implement actual API call later
    state = AsyncValue.data([]);
  }

  Future<void> createTag(Map<String, dynamic> tagData) async {
    state = const AsyncValue.loading();
    // Implement actual API call later
    // Mock new tag with generated id for now
    final newTag = CustomerTag(
      tagId: (await future).length + 1,
      tagName: tagData['tagName'],
      tagCode: tagData['tagCode'],
      tagDesc: tagData['tagDesc'],
      status: tagData['status'],
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
      deleted: false,
    );
    state = AsyncValue.data([...await future, newTag]);
  }

  Future<void> updateTag(int tagId, Map<String, dynamic> tagData) async {
    state = const AsyncValue.loading();
    // Implement actual API call later
    state = AsyncValue.data(
      (await future).map((tag) => 
        tag.tagId == tagId ? 
          CustomerTag(
            tagId: tag.tagId,
            tagName: tagData['tagName'],
            tagCode: tagData['tagCode'],
            tagDesc: tagData['tagDesc'],
            status: tagData['status'],
            createTime: tag.createTime,
            updateTime: DateTime.now(),
            deleted: tag.deleted,
          ) : tag
      ).toList()
    );
  }

  Future<void> deleteTag(int tagId) async {
    state = const AsyncValue.loading();
    // Implement actual API call later
    state = AsyncValue.data(
      (await future).where((tag) => tag.tagId != tagId).toList()
    );
  }
}