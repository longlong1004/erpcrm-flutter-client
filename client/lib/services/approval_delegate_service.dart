import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/approval_delegate_rule.dart';
import '../models/process/process_models.dart';
import '../models/process/approval_delegate_log.dart';
import '../services/app_database.dart';
import '../providers/database_provider.dart';

// 审批人替换服务
class ApprovalDelegateService {
  final Ref ref;
  Timer? _timer;
  static const Duration _checkInterval = Duration(minutes: 5); // 每5分钟检查一次

  ApprovalDelegateService(this.ref);

  // 启动定时检查服务
  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(_checkInterval, (timer) {
      _checkAndReplaceApprovers();
    });
    // 立即执行一次检查
    _checkAndReplaceApprovers();
  }

  // 停止定时检查服务
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  // 检查并替换审批人
  Future<void> _checkAndReplaceApprovers() async {
    debugPrint('开始检查审批人替换规则...');
    try {
      final db = ref.read(databaseProvider);
      await db.init();

      // 获取所有有效的替换规则
      final rules = await db.getAllApprovalDelegateRules();
      final validRules = rules.where((rule) => 
        rule.status == 1 && 
        rule.isDeleted == 0 &&
        DateTime.now().isAfter(rule.startTime) &&
        DateTime.now().isBefore(rule.endTime)
      ).toList();

      debugPrint('找到 ${validRules.length} 条有效替换规则');

      // 获取所有激活状态的审批流程
      // TODO: 从数据库获取所有激活的审批流程
      final activeProcesses = <Process>[];

      // 遍历每个规则，检查是否需要替换审批人
      for (final rule in validRules) {
        await _processDelegateRule(rule, activeProcesses);
      }
    } catch (e) {
      debugPrint('检查审批人替换规则失败: $e');
    }
  }

  // 处理单个替换规则
  Future<void> _processDelegateRule(ApprovalDelegateRule rule, List<Process> activeProcesses) async {
    try {
      final db = ref.read(databaseProvider);
      
      // 确定要处理的流程
      List<Process> targetProcesses;
      if (rule.isGlobal) {
        // 全局规则，应用于所有激活的流程
        targetProcesses = activeProcesses;
      } else if (rule.processIds != null && rule.processIds!.isNotEmpty) {
        // 特定流程规则，只应用于指定的流程
        targetProcesses = activeProcesses.where((p) => 
          rule.processIds!.contains(p.id)
        ).toList();
      } else {
        // 没有指定流程，跳过
        return;
      }

      debugPrint('规则 ${rule.id} 将应用于 ${targetProcesses.length} 个流程');

      // 遍历每个流程，处理替换
      for (final process in targetProcesses) {
        await _processProcessDelegate(rule, process);
      }
    } catch (e) {
      debugPrint('处理替换规则 ${rule.id} 失败: $e');
    }
  }

  // 处理单个流程的替换
  Future<void> _processProcessDelegate(ApprovalDelegateRule rule, Process process) async {
    try {
      final db = ref.read(databaseProvider);
      
      // 遍历流程中的每个审批节点
      for (final node in process.nodes) {
        if (node.type == NodeType.approval && node.approvalRule != null) {
          // 检查节点是否在规则指定的节点列表中
          if (rule.nodeIds != null && rule.nodeIds!.isNotEmpty && !rule.nodeIds!.contains(node.id)) {
            continue;
          }

          // 检查审批规则中是否包含原审批人
          if (node.approvalRule!.approverIds.any((id) => 
            int.tryParse(id) == rule.originalApproverId
          )) {
            // 需要替换审批人
            await _replaceApproverInNode(rule, process, node);
          }
        }
      }
    } catch (e) {
      debugPrint('处理流程 ${process.id} 的替换失败: $e');
    }
  }

  // 替换节点中的审批人
  Future<void> _replaceApproverInNode(ApprovalDelegateRule rule, Process process, ProcessNode node) async {
    try {
      final db = ref.read(databaseProvider);
      
      // 创建新的审批规则，替换审批人
      final oldApproverId = rule.originalApproverId.toString();
      final newApproverId = rule.delegateApproverId.toString();
      
      final newApproverIds = node.approvalRule!.approverIds.map((id) {
        if (id == oldApproverId) {
          return newApproverId;
        }
        return id;
      }).toList();
      
      final newApproverNames = node.approvalRule!.approverNames.map((name) {
        if (name == rule.originalApproverName) {
          return rule.delegateApproverName;
        }
        return name;
      }).toList();
      
      final newApprovalRule = node.approvalRule!.copyWith(
        approverIds: newApproverIds,
        approverNames: newApproverNames,
      );
      
      // 创建新的节点
      final newNode = node.copyWith(
        approvalRule: newApprovalRule,
      );
      
      // 更新流程中的节点
      final updatedNodes = process.nodes.map((n) {
        if (n.id == node.id) {
          return newNode;
        }
        return n;
      }).toList();
      
      // 更新流程
      final updatedProcess = process.copyWith(
        nodes: updatedNodes,
      );
      
      // TODO: 保存更新后的流程到数据库
      
      // 记录替换日志
      final log = ApprovalDelegateLog(
        originalApproverId: rule.originalApproverId,
        originalApproverName: rule.originalApproverName,
        delegateApproverId: rule.delegateApproverId,
        delegateApproverName: rule.delegateApproverName,
        processId: process.id,
        processName: process.name,
        nodeId: node.id,
        nodeName: node.name,
        replaceTime: DateTime.now(),
        triggerRuleId: rule.id ?? 0,
        triggerRuleName: rule.description ?? '无规则名称',
        status: 'success',
        description: '根据时间规则自动替换审批人',
      );
      
      // TODO: 保存日志到数据库
      
      debugPrint('成功替换流程 ${process.id} 节点 ${node.id} 的审批人: ${rule.originalApproverName} -> ${rule.delegateApproverName}');
    } catch (e) {
      debugPrint('替换节点 ${node.id} 中的审批人失败: $e');
      
      // 记录失败日志
      final log = ApprovalDelegateLog(
        originalApproverId: rule.originalApproverId,
        originalApproverName: rule.originalApproverName,
        delegateApproverId: rule.delegateApproverId,
        delegateApproverName: rule.delegateApproverName,
        processId: process.id,
        processName: process.name,
        nodeId: node.id,
        nodeName: node.name,
        replaceTime: DateTime.now(),
        triggerRuleId: rule.id ?? 0,
        triggerRuleName: rule.description ?? '无规则名称',
        status: 'failed',
        description: '替换失败: $e',
      );
      
      // TODO: 保存日志到数据库
    }
  }

  // 手动触发审批人替换
  Future<void> manuallyReplaceApprover(ApprovalDelegateRule rule, Process process) async {
    await _processProcessDelegate(rule, [process]);
  }

  // 获取审批人替换日志
  Future<List<ApprovalDelegateLog>> getDelegateLogs({
    DateTime? startTime,
    DateTime? endTime,
    String? processId,
    int? originalApproverId,
    int? delegateApproverId,
    String? status,
    int? page = 1,
    int? pageSize = 20,
  }) async {
    try {
      final db = ref.read(databaseProvider);
      await db.init();
      
      // TODO: 从数据库获取日志
      return [];
    } catch (e) {
      debugPrint('获取审批人替换日志失败: $e');
      return [];
    }
  }

  // 导出审批人替换日志
  Future<List<Map<String, dynamic>>> exportDelegateLogs({
    DateTime? startTime,
    DateTime? endTime,
    String? processId,
    int? originalApproverId,
    int? delegateApproverId,
    String? status,
  }) async {
    try {
      final logs = await getDelegateLogs(
        startTime: startTime,
        endTime: endTime,
        processId: processId,
        originalApproverId: originalApproverId,
        delegateApproverId: delegateApproverId,
        status: status,
        page: 1,
        pageSize: 10000, // 导出时获取所有数据
      );
      
      return logs.map((log) => log.toJson()).toList();
    } catch (e) {
      debugPrint('导出审批人替换日志失败: $e');
      return [];
    }
  }

  // 验证审批人替换数据一致性
  Future<bool> validateDelegateDataConsistency() async {
    try {
      final db = ref.read(databaseProvider);
      await db.init();
      
      // TODO: 实现数据一致性验证逻辑
      return true;
    } catch (e) {
      debugPrint('验证审批人替换数据一致性失败: $e');
      return false;
    }
  }
}

// 审批人替换服务Provider
final approvalDelegateServiceProvider = Provider<ApprovalDelegateService>((ref) {
  final service = ApprovalDelegateService(ref);
  // 自动启动定时服务
  service.startTimer();
  
  // 当Provider被销毁时停止服务
  ref.onDispose(() {
    service.stopTimer();
  });
  
  return service;
});
