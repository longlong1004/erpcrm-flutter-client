import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/agent/agent_model.dart';
import 'package:erpcrm_client/providers/agent_provider.dart';

/// 智能体配置界面
class AgentConfigurationScreen extends ConsumerStatefulWidget {
  const AgentConfigurationScreen({super.key});

  @override
  ConsumerState<AgentConfigurationScreen> createState() => _AgentConfigurationScreenState();
}

class _AgentConfigurationScreenState extends ConsumerState<AgentConfigurationScreen> {
  @override
  void initState() {
    super.initState();
    // 加载智能体数据
    ref.read(agentNotifierProvider.notifier).loadAgents();
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(agentNotifierProvider);
    final agents = agentState.agents;
    final config = agentState.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('智能体配置'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Text(
              '智能体配置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),

            // 操作信息提示
            if (agentState.operationMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    agentState.operationMessage!, 
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ),

            // 错误信息提示
            if (agentState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    agentState.error!, 
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),

            // 智能体开关
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '启用智能体功能',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '开启或关闭系统中的所有智能体功能',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: config.isEnabled,
                      onChanged: (value) {
                        ref.read(agentNotifierProvider.notifier).toggleAgentEnabled(value);
                      },
                      activeColor: const Color(0xFF003366),
                    ),
                  ],
                ),
              ),
            ),

            // 智能体统计信息
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${agents.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '总智能体数',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${agents.where((a) => a.status == AgentStatus.enabled).length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '已启用',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${agents.where((a) => a.status == AgentStatus.disabled).length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '已禁用',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 初始化团队智能体按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(agentNotifierProvider.notifier).initializeTeamAgents();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('初始化团队智能体'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 智能体列表
            Expanded(
              child: agentState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : agents.isEmpty
                      ? const Center(
                          child: Text(
                            '暂无智能体数据',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: agents.length,
                          itemBuilder: (context, index) {
                            final agent = agents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 智能体基本信息
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                agent.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                agent.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '角色: ${_getRoleName(agent.role)}',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 智能体状态开关
                                        Switch(
                                          value: agent.status == AgentStatus.enabled,
                                          onChanged: (value) {
                                            ref.read(agentNotifierProvider.notifier).toggleAgentStatus(agent.id, value);
                                          },
                                          activeColor: const Color(0xFF003366),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 智能体能力列表
                                    Text(
                                      '能力列表',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: agent.capabilities.map((capability) {
                                        return Chip(
                                          label: Text(capability.name),
                                          backgroundColor: capability.isEnabled ? Colors.blue[50] : Colors.grey[100],
                                          labelStyle: TextStyle(
                                            color: capability.isEnabled ? const Color(0xFF1E88E5) : Colors.grey[600],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取智能体角色名称
  String _getRoleName(AgentRole role) {
    switch (role) {
      case AgentRole.smartAssistant:
        return '智能助手';
      case AgentRole.businessAssistant:
        return '业务助手';
      case AgentRole.dataAnalysisAssistant:
        return '数据分析助手';
      case AgentRole.systemManagementAssistant:
        return '系统管理助手';
      case AgentRole.learningAssistant:
        return '学习助手';
      case AgentRole.techArchitect:
        return '技术架构师';
      case AgentRole.flutterDeveloper:
        return 'Flutter开发工程师';
      case AgentRole.uiUxDesigner:
        return 'UI/UX设计师';
      case AgentRole.frontEndDeveloper:
        return '前端开发工程师';
      case AgentRole.backEndDeveloper:
        return '后端开发工程师';
      case AgentRole.databaseAdministrator:
        return '数据库管理员';
      case AgentRole.testEngineer:
        return '测试工程师';
      case AgentRole.devOpsEngineer:
        return 'DevOps工程师';
      case AgentRole.projectManager:
        return '项目管理师';
      case AgentRole.productManager:
        return '产品经理';
      case AgentRole.securityExpert:
        return '安全专家';
      case AgentRole.apiDeveloper:
        return 'API开发工程师';
      case AgentRole.performanceOptimizationEngineer:
        return '性能优化工程师';
      case AgentRole.complianceOfficer:
        return '合规专员';
      case AgentRole.documentationEngineer:
        return '文档工程师';
      case AgentRole.customerSupportSpecialist:
        return '客户支持专员';
      case AgentRole.mobileDevelopmentExpert:
        return '移动开发专家';
      case AgentRole.webDevelopmentExpert:
        return 'Web开发专家';
      case AgentRole.desktopApplicationDeveloper:
        return '桌面应用开发专家';
      case AgentRole.dataAnalysisEngineer:
        return '数据分析工程师';
      case AgentRole.systemIntegrationEngineer:
        return '系统集成工程师';
      default:
        return '未知角色';
    }
  }
}
