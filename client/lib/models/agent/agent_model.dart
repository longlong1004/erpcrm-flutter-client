import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'agent_model.g.dart';

// 智能体角色枚举
enum AgentRole {
  @JsonValue('smart_assistant')
  smartAssistant,
  @JsonValue('business_assistant')
  businessAssistant,
  @JsonValue('data_analysis_assistant')
  dataAnalysisAssistant,
  @JsonValue('system_management_assistant')
  systemManagementAssistant,
  @JsonValue('learning_assistant')
  learningAssistant,
  @JsonValue('tech_architect')
  techArchitect,
  @JsonValue('flutter_developer')
  flutterDeveloper,
  @JsonValue('ui_ux_designer')
  uiUxDesigner,
  @JsonValue('front_end_developer')
  frontEndDeveloper,
  @JsonValue('back_end_developer')
  backEndDeveloper,
  @JsonValue('database_administrator')
  databaseAdministrator,
  @JsonValue('test_engineer')
  testEngineer,
  @JsonValue('devops_engineer')
  devOpsEngineer,
  @JsonValue('project_manager')
  projectManager,
  @JsonValue('product_manager')
  productManager,
  @JsonValue('security_expert')
  securityExpert,
  @JsonValue('api_developer')
  apiDeveloper,
  @JsonValue('performance_optimization_engineer')
  performanceOptimizationEngineer,
  @JsonValue('compliance_officer')
  complianceOfficer,
  @JsonValue('documentation_engineer')
  documentationEngineer,
  @JsonValue('customer_support_specialist')
  customerSupportSpecialist,
  @JsonValue('mobile_development_expert')
  mobileDevelopmentExpert,
  @JsonValue('web_development_expert')
  webDevelopmentExpert,
  @JsonValue('desktop_application_developer')
  desktopApplicationDeveloper,
  @JsonValue('data_analysis_engineer')
  dataAnalysisEngineer,
  @JsonValue('system_integration_engineer')
  systemIntegrationEngineer,
}

// 智能体角色枚举适配器
class AgentRoleAdapter extends TypeAdapter<AgentRole> {
  @override
  final typeId = 13;

  @override
  AgentRole read(BinaryReader reader) {
    return AgentRole.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AgentRole obj) {
    writer.writeByte(obj.index);
  }
}

// 智能体状态枚举
enum AgentStatus {
  @JsonValue('enabled')
  enabled,
  @JsonValue('disabled')
  disabled,
  @JsonValue('updating')
  updating,
}

// 智能体状态枚举适配器
class AgentStatusAdapter extends TypeAdapter<AgentStatus> {
  @override
  final typeId = 14;

  @override
  AgentStatus read(BinaryReader reader) {
    return AgentStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AgentStatus obj) {
    writer.writeByte(obj.index);
  }
}

// 智能体能力模型
@HiveType(typeId: 10)
class AgentCapability extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  bool isEnabled;

  AgentCapability({
    String? id,
    String? name,
    required this.description,
    required this.isEnabled,
  }) : 
        id = id ?? 'capability_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}',
        name = name ?? description;


  AgentCapability copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
  }) {
    return AgentCapability(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// 智能体模型
@HiveType(typeId: 11)
class Agent extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final AgentRole role;
  @HiveField(4)
  AgentStatus status;
  @HiveField(5)
  final String icon;
  @HiveField(6)
  final List<AgentCapability> capabilities;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  DateTime updatedAt;

  Agent({
    required this.id,
    required this.name,
    required this.description,
    required this.role,
    required this.status,
    required this.icon,
    required this.capabilities,
    required this.createdAt,
    required this.updatedAt,
  });

  Agent copyWith({
    String? id,
    String? name,
    String? description,
    AgentRole? role,
    AgentStatus? status,
    String? icon,
    List<AgentCapability>? capabilities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      role: role ?? this.role,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      capabilities: capabilities ?? this.capabilities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 智能体配置模型
@HiveType(typeId: 12)
class AgentConfig extends HiveObject {
  @HiveField(0)
  bool isEnabled;
  @HiveField(1)
  String defaultAgentId;
  @HiveField(2)
  bool showAgentPanel;
  @HiveField(3)
  int maxAgentCount;
  @HiveField(4)
  DateTime updatedAt;

  AgentConfig({
    required this.isEnabled,
    required this.defaultAgentId,
    required this.showAgentPanel,
    required this.maxAgentCount,
    required this.updatedAt,
  });

  AgentConfig copyWith({
    bool? isEnabled,
    String? defaultAgentId,
    bool? showAgentPanel,
    int? maxAgentCount,
    DateTime? updatedAt,
  }) {
    return AgentConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      defaultAgentId: defaultAgentId ?? this.defaultAgentId,
      showAgentPanel: showAgentPanel ?? this.showAgentPanel,
      maxAgentCount: maxAgentCount ?? this.maxAgentCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
