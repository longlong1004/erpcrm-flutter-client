import 'package:hive_flutter/hive_flutter.dart';
import '../models/agent/agent_model.dart';

/// 智能体服务类，用于管理智能体的CRUD操作
class AgentService {
  static final AgentService _instance = AgentService._internal();
  late Box<Agent> _agentBox;
  late Box _agentConfigBox;

  factory AgentService() {
    return _instance;
  }

  AgentService._internal();

  /// 初始化智能体服务
  Future<void> init() async {
    _agentBox = Hive.box<Agent>('agents_box');
    _agentConfigBox = Hive.box('agent_config_box');
  }

  /// 获取所有智能体
  List<Agent> getAllAgents() {
    return _agentBox.values.toList();
  }

  /// 根据ID获取智能体
  Agent? getAgentById(String id) {
    return _agentBox.get(id);
  }

  /// 添加智能体
  Future<void> addAgent(Agent agent) async {
    await _agentBox.put(agent.id, agent);
  }

  /// 批量添加智能体
  Future<void> addAgents(List<Agent> agents) async {
    final Map<String, Agent> agentMap = {
      for (var agent in agents) agent.id: agent
    };
    await _agentBox.putAll(agentMap);
  }

  /// 更新智能体
  Future<void> updateAgent(Agent agent) async {
    await _agentBox.put(agent.id, agent);
  }

  /// 删除智能体
  Future<void> deleteAgent(String id) async {
    await _agentBox.delete(id);
  }

  /// 清空所有智能体
  Future<void> clearAllAgents() async {
    await _agentBox.clear();
  }

  /// 获取智能体配置
  AgentConfig getAgentConfig() {
    final config = _agentConfigBox.get('agent_config');
    if (config != null && config is AgentConfig) {
      return config;
    }
    // 返回默认配置
    return AgentConfig(
      isEnabled: true,
      defaultAgentId: '',
      showAgentPanel: true,
      maxAgentCount: 100,
      updatedAt: DateTime.now(),
    );
  }

  /// 更新智能体配置
  Future<void> updateAgentConfig(AgentConfig config) async {
    await _agentConfigBox.put('agent_config', config);
  }

