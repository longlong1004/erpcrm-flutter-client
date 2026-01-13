import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/agent_service.dart';
import '../models/agent/agent_model.dart';

part 'agent_provider.g.dart';

/// 智能体服务Provider
@riverpod
AgentService agentService(AgentServiceRef ref) {
  return AgentService();
}

/// 智能体状态
class AgentState {
  final List<Agent> agents;
  final bool isLoading;
  final String? error;
  final AgentConfig config;
  final bool isSaving;
  final String? operationMessage;

  AgentState({
    required this.agents,
    this.isLoading = false,
    this.error,
    required this.config,
    this.isSaving = false,
    this.operationMessage,
  });

  AgentState copyWith({
    List<Agent>? agents,
    bool? isLoading,
    String? error,
    AgentConfig? config,
    bool? isSaving,
    String? operationMessage,
  }) {
    return AgentState(
      agents: agents ?? this.agents,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
      isSaving: isSaving ?? this.isSaving,
      operationMessage: operationMessage ?? this.operationMessage,
    );
  }
}

/// 智能体状态管理Notifier
@riverpod
class AgentNotifier extends _$AgentNotifier {
  @override
  AgentState build() {
    final service = ref.watch(agentServiceProvider);
    return AgentState(
      agents: service.getAllAgents(),
      config: service.getAgentConfig(),
    );
  }

  /// 加载所有智能体
  Future<void> loadAgents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.watch(agentServiceProvider);
      final agents = service.getAllAgents();
      state = state.copyWith(agents: agents, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载智能体失败: $e', isLoading: false);
    }
  }

  /// 切换智能体状态
  Future<void> toggleAgentStatus(String agentId, bool isEnabled) async {
    state = state.copyWith(isSaving: true, error: null, operationMessage: '正在更新智能体状态...');
    try {
      final service = ref.watch(agentServiceProvider);
      final agent = service.getAgentById(agentId);
      if (agent != null) {
        final updatedAgent = agent.copyWith(
          status: isEnabled ? AgentStatus.enabled : AgentStatus.disabled,
          updatedAt: DateTime.now(),
        );
        await service.updateAgent(updatedAgent);
        await loadAgents();
        state = state.copyWith(
          isSaving: false,
          operationMessage: '智能体状态更新成功',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: '更新智能体状态失败: $e',
        operationMessage: null,
      );
    }
  }

  /// 切换智能体功能开关
  Future<void> toggleAgentEnabled(bool isEnabled) async {
    state = state.copyWith(isSaving: true, error: null, operationMessage: '正在更新智能体配置...');
    try {
      final service = ref.watch(agentServiceProvider);
      final updatedConfig = state.config.copyWith(
        isEnabled: isEnabled,
        updatedAt: DateTime.now(),
      );
      await service.updateAgentConfig(updatedConfig);
      state = state.copyWith(
        config: updatedConfig,
        isSaving: false,
        operationMessage: '智能体配置更新成功',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: '更新智能体配置失败: $e',
        operationMessage: null,
      );
    }
  }

  /// 初始化团队智能体
  Future<void> initializeTeamAgents() async {
    state = state.copyWith(isLoading: true, error: null, operationMessage: '正在初始化团队智能体...');
    try {
      final service = ref.watch(agentServiceProvider);
      await service.initializeTeamAgents();
      await loadAgents();
      state = state.copyWith(
        isLoading: false,
        operationMessage: '团队智能体初始化成功',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '初始化团队智能体失败: $e',
        operationMessage: null,
      );
    }
  }
}