import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/app.dart';
import 'package:erpcrm_client/utils/storage.dart';
import 'package:erpcrm_client/utils/http_client.dart';
import 'package:erpcrm_client/services/network_service.dart';
import 'package:erpcrm_client/services/local_storage_service.dart';
import 'package:erpcrm_client/services/agent_service.dart';
import 'package:erpcrm_client/data/database/system_factory_database.dart';
import 'package:erpcrm_client/models/settings/system_parameter.dart';
import 'package:erpcrm_client/models/settings/operation_log.dart';
import 'package:erpcrm_client/models/settings/data_dictionary.dart';
import 'package:erpcrm_client/models/agent/agent_model.dart';
import 'package:erpcrm_client/models/tab_item.dart';
import 'package:collection/collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive本地存储
  // Web平台使用默认IndexedDB存储，其他平台使用自定义路径
  if (!kIsWeb) {
    String path = Directory.current.path;
    await Hive.initFlutter(path + '/hive_data');
  } else {
    await Hive.initFlutter();
  }
  
  // 注册智能体相关的Hive适配器
  Hive.registerAdapter(AgentCapabilityAdapter());
  Hive.registerAdapter(AgentAdapter());
  Hive.registerAdapter(AgentConfigAdapter());
  Hive.registerAdapter(AgentRoleAdapter());
  Hive.registerAdapter(AgentStatusAdapter());
  
  // 注册系统扩展工厂相关的Hive适配器
  Hive.registerAdapter(SysUiConfigAdapter());
  Hive.registerAdapter(SysMenuConfigAdapter());
  
  // 注册系统设置相关的Hive适配器
  Hive.registerAdapter(OperationLogAdapter());
  Hive.registerAdapter(SystemParameterAdapter());
  Hive.registerAdapter(DataDictionaryAdapter());
  Hive.registerAdapter(TabItemAdapter());
  
  // 尝试打开Hive box，如果失败则重试
  Future<void> tryOpenBox(String name) async {
    const maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        await Hive.openBox(name);
        return;
      } catch (e) {
        print('尝试打开box $name 失败 (${i+1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          print('打开box $name 最终失败');
        }
      }
    }
  }

  Future<void> tryOpenBoxWithType<T extends HiveObject>(String name) async {
    const maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        await Hive.openBox<T>(name);
        return;
      } catch (e) {
        print('尝试打开带类型的box $name 失败 (${i+1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          print('打开带类型的box $name 最终失败');
        }
      }
    }
  }

  // 执行box打开操作
  await tryOpenBox('user_box');
  await tryOpenBox('settings_box');
  
  // 系统扩展工厂相关的Hive box
  await tryOpenBoxWithType<SysUiConfig>('sysUiConfigs');
  await tryOpenBoxWithType<SysMenuConfig>('sysMenuConfigs');
  // 基本信息模块所需的Hive box
  await tryOpenBox('company_info_box');
  await tryOpenBox('railway_station_box');
  await tryOpenBox('contact_info_box');
  await tryOpenBox('supplier_info_box');
  await tryOpenBox('unit_box');
  await tryOpenBox('category_box');
  await tryOpenBox('tax_category_box');
  await tryOpenBox('template_box');
  await tryOpenBox('employee_box');
  await tryOpenBox('department_box');
  await tryOpenBox('position_box');
  // 智能体相关的Hive box
  await tryOpenBox('agent_config_box');
  await tryOpenBoxWithType<Agent>('agents_box');
  
  // 标签页相关的Hive box
  await tryOpenBoxWithType<TabItem>('tabs');
  
  // 初始化存储管理器
  await StorageManager.init();
  
  // 初始化HTTP客户端
  await HttpClient.init();
  
  // 初始化网络服务
  final networkService = NetworkService();
  await networkService.initialize();
  
  // 初始化本地存储服务
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  
  runApp(
    const ProviderScope(
      child: ErpCrmApp(),
    ),
  );

  // 初始化智能体服务（移到runApp之后，确保UI能正常显示）
  final agentService = AgentService();
  await agentService.init();
  try {
    await agentService.initializeTeamAgents();
  } catch (e) {
    print('初始化智能体团队失败: $e');
    // 忽略错误，确保应用程序能正常运行
  }
}