  /// 初始化58名团队智能体
  Future<void> initializeTeamAgents() async {
    // 检查是否已初始化
    if (_agentBox.isNotEmpty) {
      return;
    }

    // 定义团队智能体角色映射
    final roleMap = {
      '技术架构师': AgentRole.techArchitect,
      'Flutter开发工程师': AgentRole.flutterDeveloper,
      'UI/UX设计师': AgentRole.uiUxDesigner,
      '前端开发工程师': AgentRole.frontEndDeveloper,
      '后端开发工程师': AgentRole.backEndDeveloper,
      '数据库管理员': AgentRole.databaseAdministrator,
      '测试工程师': AgentRole.testEngineer,
      'DevOps工程师': AgentRole.devOpsEngineer,
      '项目管理师': AgentRole.projectManager,
      '产品经理': AgentRole.productManager,
      '安全专家': AgentRole.securityExpert,
      'API开发工程师': AgentRole.apiDeveloper,
      '性能优化工程师': AgentRole.performanceOptimizationEngineer,
      '合规专员': AgentRole.complianceOfficer,
      '文档工程师': AgentRole.documentationEngineer,
      '客户支持专员': AgentRole.customerSupportSpecialist,
      '移动开发专家': AgentRole.mobileDevelopmentExpert,
      'Web开发专家': AgentRole.webDevelopmentExpert,
      '桌面应用开发专家': AgentRole.desktopApplicationDeveloper,
      '数据分析工程师': AgentRole.dataAnalysisEngineer,
      '系统集成工程师': AgentRole.systemIntegrationEngineer,
    };

    // 定义团队智能体能力映射
    final capabilityMap = {
      '技术架构师': [
        AgentCapability(
          id: 'cap_arch_1',
          name: '系统架构设计',
          description: '设计复杂系统的架构',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_arch_2',
          name: '技术选型',
          description: '选择合适的技术栈',
          isEnabled: true,
        ),
      ],
      'Flutter开发工程师': [
        AgentCapability(
          id: 'cap_flutter_1',
          name: '跨平台开发',
          description: '开发跨平台Flutter应用',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_flutter_2',
          name: 'UI组件开发',
          description: '开发高质量UI组件',
          isEnabled: true,
        ),
      ],
      'UI/UX设计师': [
        AgentCapability(
          id: 'cap_ui_1',
          name: '界面设计',
          description: '设计美观易用的界面',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_ui_2',
          name: '用户体验优化',
          description: '优化用户体验',
          isEnabled: true,
        ),
      ],
      '前端开发工程师': [
        AgentCapability(
          id: 'cap_frontend_1',
          name: 'Web界面开发',
          description: '开发Web界面',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_frontend_2',
          name: '前端框架应用',
          description: '应用前端框架开发',
          isEnabled: true,
        ),
      ],
      '后端开发工程师': [
        AgentCapability(
          id: 'cap_backend_1',
          name: 'API开发',
          description: '开发RESTful API',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_backend_2',
          name: '业务逻辑实现',
          description: '实现业务逻辑',
          isEnabled: true,
        ),
      ],
      '数据库管理员': [
        AgentCapability(
          id: 'cap_db_1',
          name: '数据库设计',
          description: '设计数据库结构',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_db_2',
          name: '数据库优化',
          description: '优化数据库性能',
          isEnabled: true,
        ),
      ],
      '测试工程师': [
        AgentCapability(
          id: 'cap_test_1',
          name: '测试用例设计',
          description: '设计测试用例',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_test_2',
          name: '自动化测试',
          description: '实现自动化测试',
          isEnabled: true,
        ),
      ],
      'DevOps工程师': [
        AgentCapability(
          id: 'cap_devops_1',
          name: 'CI/CD配置',
          description: '配置持续集成/持续部署',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_devops_2',
          name: '容器化部署',
          description: '使用容器化技术部署应用',
          isEnabled: true,
        ),
      ],
      '项目管理师': [
        AgentCapability(
          id: 'cap_pm_1',
          name: '项目规划',
          description: '规划项目进度和资源',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_pm_2',
          name: '团队协调',
          description: '协调团队成员工作',
          isEnabled: true,
        ),
      ],
      '产品经理': [
        AgentCapability(
          id: 'cap_product_1',
          name: '需求分析',
          description: '分析用户需求',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_product_2',
          name: '产品设计',
          description: '设计产品功能和流程',
          isEnabled: true,
        ),
      ],
      '安全专家': [
        AgentCapability(
          id: 'cap_security_1',
          name: '安全审计',
          description: '进行系统安全审计',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_security_2',
          name: '漏洞修复',
          description: '修复系统安全漏洞',
          isEnabled: true,
        ),
      ],
      'API开发工程师': [
        AgentCapability(
          id: 'cap_api_1',
          name: 'API设计',
          description: '设计RESTful API',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_api_2',
          name: 'API文档编写',
          description: '编写API文档',
          isEnabled: true,
        ),
      ],
      '性能优化工程师': [
        AgentCapability(
          id: 'cap_perf_1',
          name: '性能分析',
          description: '分析系统性能瓶颈',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_perf_2',
          name: '性能优化',
          description: '优化系统性能',
          isEnabled: true,
        ),
      ],
      '合规专员': [
        AgentCapability(
          id: 'cap_compliance_1',
          name: '合规检查',
          description: '检查系统是否符合法规要求',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_compliance_2',
          name: '合规文档编写',
          description: '编写合规文档',
          isEnabled: true,
        ),
      ],
      '文档工程师': [
        AgentCapability(
          id: 'cap_doc_1',
          name: '技术文档编写',
          description: '编写技术文档',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_doc_2',
          name: '用户手册编写',
          description: '编写用户手册',
          isEnabled: true,
        ),
      ],
      '客户支持专员': [
        AgentCapability(
          id: 'cap_support_1',
          name: '客户问题处理',
          description: '处理客户反馈的问题',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_support_2',
          name: '客户培训',
          description: '培训客户使用系统',
          isEnabled: true,
        ),
      ],
      '移动开发专家': [
        AgentCapability(
          id: 'cap_mobile_1',
          name: '移动端开发',
          description: '开发移动应用',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_mobile_2',
          name: '移动端优化',
          description: '优化移动应用性能',
          isEnabled: true,
        ),
      ],
      'Web开发专家': [
        AgentCapability(
          id: 'cap_web_1',
          name: 'Web应用开发',
          description: '开发Web应用',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_web_2',
          name: 'Web性能优化',
          description: '优化Web应用性能',
          isEnabled: true,
        ),
      ],
      '桌面应用开发专家': [
        AgentCapability(
          id: 'cap_desktop_1',
          name: '桌面应用开发',
          description: '开发桌面应用',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_desktop_2',
          name: '桌面应用优化',
          description: '优化桌面应用性能',
          isEnabled: true,
        ),
      ],
      '数据分析工程师': [
        AgentCapability(
          id: 'cap_data_1',
          name: '数据建模',
          description: '建立数据分析模型',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_data_2',
          name: '数据可视化',
          description: '可视化展示数据分析结果',
          isEnabled: true,
        ),
      ],
      '系统集成工程师': [
        AgentCapability(
          id: 'cap_integration_1',
          name: '系统集成设计',
          description: '设计系统集成方案',
          isEnabled: true,
        ),
        AgentCapability(
          id: 'cap_integration_2',
          name: '系统集成实现',
          description: '实现系统集成',
          isEnabled: true,
        ),
      ],
    };

    // 定义团队智能体数量
    final agentCounts = {
      '技术架构师': 3,
      'Flutter开发工程师': 5,
      'UI/UX设计师': 3,
      '前端开发工程师': 3,
      '后端开发工程师': 5,
      '数据库管理员': 3,
      '测试工程师': 3,
      'DevOps工程师': 3,
      '项目管理师': 2,
      '产品经理': 3,
      '安全专家': 3,
      'API开发工程师': 3,
      '性能优化工程师': 3,
      '合规专员': 2,
      '文档工程师': 2,
      '客户支持专员': 2,
      '移动开发专家': 2,
      'Web开发专家': 2,
      '桌面应用开发专家': 2,
      '数据分析工程师': 3,
      '系统集成工程师': 3,
    };

    // 创建团队智能体
    final agents = <Agent>[];
    int agentId = 1;

    agentCounts.forEach((roleName, count) {
      for (int i = 1; i <= count; i++) {
        final agent = Agent(
          id: 'agent_$agentId',
          name: '$roleName $i',
          description: '负责${roleName}相关工作的智能体',
          role: roleMap[roleName] ?? AgentRole.smartAssistant,
          status: AgentStatus.enabled,
          icon: 'agent_${roleName.toLowerCase().replaceAll(' ', '_')}',
          capabilities: capabilityMap[roleName] ?? [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        agents.add(agent);
        agentId++;
      }
    });

    // 批量添加智能体
    await addAgents(agents);
  }
}