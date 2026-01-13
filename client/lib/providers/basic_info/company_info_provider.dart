import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/company_info.dart';
import 'package:erpcrm_client/services/api_service.dart';

class CompanyInfoState {
  final List<CompanyInfo> companies;
  final bool isLoading;
  final String? error;

  const CompanyInfoState({
    this.companies = const [],
    this.isLoading = false,
    this.error,
  });

  CompanyInfoState copyWith({
    List<CompanyInfo>? companies,
    bool? isLoading,
    String? error,
  }) {
    return CompanyInfoState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CompanyInfoNotifier extends StateNotifier<CompanyInfoState> {
  final Box companyBox;
  final ApiService _apiService;

  CompanyInfoNotifier(this.companyBox, this._apiService) : super(const CompanyInfoState()) {
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    state = state.copyWith(isLoading: true);
    try {
      // 从API获取数据
      final apiCompanies = await _apiService.getCompanies();
      
      // 将API数据转换为CompanyInfo对象
      final companies = apiCompanies
          .map((json) => CompanyInfo.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // 更新本地Hive存储
      await companyBox.put('companies', companies.map((c) => c.toJson()).toList());
      
      // 更新状态
      state = state.copyWith(
        companies: companies,
        isLoading: false,
      );
    } catch (e) {
      // API请求失败，尝试从本地Hive加载数据
      try {
        final companiesJson = companyBox.get('companies', defaultValue: <Map<String, dynamic>>[]);
        final companies = (companiesJson as List)
            .map((json) => CompanyInfo.fromJson(json as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          companies: companies,
          isLoading: false,
          error: '从服务器获取数据失败，已加载本地缓存数据: $e',
        );
      } catch (hiveError) {
        // 本地Hive加载也失败
        state = state.copyWith(
          isLoading: false,
          error: '加载公司信息失败: $hiveError',
        );
      }
    }
  }

  Future<void> addCompany(CompanyInfo company) async {
    // 保存当前状态，用于API调用失败时恢复
    final originalCompanies = state.companies;
    
    // 乐观更新：先更新本地状态
    final updatedCompanies = [...state.companies, company];
    state = state.copyWith(
      companies: updatedCompanies,
      isLoading: true,
    );

    try {
      // 调用API创建公司
      final createdCompanyJson = await _apiService.createCompany(company.toJson());
      final createdCompany = CompanyInfo.fromJson(createdCompanyJson);
      
      // 更新本地Hive存储
      await companyBox.put('companies', updatedCompanies.map((c) => c.toJson()).toList());
      
      // 更新状态，使用服务器返回的数据
      final finalCompanies = state.companies.map((c) => c.id == company.id ? createdCompany : c).toList();
      state = state.copyWith(
        companies: finalCompanies,
        isLoading: false,
      );
    } catch (e) {
      // API调用失败，恢复之前的状态
      state = state.copyWith(
        companies: originalCompanies,
        isLoading: false,
        error: '添加公司信息失败: $e',
      );
      // 重新加载数据，确保状态一致
      await _loadCompanies();
    }
  }

  Future<void> updateCompany(CompanyInfo company) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API更新公司
      await _apiService.updateCompany(company.id.toString(), company.toJson());
      
      // 更新本地Hive存储
      final updatedCompanies = state.companies.map((c) => c.id == company.id ? company : c).toList();
      await companyBox.put('companies', updatedCompanies.map((c) => c.toJson()).toList());
      
      // 更新状态
      state = state.copyWith(
        companies: updatedCompanies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新公司信息失败: $e',
      );
    }
  }

  Future<void> deleteCompany(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API删除公司
      await _apiService.deleteCompany(id.toString());
      
      // 更新本地Hive存储
      final updatedCompanies = state.companies.where((c) => c.id != id).toList();
      await companyBox.put('companies', updatedCompanies.map((c) => c.toJson()).toList());
      
      // 更新状态
      state = state.copyWith(
        companies: updatedCompanies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除公司信息失败: $e',
      );
    }
  }
}

final companyInfoBoxProvider = Provider<Box>((ref) {
  return Hive.box('company_info_box');
});

final companyInfoProvider = StateNotifierProvider<CompanyInfoNotifier, CompanyInfoState>((ref) {
  final box = ref.watch(companyInfoBoxProvider);
  final apiService = ref.watch(apiServiceProvider);
  return CompanyInfoNotifier(box, apiService);
});
