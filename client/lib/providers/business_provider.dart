import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business/business.dart';
import '../services/business_service.dart';

// 创建BusinessService的provider
final businessServiceProvider = Provider<BusinessService>((ref) {
  return BusinessService();
});

// 业务列表状态管理
final businessesProvider = AsyncNotifierProvider<BusinessesNotifier, List<Business>>(
  () => BusinessesNotifier(),
);

class BusinessesNotifier extends AsyncNotifier<List<Business>> {
  late final BusinessService _businessService;

  @override
  Future<List<Business>> build() async {
    _businessService = ref.read(businessServiceProvider);
    return await _businessService.getBusinesses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _businessService.getBusinesses();
    });
  }

  Future<void> fetchBusinesses({Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _businessService.getBusinesses(params: params);
    });
  }

  Future<void> searchBusinesses(String keyword, {Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _businessService.searchBusinesses(keyword, params: params);
    });
  }

  Future<void> createBusiness(Map<String, dynamic> businessData) async {
    state = await AsyncValue.guard(() async {
      final newBusiness = await _businessService.createBusiness(businessData);
      final currentBusinesses = state.value ?? [];
      return [...currentBusinesses, newBusiness];
    });
  }

  Future<void> updateBusiness(int id, Map<String, dynamic> businessData) async {
    state = await AsyncValue.guard(() async {
      final updatedBusiness = await _businessService.updateBusiness(id, businessData);
      final currentBusinesses = state.value ?? [];
      return currentBusinesses
          .map((business) => business.id == id ? updatedBusiness : business)
          .toList();
    });
  }

  Future<void> deleteBusiness(int id) async {
    state = await AsyncValue.guard(() async {
      await _businessService.deleteBusiness(id);
      final currentBusinesses = state.value ?? [];
      return currentBusinesses
          .where((business) => business.id != id)
          .toList();
    });
  }

  Future<void> softDeleteBusiness(int id) async {
    state = await AsyncValue.guard(() async {
      await _businessService.softDeleteBusiness(id);
      final currentBusinesses = state.value ?? [];
      return currentBusinesses
          .where((business) => business.id != id)
          .toList();
    });
  }

  Future<void> restoreBusiness(int id) async {
    state = await AsyncValue.guard(() async {
      final restoredBusiness = await _businessService.restoreBusiness(id);
      final currentBusinesses = state.value ?? [];
      return [...currentBusinesses, restoredBusiness];
    });
  }
}

// 单个业务状态管理
final businessProvider = AsyncNotifierProviderFamily<BusinessNotifier, Business, int>(
  () => BusinessNotifier(),
);

class BusinessNotifier extends FamilyAsyncNotifier<Business, int> {
  late final BusinessService _businessService;

  @override
  Future<Business> build(int businessId) async {
    _businessService = ref.read(businessServiceProvider);
    return await _businessService.getBusinessById(businessId);
  }

  Future<void> fetchBusiness() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _businessService.getBusinessById(arg);
    });
  }

  Future<void> updateBusiness(Map<String, dynamic> businessData) async {
    state = await AsyncValue.guard(() async {
      return await _businessService.updateBusiness(arg, businessData);
    });
  }

  Future<void> activateBusiness() async {
    state = await AsyncValue.guard(() async {
      return await _businessService.activateBusiness(arg);
    });
  }

  Future<void> deactivateBusiness() async {
    state = await AsyncValue.guard(() async {
      return await _businessService.deactivateBusiness(arg);
    });
  }

  Future<void> completeBusiness() async {
    state = await AsyncValue.guard(() async {
      return await _businessService.completeBusiness(arg);
    });
  }

  Future<void> cancelBusiness() async {
    state = await AsyncValue.guard(() async {
      return await _businessService.cancelBusiness(arg);
    });
  }
}