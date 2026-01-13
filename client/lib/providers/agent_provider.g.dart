// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agentServiceHash() => r'34665a54e583aa7cf095e3e3f5c0eba61c979cd4';

/// 智能体服务Provider
///
/// Copied from [agentService].
@ProviderFor(agentService)
final agentServiceProvider = AutoDisposeProvider<AgentService>.internal(
  agentService,
  name: r'agentServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$agentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AgentServiceRef = AutoDisposeProviderRef<AgentService>;
String _$agentNotifierHash() => r'a3104631c6fa11fbf82388e1b3d3e48d5460e0e1';

/// 智能体状态管理Notifier
///
/// Copied from [AgentNotifier].
@ProviderFor(AgentNotifier)
final agentNotifierProvider =
    AutoDisposeNotifierProvider<AgentNotifier, AgentState>.internal(
  AgentNotifier.new,
  name: r'agentNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$agentNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AgentNotifier = AutoDisposeNotifier<AgentState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
