import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/approval_delegate_rule.dart';
import '../services/app_database.dart';
import '../providers/database_provider.dart';

// 审批代理规则的Notifier
class ApprovalDelegateNotifier extends Notifier<AsyncValue<List<ApprovalDelegateRule>>> {
  @override
  AsyncValue<List<ApprovalDelegateRule>> build() {
    // 初始化时立即获取数据
    fetchRules();
    return const AsyncLoading();
  }

  // 获取所有代理规则
  Future<void> fetchRules() async {
    debugPrint('开始获取代理规则...');
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      debugPrint('初始化数据库...');
      await db.init();
      
      // 优先从本地数据库获取
      debugPrint('从本地数据库获取规则...');
      final localRules = await db.getAllApprovalDelegateRules();
      debugPrint('获取到 ${localRules.length} 条规则，包括已删除的');
      final rules = localRules
          .where((rule) => rule.isDeleted == 0)
          .toList();
      debugPrint('过滤后获取到 ${rules.length} 条有效的代理规则');

      // 尝试从服务器同步数据
      // await syncRules();
      
      debugPrint('更新状态为 AsyncData');
      state = AsyncData(rules);
    } catch (e, stackTrace) {
      debugPrint('获取代理规则失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      state = AsyncError(e, stackTrace);
    }
  }

  // 创建代理规则
  Future<void> createRule(ApprovalDelegateRule rule) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 保存到本地数据库
      final now = DateTime.now();
      final newRule = rule.copyWith(
        createdAt: now,
        updatedAt: now,
        isDeleted: 0,
        syncStatus: 0, // 标记为未同步
      );
      await db.insertApprovalDelegateRule(newRule);

      // 刷新状态
      await fetchRules();

      // 尝试同步到服务器
      // await syncRules();
    } catch (e) {
      debugPrint('创建代理规则失败: $e');
      rethrow;
    }
  }

  // 更新代理规则
  Future<void> updateRule(ApprovalDelegateRule rule) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 更新本地数据库
      final now = DateTime.now();
      final updatedRule = rule.copyWith(
        updatedAt: now,
        syncStatus: 0, // 标记为未同步
      );
      await db.updateApprovalDelegateRule(updatedRule);

      // 刷新状态
      await fetchRules();

      // 尝试同步到服务器
      // await syncRules();
    } catch (e) {
      debugPrint('更新代理规则失败: $e');
      rethrow;
    }
  }

  // 删除代理规则
  Future<void> deleteRule(int id) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 标记为已删除
      final rule = await db.getApprovalDelegateRuleById(id);
      if (rule != null) {
        final updatedRule = rule.copyWith(
          isDeleted: 1,
          syncStatus: 0, // 标记为未同步
        );
        await db.updateApprovalDelegateRule(updatedRule);

        // 刷新状态
        await fetchRules();

        // 尝试同步到服务器
        // await syncRules();
      }
    } catch (e) {
      debugPrint('删除代理规则失败: $e');
      rethrow;
    }
  }

  // 获取当前有效的代理规则
  Future<ApprovalDelegateRule?> getCurrentDelegate(int originalApproverId) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      final now = DateTime.now();
      // 先从本地查询
      final allRules = await db.getAllApprovalDelegateRules();
      final localRule = allRules.firstWhereOrNull((rule) =>
          rule.originalApproverId == originalApproverId &&
          rule.startTime.isBefore(now) &&
          rule.endTime.isAfter(now) &&
          rule.status == 1 &&
          rule.isDeleted == 0);

      return localRule;
    } catch (e) {
      debugPrint('获取当前代理规则失败: $e');
      return null;
    }
  }

  // 获取所有替换规则
  Future<List<ApprovalDelegateRule>> getAllDelegateRules() async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 获取所有规则，包括已失效和已删除的
      final allRules = await db.getAllApprovalDelegateRules();
      // 过滤掉已删除的规则
      return allRules.where((rule) => rule.isDeleted == 0).toList();
    } catch (e) {
      debugPrint('获取所有替换规则失败: $e');
      return [];
    }
  }

  // 获取有效替换规则
  Future<List<ApprovalDelegateRule>> getValidDelegateRules() async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      final now = DateTime.now();
      // 获取所有规则
      final allRules = await db.getAllApprovalDelegateRules();
      // 过滤出有效的规则
      return allRules.where((rule) =>
          rule.status == 1 &&
          rule.isDeleted == 0 &&
          now.isAfter(rule.startTime) &&
          now.isBefore(rule.endTime)).toList();
    } catch (e) {
      debugPrint('获取有效替换规则失败: $e');
      return [];
    }
  }

  // 关联替换规则到审批流程
  Future<void> associateRuleWithProcess(int ruleId, String processId) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 获取规则
      final rule = await db.getApprovalDelegateRuleById(ruleId);
      if (rule != null) {
        // 添加关联的流程ID
        final processIds = List<String>.from(rule.processIds ?? []);
        if (!processIds.contains(processId)) {
          processIds.add(processId);
          // 更新规则
          await db.updateApprovalDelegateRule(rule.copyWith(processIds: processIds));
        }
      }
    } catch (e) {
      debugPrint('关联替换规则到审批流程失败: $e');
      rethrow;
    }
  }

  // 从审批流程解除关联替换规则
  Future<void> disassociateRuleFromProcess(int ruleId, String processId) async {
    try {
      final db = ref.read(databaseProvider);
      // 确保数据库已初始化
      await db.init();
      
      // 获取规则
      final rule = await db.getApprovalDelegateRuleById(ruleId);
      if (rule != null) {
        // 移除关联的流程ID
        final processIds = List<String>.from(rule.processIds ?? []);
        if (processIds.contains(processId)) {
          processIds.remove(processId);
          // 更新规则
          await db.updateApprovalDelegateRule(rule.copyWith(processIds: processIds));
        }
      }
    } catch (e) {
      debugPrint('从审批流程解除关联替换规则失败: $e');
      rethrow;
    }
  }
}

// 用于控制代理规则表单的状态
class ApprovalDelegateFormNotifier extends StateNotifier<ApprovalDelegateRule> {
  ApprovalDelegateFormNotifier()
      : super(ApprovalDelegateRule(
            originalApproverId: 0,
            originalApproverName: '',
            delegateApproverId: 0,
            delegateApproverName: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            status: 1,
            description: '',
            isDeleted: 0,
            syncStatus: 0,
          ));

  void updateOriginalApprover(int id, String name) {
    state = state.copyWith(
      originalApproverId: id,
      originalApproverName: name,
    );
  }

  void updateDelegateApprover(int id, String name) {
    state = state.copyWith(
      delegateApproverId: id,
      delegateApproverName: name,
    );
  }

  void updateTimeRange(DateTime startTime, DateTime endTime) {
    state = state.copyWith(
      startTime: startTime,
      endTime: endTime,
    );
  }

  void updateStatus(int status) {
    state = state.copyWith(status: status);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void reset() {
    state = ApprovalDelegateRule(
      originalApproverId: 0,
      originalApproverName: '',
      delegateApproverId: 0,
      delegateApproverName: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: 1,
      description: '',
      isDeleted: 0,
      syncStatus: 0,
    );
  }
}

// 定义provider
final approvalDelegateNotifierProvider = NotifierProvider<ApprovalDelegateNotifier, AsyncValue<List<ApprovalDelegateRule>>>(() {
  return ApprovalDelegateNotifier();
});

final approvalDelegateFormProvider = StateNotifierProvider<ApprovalDelegateFormNotifier, ApprovalDelegateRule>((ref) {
  return ApprovalDelegateFormNotifier();
});
