import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/system_factory_provider.dart';
import '../data/database/system_factory_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/error_handler_service.dart';
import '../services/message_service.dart';

// 定义字体大小常量
const kFontSizeXXL = 24.0;
const kFontSizeXL = 20.0;
const kFontSizeL = 18.0;
const kFontSizeM = 16.0;
const kFontSizeS = 14.0;
const kFontSizeXS = 12.0;

// 定义间距常量
const kSpacingXXS = 4.0;
const kSpacingXS = 8.0;
const kSpacingS = 16.0;
const kSpacingM = 24.0;
const kSpacingL = 32.0;
const kSpacingXL = 40.0;

// 定义圆角常量
const kBorderRadiusS = 4.0;
const kBorderRadiusM = 8.0;
const kBorderRadiusL = 12.0;

// 定义颜色常量
const kPrimaryColor = Colors.blue;
const kSecondaryColor = Colors.orange;
const kDangerColor = Colors.red;
const kSuccessColor = Colors.green;
const kWarningColor = Colors.yellow;
const kTextPrimary = Colors.black87;
const kTextSecondary = Colors.black54;
const kTextTertiary = Colors.black38;
const kBackgroundColor = Colors.white;
const kCardBackgroundColor = Colors.white;
const kDisabledColor = Colors.grey;

// 使用const颜色值
const kBorderColor = Color.fromARGB(255, 229, 229, 229);

// 系统扩展工厂主界面
class SystemFactoryScreen extends ConsumerStatefulWidget {
  const SystemFactoryScreen({super.key});

  @override
  ConsumerState<SystemFactoryScreen> createState() => _SystemFactoryScreenState();
}

class _SystemFactoryScreenState extends ConsumerState<SystemFactoryScreen> with SingleTickerProviderStateMixin {
  // 标签控制器
  late TabController _tabController;
  
  // 当前激活的标签索引
  int _currentTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // 标签栏
        Container(
          color: kPrimaryColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: kFontSizeM,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: l10n.dynamicFieldConfig),
              Tab(text: l10n.dynamicMenuConfig),
            ],
          ),
        ),
        
        // 发布流程操作区
        _buildPublishOperationArea(),
        
        // 标签内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // 动态字段配置页面
              DynamicFieldConfigPage(),
              // 动态导航菜单配置页面
              DynamicMenuConfigPage(),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建发布操作区
  Widget _buildPublishOperationArea() {
    final syncState = ref.watch(syncNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(kSpacingS),
      margin: const EdgeInsets.all(kSpacingXS),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadiusM),
        border: Border.all(color: kBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.publishFlow,
            style: const TextStyle(
              fontSize: kFontSizeM,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: kSpacingS),
          
          // 使用Wrap实现响应式按钮布局
          Wrap(
            spacing: kSpacingS,
            runSpacing: kSpacingS,
            children: [
              // 主要操作按钮 - 使用ElevatedButton
              ElevatedButton.icon(
                onPressed: () {
                  _showPublishDialog(context);
                },
                icon: const Icon(Icons.publish),
                label: Text(l10n.publish),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                  textStyle: const TextStyle(
                    fontSize: kFontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                  ),
                ),
              ),
              
              // 次要操作按钮 - 使用OutlinedButton
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(syncNotifierProvider.notifier).syncLocalDrafts();
                },
                icon: const Icon(Icons.sync),
                label: Text(l10n.sync),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: const BorderSide(color: kPrimaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                  textStyle: const TextStyle(
                    fontSize: kFontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                  ),
                ),
              ),
              
              // 审核相关按钮 - 使用TextButton
              TextButton.icon(
                onPressed: () {
                  // 实现审核人选择逻辑
                },
                icon: const Icon(Icons.person),
                label: Text(l10n.approver),
                style: TextButton.styleFrom(
                  foregroundColor: kSecondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                  textStyle: const TextStyle(
                    fontSize: kFontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                  ),
                ),
              ),
              
              TextButton.icon(
                onPressed: () {
                  // 实现审核方式选择逻辑
                },
                icon: const Icon(Icons.settings),
                label: Text(l10n.approvalMethod),
                style: TextButton.styleFrom(
                  foregroundColor: kSecondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                  textStyle: const TextStyle(
                    fontSize: kFontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 显示发布对话框
  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final publishState = ref.watch(publishNotifierProvider);
        final l10n = AppLocalizations.of(context)!;
        
        return AlertDialog(
          title: Text(
            l10n.publishConfig,
            style: const TextStyle(
              fontSize: kFontSizeL,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: kSpacingS),
                child: Text(
                  l10n.selectPublishTypeAndEnvironment,
                  style: const TextStyle(
                    fontSize: kFontSizeM,
                    color: kTextSecondary,
                  ),
                ),
              ),
              if (publishState.isPublishing) 
                const SizedBox(height: kSpacingS),
              if (publishState.isPublishing) 
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              if (publishState.error != null) 
                const SizedBox(height: kSpacingS),
              if (publishState.error != null) 
                Container(
                  padding: const EdgeInsets.all(kSpacingS),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    l10n.error(publishState.error!),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: kFontSizeS,
                    ),
                  ),
                ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusL),
          ),
          actions: [
            // 取消按钮
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: kFontSizeM,
                  color: kTextSecondary,
                ),
              ),
            ),
            
            // 模拟发布按钮
            OutlinedButton(
              onPressed: publishState.isPublishing ? null : () async {
                final success = await ref.read(publishNotifierProvider.notifier).simulatePublish(
                  _currentTabIndex == 0 ? 'UI_CONFIG' : 'MENU_CONFIG'
                );
                if (success) {
                  Navigator.pop(context);
                  context.showSuccessMessage(
                    title: l10n.success,
                    message: l10n.simulatePublishSuccess,
                    operationLog: '模拟发布成功: ${_currentTabIndex == 0 ? 'UI_CONFIG' : 'MENU_CONFIG'}',
                  );
                } else {
                  // 发布失败，不关闭对话框，让用户查看错误信息
                  context.showErrorMessage(
                    title: l10n.error(''),
                    message: l10n.simulatePublishFailed(publishState.error ?? '未知错误'),
                    useDialog: false,
                    operationLog: '模拟发布失败: ${publishState.error ?? '未知错误'}',
                  );
                }
              },
              child: Text(
                l10n.simulatePublish,
                style: const TextStyle(
                  fontSize: kFontSizeM,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor),
                padding: const EdgeInsets.symmetric(horizontal: kSpacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadiusM),
                ),
              ),
            ),
            
            // 正式发布按钮
            ElevatedButton(
              onPressed: publishState.isPublishing ? null : () async {
                final success = await ref.read(publishNotifierProvider.notifier).officialPublish(
                  _currentTabIndex == 0 ? 'UI_CONFIG' : 'MENU_CONFIG'
                );
                if (success) {
                  Navigator.pop(context);
                  context.showSuccessMessage(
                    title: l10n.success,
                    message: l10n.officialPublishSuccess,
                    operationLog: '正式发布成功: ${_currentTabIndex == 0 ? 'UI_CONFIG' : 'MENU_CONFIG'}',
                  );
                } else {
                  // 发布失败，不关闭对话框，让用户查看错误信息
                  context.showErrorMessage(
                    title: l10n.error(''),
                    message: l10n.officialPublishFailed(publishState.error ?? '未知错误'),
                    useDialog: false,
                    operationLog: '正式发布失败: ${publishState.error ?? '未知错误'}',
                  );
                }
              },
              child: Text(
                l10n.officialPublish,
                style: const TextStyle(
                  fontSize: kFontSizeM,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: kSpacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadiusM),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 动态字段配置页面
class DynamicFieldConfigPage extends ConsumerWidget {
  const DynamicFieldConfigPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiConfigState = ref.watch(uiConfigNotifierProvider);
    final businessModules = ref.watch(businessModulesProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // 获取当前选中的模块及其层级信息
    final selectedModuleInfo = uiConfigState.selectedModule != null
        ? businessModules.firstWhere((module) => module['code'] == uiConfigState.selectedModule, orElse: () => {}) as Map<String, dynamic>?
        : null;
    
    // 获取下一级模块选项
    final nextLevelModules = selectedModuleInfo != null && selectedModuleInfo.isNotEmpty
        ? businessModules.where((module) {
            final currentLevel = selectedModuleInfo!['level'] as int;
            final moduleLevel = module['level'] as int;
            final currentCode = selectedModuleInfo!['code'] as String;
            final moduleCode = module['code'] as String;
            
            // 只显示下一层级的模块，且是当前模块的子模块
            return moduleLevel == currentLevel + 1 && moduleCode.startsWith(currentCode);
          }).toList()
        : [];
    
    return Column(
      children: [
        // 面包屑导航栏
        if (uiConfigState.selectedModulePath.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(kSpacingS),
            margin: const EdgeInsets.only(left: kSpacingXS, right: kSpacingXS, bottom: kSpacingXS),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(kBorderRadiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: kSpacingXS),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 首页按钮
                        TextButton(
                          onPressed: () {
                            ref.read(uiConfigNotifierProvider.notifier).resetModulePath();
                          },
                          child: Text(
                            '首页',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: kFontSizeM,
                            ),
                          ),
                        ),
                        // 路径分隔符
                        if (uiConfigState.selectedModulePath.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: kSpacingXS),
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        // 模块路径
                        ...uiConfigState.selectedModulePath.asMap().entries.map((entry) {
                          final index = entry.key;
                          final moduleCode = entry.value;
                          final businessModules = ref.watch(businessModulesProvider);
                          final module = businessModules.firstWhere(
                            (m) => m['code'] == moduleCode,
                            orElse: () => {'name': moduleCode},
                          );
                          final moduleName = module['name'] as String;
                          final isLast = index == uiConfigState.selectedModulePath.length - 1;
                          
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (index > 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: kSpacingXS),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              TextButton(
                                onPressed: isLast ? null : () {
                                  ref.read(uiConfigNotifierProvider.notifier).navigateToModulePath(index);
                                },
                                child: Text(
                                  moduleName,
                                  style: TextStyle(
                                    color: isLast ? Colors.black87 : Colors.blue.shade700,
                                    fontSize: kFontSizeM,
                                    fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // 业务模块选择区
        Container(
          padding: const EdgeInsets.all(kSpacingS),
          margin: const EdgeInsets.all(kSpacingXS),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(kBorderRadiusM),
            border: Border.all(color: kBorderColor),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectBusinessModule,
                style: const TextStyle(
                  fontSize: kFontSizeM,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: kSpacingS),
              
              // 模块选择和操作按钮区域，使用Wrap实现响应式布局
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: uiConfigState.selectedModule,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kBorderRadiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingS, vertical: kSpacingXS),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      hintText: l10n.pleaseSelectBusinessModule,
                      hintStyle: TextStyle(
                        color: kTextTertiary,
                        fontSize: kFontSizeM,
                      ),
                    ),
                    items: businessModules.map((module) {
                      // 根据模块层级添加缩进
                      final level = module['level'] as int;
                      final indent = '  ' * (level - 1);
                      final moduleName = '$indent${module['name']}';
                      
                      return DropdownMenuItem(
                        value: module['code'] as String,
                        child: Tooltip(
                          message: '${module['description'] as String}\n路由: ${module['route'] as String}',
                          child: Row(
                            children: [
                              // 添加层级指示图标
                              if (level > 1)
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                              Expanded(
                                child: Text(
                                  moduleName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: level == 1 ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: kFontSizeM,
                                    color: kTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(uiConfigNotifierProvider.notifier).loadConfigsByModule(value);
                      }
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: kFontSizeM,
                      color: kTextPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: kSpacingS),
                  
                  // 下一级选项选择区域
                  if (nextLevelModules.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(kSpacingS),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(kBorderRadiusM),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: kSpacingXS),
                              Text(
                                '下一级选项',
                                style: TextStyle(
                                  fontSize: kFontSizeM,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: kSpacingS),
                          // 下一级选项列表
                          Wrap(
                            spacing: kSpacingS,
                            runSpacing: kSpacingS,
                            children: nextLevelModules.map((module) {
                              return ActionChip(
                                label: Text(module['name'] as String),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.blue.shade300),
                                onPressed: () {
                                  ref.read(uiConfigNotifierProvider.notifier).loadConfigsByModule(module['code'] as String);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: kSpacingS),
                  
                  // 操作按钮区域，使用Wrap实现响应式布局
                  Wrap(
                    spacing: kSpacingS,
                    runSpacing: kSpacingS,
                    children: [
                      // 添加新字段按钮
                      ElevatedButton.icon(
                        onPressed: uiConfigState.selectedModule != null
                            ? () {
                                // 实现添加新字段功能
                                _addNewFieldHeader(context, ref, uiConfigState.selectedModule!);
                              }
                            : null,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addNewField),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                          textStyle: const TextStyle(
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kBorderRadiusM),
                          ),
                        ),
                      ),
                      
                      // 编辑字段按钮
                      ElevatedButton.icon(
                        onPressed: uiConfigState.selectedModule != null
                            ? () {
                                // 实现更改字段功能
                                _editFieldHeader(context, ref, uiConfigState.selectedModule!);
                              }
                            : null,
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.editField),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                          textStyle: const TextStyle(
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kBorderRadiusM),
                          ),
                        ),
                      ),
                      
                      // 删除字段按钮
                      ElevatedButton.icon(
                        onPressed: uiConfigState.selectedModule != null
                            ? () {
                                // 实现删除字段功能
                                _deleteFieldHeader(context, ref, uiConfigState.selectedModule!);
                              }
                            : null,
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.deleteField),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                          textStyle: const TextStyle(
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kBorderRadiusM),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 显示选中模块的详细信息
              if (uiConfigState.selectedModule != null)
                Padding(
                  padding: const EdgeInsets.only(top: kSpacingS),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadiusM),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kSpacingS),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.moduleInfo,
                            style: const TextStyle(
                              fontSize: kFontSizeM,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: kSpacingXS),
                          
                          // 模块信息行，使用统一的样式和间距
                          _buildModuleInfoRow(l10n.name, 
                            businessModules
                                .firstWhere((module) => module['code'] == uiConfigState.selectedModule)
                                ['name'] as String,
                            isBold: true,
                          ),
                          
                          _buildModuleInfoRow(l10n.route, 
                            businessModules
                                .firstWhere((module) => module['code'] == uiConfigState.selectedModule)
                                ['route'] as String,
                            isSecondary: true,
                          ),
                          
                          _buildModuleInfoRow(l10n.description, 
                            businessModules
                                .firstWhere((module) => module['code'] == uiConfigState.selectedModule)
                                ['description'] as String,
                            isSecondary: true,
                          ),
                          
                          _buildModuleInfoRow(l10n.status, '', 
                            showStatusBadge: true,
                            status: l10n.enabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 操作状态反馈条
        if (uiConfigState.operationMessage != null || uiConfigState.isSaving || uiConfigState.isDeleting)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(kSpacingS),
            margin: const EdgeInsets.symmetric(horizontal: kSpacingXS),
            decoration: BoxDecoration(
              color: uiConfigState.isSaving || uiConfigState.isDeleting ? Colors.blue.shade50 : 
                     uiConfigState.operationMessage != null ? Colors.green.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(kBorderRadiusM),
              border: Border.all(
                color: uiConfigState.isSaving || uiConfigState.isDeleting ? Colors.blue.shade200 : 
                       uiConfigState.operationMessage != null ? Colors.green.shade200 : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                if (uiConfigState.isSaving || uiConfigState.isDeleting)
                  const Padding(
                    padding: EdgeInsets.only(right: kSpacingS),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    uiConfigState.operationMessage ?? 
                    (uiConfigState.isSaving ? AppLocalizations.of(context)!.operationInProgress('保存') : 
                     uiConfigState.isDeleting ? AppLocalizations.of(context)!.operationInProgress('删除') : ''),
                    style: TextStyle(
                      color: uiConfigState.isSaving || uiConfigState.isDeleting ? Colors.blue : Colors.green,
                      fontSize: kFontSizeM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // UI配置表格
        Expanded(
          child: uiConfigState.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: kPrimaryColor,
                    ),
                  ),
                )
              : uiConfigState.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: kDangerColor,
                            ),
                            const SizedBox(height: kSpacingS),
                            Text(
                              AppLocalizations.of(context)!.error(uiConfigState.error!),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: kFontSizeM,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: kSpacingM),
                            ElevatedButton(
                              onPressed: () {
                                ErrorHandlerService.handleError(context, uiConfigState.error!);
                              },
                              child: Text(AppLocalizations.of(context)!.viewDetails),
                              style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(kBorderRadiusM),
                              ),
                            ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildFieldConfigTable(uiConfigState.configs, context, ref),
        ),
      ],
    );
  }
  
  // 构建模块信息行
  Widget _buildModuleInfoRow(String label, String value, {bool isBold = false, bool isSecondary = false, bool showStatusBadge = false, String status = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingXXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: kFontSizeS,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(width: kSpacingXXS),
          showStatusBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingS, vertical: kSpacingXXS),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(kBorderRadiusL),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: kFontSizeS,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: kFontSizeS,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                      color: isSecondary ? kTextTertiary : kTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ],
      ),
    );
  }
  
  // 更改字段表头
  void _editFieldHeader(BuildContext context, WidgetRef ref, String moduleCode) {
    // 获取模块名称
    final businessModules = ref.watch(businessModulesProvider);
    final moduleName = businessModules.firstWhere(
      (module) => module['code'] == moduleCode,
      orElse: () => {'name': moduleCode},
    )['name']!;
    
    final uiConfigState = ref.watch(uiConfigNotifierProvider);
    final configs = uiConfigState.configs;
    final l10n = AppLocalizations.of(context)!;
    
    if (configs.isEmpty) {
      context.showWarningMessage(
        title: l10n.warning,
        message: l10n.noFieldsToEdit,
      );
      return;
    }
    
    // 显示选择字段的对话框
    showDialog(
      context: context,
      builder: (context) {
        SysUiConfig? selectedConfig;
        final dialogL10n = AppLocalizations.of(context)!;
        
        return AlertDialog(
          title: Text(dialogL10n.selectFieldToEdit(moduleName)),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: configs.length,
              itemBuilder: (context, index) {
                final config = configs[index];
                return RadioListTile<SysUiConfig>(
                  title: Text('${config.fieldName} (${config.fieldCode})'),
                  value: config,
                  groupValue: selectedConfig,
                  onChanged: (value) {
                    selectedConfig = value;
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(dialogL10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (selectedConfig != null) {
                  Navigator.pop(context);
                  // 显示更改字段的对话框
                  _showEditFieldDialog(context, ref, moduleCode, selectedConfig!);
                } else {
                  context.showWarningMessage(
                    title: l10n.warning,
                    message: dialogL10n.pleaseSelectField,
                    useDialog: false,
                  );
                }
              },
              child: Text(dialogL10n.confirm),
            ),
          ],
        );
      },
    );
  }
  
  // 显示更改字段的对话框
  void _showEditFieldDialog(BuildContext context, WidgetRef ref, String moduleCode, SysUiConfig config) {
    // 获取模块名称
    final businessModules = ref.watch(businessModulesProvider);
    final moduleName = businessModules.firstWhere(
      (module) => module['code'] == moduleCode,
      orElse: () => {'name': moduleCode},
    )['name']!;
    
    // 显示更改字段的对话框
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final fieldNameController = TextEditingController(text: config.fieldName);
        final defaultValueController = TextEditingController(text: config.defaultValue ?? '');
        final validationParamsController = TextEditingController(text: config.validationParams ?? '');
        bool isVisible = config.visible ?? true;
        int displayOrder = config.displayOrder ?? 0;
        String fieldType = config.fieldType ?? 'text'; // 默认文本类型
        String validationRule = config.validationRule ?? 'required'; // 默认必填规则
        String autoGeneratedFieldCode = config.fieldCode ?? '';
        bool isAdvancedOpen = false;
        
        // 简化的字段类型选项
        const fieldTypes = [
          'text', 'number', 'date', 'datetime', 'select', 'checkbox', 'radio', 'textarea', 'file', 'image', 'email', 'phone'
        ];
        
        // 简化的验证规则选项（只保留最常用的5个）
        const validationRules = [
          'required', 'optional', 'email', 'phone', 'number'
        ];
        
        // 字段类型映射
        final Map<String, String> fieldTypeLabels = {
          'text': l10n.fieldTypeText,
          'number': l10n.fieldTypeNumber,
          'date': l10n.fieldTypeDate,
          'datetime': l10n.fieldTypeDatetime,
          'select': l10n.fieldTypeSelect,
          'checkbox': l10n.fieldTypeCheckbox,
          'radio': l10n.fieldTypeRadio,
          'textarea': l10n.fieldTypeTextarea,
          'file': l10n.fieldTypeFile,
          'image': l10n.fieldTypeImage,
          'email': l10n.fieldTypeEmail,
          'phone': l10n.fieldTypePhone
        };
        
        // 简化的验证规则映射
        final Map<String, String> validationRuleLabels = {
          'required': l10n.validationRuleRequired,
          'optional': l10n.validationRuleOptional,
          'email': l10n.validationRuleEmail,
          'phone': l10n.validationRulePhone,
          'number': l10n.validationRuleNumber
        };
        
        return AlertDialog(
          title: Text(l10n.editFieldHeader(moduleName)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 字段名称（必填）
                TextField(
                  controller: fieldNameController,
                  decoration: InputDecoration(
                    labelText: l10n.fieldName,
                    hintText: l10n.fieldNameExample,
                    helperText: '请输入字段名称，字段代码将自动生成',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // 自动生成字段代码
                    autoGeneratedFieldCode = generateFieldCode(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 自动生成的字段代码（只读，用户可查看）
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.fieldCode,
                    hintText: l10n.fieldCodeExample,
                    helperText: '字段代码由系统自动生成，无需手动输入',
                    border: const OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: autoGeneratedFieldCode),
                  readOnly: true,
                  enabled: false,
                ),
                
                const SizedBox(height: 16),
                
                // 字段类型选择
                DropdownButtonFormField<String>(
                  value: fieldType,
                  decoration: InputDecoration(
                    labelText: l10n.fieldType,
                    border: const OutlineInputBorder(),
                  ),
                  items: fieldTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(fieldTypeLabels[type] ?? type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      fieldType = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 验证规则选择
                DropdownButtonFormField<String>(
                  value: validationRule,
                  decoration: InputDecoration(
                    labelText: l10n.validationRule,
                    border: const OutlineInputBorder(),
                  ),
                  items: validationRules.map((rule) {
                    return DropdownMenuItem(
                      value: rule,
                      child: Text(validationRuleLabels[rule] ?? rule),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      validationRule = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 折叠面板：高级选项
                ExpansionTile(
                  title: Text(
                    '高级选项',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false,
                  onExpansionChanged: (expanded) {
                    isAdvancedOpen = expanded;
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // 默认值
                          TextField(
                            controller: defaultValueController,
                            decoration: InputDecoration(
                              labelText: l10n.defaultValue,
                              hintText: l10n.defaultValueExample,
                              helperText: '选填，字段的默认值',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 验证参数（仅在需要时显示）
                          if (validationRule != 'optional')
                            TextField(
                              controller: validationParamsController,
                              decoration: InputDecoration(
                                labelText: l10n.validationParams,
                                hintText: l10n.validationParamsExample,
                                helperText: '选填，验证规则的参数',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 是否可见
                          Row(
                            children: [
                              Expanded(child: Text(l10n.isVisible)),
                              Checkbox(
                                value: isVisible,
                                onChanged: (value) {
                                  if (value != null) {
                                    isVisible = value;
                                  }
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 显示顺序
                          TextField(
                            controller: TextEditingController(text: displayOrder.toString()),
                            decoration: InputDecoration(
                              labelText: l10n.displayOrder,
                              hintText: l10n.displayOrderExample,
                              helperText: '选填，字段的显示顺序，数值越小越靠前',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              displayOrder = int.tryParse(value) ?? (config.displayOrder ?? 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final fieldName = fieldNameController.text.trim();
                final defaultValue = defaultValueController.text.trim();
                final validationParams = validationParamsController.text.trim();
                final fieldCode = autoGeneratedFieldCode;
                
                // 表单验证 - 只验证必填的字段名称
                if (fieldName.isEmpty) {
                  context.showWarningMessage(
                  title: l10n.warning,
                  message: '请填写字段名称',
                  useDialog: false,
                );
                  return;
                }
                
                // 更新字段
                final now = DateTime.now().millisecondsSinceEpoch;
                final updatedConfig = config.copyWith(
                  fieldCode: fieldCode,
                  fieldName: fieldName,
                  fieldType: fieldType,
                  validationRule: validationRule,
                  validationParams: validationParams,
                  defaultValue: defaultValue,
                  visible: isVisible,
                  displayOrder: displayOrder,
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
                );
                
                await ref.read(uiConfigNotifierProvider.notifier).saveConfig(updatedConfig);
                
                Navigator.pop(context);
                context.showSuccessMessage(
                  title: l10n.success,
                  message: l10n.fieldUpdatedSuccess,
                  operationLog: '字段更新成功: ${fieldCode}',
                );
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }
  
  // 删除字段
  void _deleteFieldHeader(BuildContext context, WidgetRef ref, String moduleCode) {
    // 获取模块名称
    final businessModules = ref.watch(businessModulesProvider);
    final moduleName = businessModules.firstWhere(
      (module) => module['code'] == moduleCode,
      orElse: () => {'name': moduleCode},
    )['name']!;
    
    final uiConfigState = ref.watch(uiConfigNotifierProvider);
    final configs = uiConfigState.configs;
    final l10n = AppLocalizations.of(context)!;
    
    if (configs.isEmpty) {
      context.showWarningMessage(
        title: l10n.warning,
        message: l10n.noFieldsToDelete,
      );
      return;
    }
    
    // 显示选择字段的对话框
    showDialog(
      context: context,
      builder: (context) {
        SysUiConfig? selectedConfig;
        final dialogL10n = AppLocalizations.of(context)!;
        
        return AlertDialog(
          title: Text(dialogL10n.selectFieldToDelete(moduleName)),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: configs.length,
              itemBuilder: (context, index) {
                final config = configs[index];
                return RadioListTile<SysUiConfig>(
                  title: Text('${config.fieldName} (${config.fieldCode})'),
                  value: config,
                  groupValue: selectedConfig,
                  subtitle: Text('${dialogL10n.type}: ${config.fieldType ?? 'text'}, ${dialogL10n.rule}: ${config.validationRule ?? 'required'}'),
                  onChanged: (value) {
                    selectedConfig = value;
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(dialogL10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (selectedConfig != null) {
                  Navigator.pop(context);
                  
                  // 显示确认删除的对话框
                  showDialog(
                    context: context,
                    builder: (context) {
                      final confirmL10n = AppLocalizations.of(context)!;
                      return AlertDialog(
                        title: Text(confirmL10n.confirmDelete),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(confirmL10n.confirmDeleteField(selectedConfig!.fieldName ?? '')),
                            const SizedBox(height: 10),
                            Text(confirmL10n.deleteOperations),
                            const SizedBox(height: 5),
                            Text(confirmL10n.deleteFieldBasicInfo),
                            Text(confirmL10n.cleanRelatedDependencies),
                            Text(confirmL10n.updateRouteConfig),
                            const SizedBox(height: 10),
                            Text(confirmL10n.operationIrreversible, style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(confirmL10n.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                // 执行删除操作，包括级联删除
                                await ref.read(uiConfigNotifierProvider.notifier).deleteConfig(int.parse(selectedConfig!.id!));
                                Navigator.pop(context);
                                Navigator.pop(context);
                                context.showSuccessMessage(
                                  title: l10n.success,
                                  message: confirmL10n.fieldDeletedSuccess,
                                  operationLog: '字段删除成功: ${selectedConfig!.fieldName}',
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                context.showErrorMessage(
                                  title: l10n.error(''),
                                  message: confirmL10n.fieldDeletedFailed(e.toString()),
                                  operationLog: '字段删除失败: ${selectedConfig!.fieldName}, 错误: ${e.toString()}',
                                );
                              }
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: Text(confirmL10n.confirmDelete),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  context.showWarningMessage(
                    title: l10n.warning,
                    message: dialogL10n.pleaseSelectField,
                    useDialog: false,
                  );
                }
              },
              child: Text(dialogL10n.confirm),
            ),
          ],
        );
      },
    );
  }
  
  // 添加新字段
  // 自动生成字段代码的辅助函数
  String generateFieldCode(String fieldName) {
    if (fieldName.isEmpty) return '';
    return fieldName.toLowerCase()
        .replaceAll(RegExp(r'[\s\p{Punct}]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
  
  void _addNewFieldHeader(BuildContext context, WidgetRef ref, String moduleCode) {
    // 获取模块名称
    final businessModules = ref.watch(businessModulesProvider);
    final moduleName = businessModules.firstWhere(
      (module) => module['code'] == moduleCode,
      orElse: () => {'name': moduleCode},
    )['name']!;
    
    // 显示添加新字段的对话框
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final fieldNameController = TextEditingController();
        final defaultValueController = TextEditingController();
        final validationParamsController = TextEditingController();
        bool isVisible = true;
        int displayOrder = 999;
        String fieldType = 'text'; // 默认文本类型
        String validationRule = 'required'; // 默认必填规则
        String autoGeneratedFieldCode = '';
        bool isAdvancedOpen = false;
        
        // 简化的字段类型选项
        const fieldTypes = [
          'text', 'number', 'date', 'datetime', 'select', 'checkbox', 'radio', 'textarea', 'file', 'image', 'email', 'phone'
        ];
        
        // 简化的验证规则选项（只保留最常用的5个）
        const validationRules = [
          'required', 'optional', 'email', 'phone', 'number'
        ];
        
        // 字段类型映射
        final Map<String, String> fieldTypeLabels = {
          'text': l10n.fieldTypeText,
          'number': l10n.fieldTypeNumber,
          'date': l10n.fieldTypeDate,
          'datetime': l10n.fieldTypeDatetime,
          'select': l10n.fieldTypeSelect,
          'checkbox': l10n.fieldTypeCheckbox,
          'radio': l10n.fieldTypeRadio,
          'textarea': l10n.fieldTypeTextarea,
          'file': l10n.fieldTypeFile,
          'image': l10n.fieldTypeImage,
          'email': l10n.fieldTypeEmail,
          'phone': l10n.fieldTypePhone
        };
        
        // 简化的验证规则映射
        final Map<String, String> validationRuleLabels = {
          'required': l10n.validationRuleRequired,
          'optional': l10n.validationRuleOptional,
          'email': l10n.validationRuleEmail,
          'phone': l10n.validationRulePhone,
          'number': l10n.validationRuleNumber
        };
        
        return AlertDialog(
          title: Text(l10n.addNewFieldHeader(moduleName)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 字段名称（必填）
                TextField(
                  controller: fieldNameController,
                  decoration: InputDecoration(
                    labelText: l10n.fieldName,
                    hintText: l10n.fieldNameExample,
                    helperText: '请输入字段名称，字段代码将自动生成',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // 自动生成字段代码
                    autoGeneratedFieldCode = generateFieldCode(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 自动生成的字段代码（只读，用户可查看）
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.fieldCode,
                    hintText: l10n.fieldCodeExample,
                    helperText: '字段代码由系统自动生成，无需手动输入',
                    border: const OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: autoGeneratedFieldCode),
                  readOnly: true,
                  enabled: false,
                ),
                
                const SizedBox(height: 16),
                
                // 字段类型选择
                DropdownButtonFormField<String>(
                  value: fieldType,
                  decoration: InputDecoration(
                    labelText: l10n.fieldType,
                    border: const OutlineInputBorder(),
                  ),
                  items: fieldTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(fieldTypeLabels[type] ?? type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      fieldType = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 验证规则选择
                DropdownButtonFormField<String>(
                  value: validationRule,
                  decoration: InputDecoration(
                    labelText: l10n.validationRule,
                    border: const OutlineInputBorder(),
                  ),
                  items: validationRules.map((rule) {
                    return DropdownMenuItem(
                      value: rule,
                      child: Text(validationRuleLabels[rule] ?? rule),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      validationRule = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 折叠面板：高级选项
                ExpansionTile(
                  title: Text(
                    '高级选项',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false,
                  onExpansionChanged: (expanded) {
                    isAdvancedOpen = expanded;
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // 默认值
                          TextField(
                            controller: defaultValueController,
                            decoration: InputDecoration(
                              labelText: l10n.defaultValue,
                              hintText: l10n.defaultValueExample,
                              helperText: '选填，字段的默认值',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 验证参数（仅在需要时显示）
                          if (validationRule != 'optional')
                            TextField(
                              controller: validationParamsController,
                              decoration: InputDecoration(
                                labelText: l10n.validationParams,
                                hintText: l10n.validationParamsExample,
                                helperText: '选填，验证规则的参数',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 是否可见
                          Row(
                            children: [
                              Expanded(child: Text(l10n.isVisible)),
                              Checkbox(
                                value: isVisible,
                                onChanged: (value) {
                                  if (value != null) {
                                    isVisible = value;
                                  }
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 显示顺序
                          TextField(
                            controller: TextEditingController(text: displayOrder.toString()),
                            decoration: InputDecoration(
                              labelText: l10n.displayOrder,
                              hintText: l10n.displayOrderExample,
                              helperText: '选填，字段的显示顺序，数值越小越靠前',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              displayOrder = int.tryParse(value) ?? 999;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final fieldName = fieldNameController.text.trim();
                final defaultValue = defaultValueController.text.trim();
                final validationParams = validationParamsController.text.trim();
                final fieldCode = autoGeneratedFieldCode;
                
                // 表单验证 - 只验证必填的字段名称
                if (fieldName.isEmpty) {
                  context.showWarningMessage(
                  title: l10n.warning,
                  message: '请填写字段名称',
                  useDialog: false,
                );
                  return;
                }
                
                // 保存新的字段
                final now = DateTime.now().millisecondsSinceEpoch;
                final newField = SysUiConfig(
                  id: now.toString(), // 使用时间戳字符串作为ID
                  moduleCode: moduleCode,
                  fieldCode: fieldCode,
                  fieldName: fieldName,
                  fieldType: fieldType,
                  validationRule: validationRule,
                  validationParams: validationParams,
                  defaultValue: defaultValue,
                  visible: isVisible,
                  displayOrder: displayOrder,
                  status: 'DRAFT',
                  createdBy: 'admin',
                  createdAt: DateTime.fromMillisecondsSinceEpoch(now),
                  updatedBy: 'admin',
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
                );
                
                try {
                  await SystemFactoryDao.saveOrUpdateUiConfig(newField);
                  await ref.read(uiConfigNotifierProvider.notifier).loadConfigsByModule(moduleCode);
                  
                  Navigator.pop(context);
                context.showSuccessMessage(
                  title: l10n.success,
                  message: l10n.fieldAddedSuccess,
                  operationLog: '字段添加成功: ${fieldName}',
                );
                } catch (e) {
                  context.showErrorMessage(
                    title: l10n.error(''),
                    message: l10n.fieldAddedFailed(e.toString()),
                    operationLog: '字段添加失败: ${fieldName}, 错误: ${e.toString()}',
                  );
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }
  
  // 构建字段配置表格
  Widget _buildFieldConfigTable(List<SysUiConfig> configs, BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // 如果没有配置，显示空状态
    if (configs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.table_chart_outlined,
                size: 64,
                color: kTextTertiary,
              ),
              const SizedBox(height: kSpacingS),
              Text(
                l10n.noFieldsToEdit,
                style: const TextStyle(
                  fontSize: kFontSizeL,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: kSpacingXS),
              Text(
                l10n.selectBusinessModule,
                style: const TextStyle(
                  fontSize: kFontSizeM,
                  color: kTextTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - (kSpacingXS * 2),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusM),
          ),
          margin: const EdgeInsets.all(kSpacingXS),
          child: DataTable(
            columns: [
              DataColumn(
                label: Text(
                  l10n.fieldCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.rule,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.params,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.defaultValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Text(
                  l10n.visible,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  l10n.order,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  l10n.actions,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeS,
                    color: kTextPrimary,
                  ),
                ),
                numeric: false,
              ),
            ],
            dataRowHeight: 60,
            headingRowHeight: 50,
            headingRowColor: const MaterialStatePropertyAll(Colors.grey),
            border: TableBorder.symmetric(
              inside: BorderSide(color: kBorderColor),
              outside: BorderSide(color: kBorderColor),
            ),
            rows: configs.map<DataRow>((config) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      config.fieldCode ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: kFontSizeM,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    TextField(
                      controller: TextEditingController(text: config.fieldName),
                      onChanged: (value) {
                        final updatedConfig = config.copyWith(fieldName: value);
                        ref.read(uiConfigNotifierProvider.notifier).saveConfig(updatedConfig);
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: kFontSizeM,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      config.fieldType ?? 'text',
                      style: TextStyle(
                        fontSize: kFontSizeS,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      config.validationRule ?? 'required',
                      style: TextStyle(
                        fontSize: kFontSizeS,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      config.validationParams ?? '',
                      style: TextStyle(
                        fontSize: kFontSizeS,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      config.defaultValue ?? '',
                      style: TextStyle(
                        fontSize: kFontSizeS,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                  DataCell(
                    Checkbox(
                      value: config.visible,
                      onChanged: (value) {
                        if (value != null) {
                          final updatedConfig = config.copyWith(visible: value);
                          ref.read(uiConfigNotifierProvider.notifier).saveConfig(updatedConfig);
                        }
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return kPrimaryColor;
                        }
                        return null;
                      }),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: TextEditingController(text: config.displayOrder.toString()),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final order = int.tryParse(value) ?? config.displayOrder;
                          final updatedConfig = config.copyWith(displayOrder: order);
                          ref.read(uiConfigNotifierProvider.notifier).saveConfig(updatedConfig);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: kBorderColor),
                            borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: kSpacingS, vertical: kSpacingXXS),
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: kFontSizeS,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: l10n.edit,
                          color: kSecondaryColor,
                          iconSize: 20,
                          onPressed: () {
                            // 实现编辑逻辑
                            _showEditFieldDialog(context, ref, config.moduleCode ?? '', config);
                          },
                        ),
                        const SizedBox(width: kSpacingXXS),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: l10n.delete,
                          color: kDangerColor,
                          iconSize: 20,
                          onPressed: () {
                            // 实现删除逻辑
                            _deleteFieldDialog(context, ref, config);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  // 显示删除字段的确认对话框
  void _deleteFieldDialog(BuildContext context, WidgetRef ref, SysUiConfig config) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        
        return AlertDialog(
          title: Text(l10n.confirmDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.confirmDeleteField(config.fieldName ?? '')),
              const SizedBox(height: 10),
              Text(l10n.deleteOperations),
              const SizedBox(height: 5),
              Text(l10n.deleteFieldBasicInfo),
              Text(l10n.cleanRelatedDependencies),
              Text(l10n.updateRouteConfig),
              const SizedBox(height: 10),
              Text(l10n.operationIrreversible, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // 执行删除操作
                  await ref.read(uiConfigNotifierProvider.notifier).deleteConfig(int.parse(config.id!));
                  Navigator.pop(context);
                  context.showSuccessMessage(
                    title: l10n.success,
                    message: l10n.fieldDeletedSuccess,
                    operationLog: '菜单删除成功',
                  );
                } catch (e) {
                  Navigator.pop(context);
                  context.showErrorMessage(
                    title: l10n.error(''),
                    message: l10n.fieldDeletedFailed(e.toString()),
                    operationLog: '菜单删除失败: ${e.toString()}',
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.confirmDelete),
            ),
          ],
        );
      },
    );
  }
}

// 动态导航菜单配置页面
class DynamicMenuConfigPage extends ConsumerWidget {
  const DynamicMenuConfigPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuConfigState = ref.watch(menuConfigNotifierProvider);
    
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // 菜单操作按钮区
        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 实现添加根菜单逻辑
                    _addRootMenu(ref);
                  },
                  child: Text(l10n.addRootMenu),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // 实现添加子菜单逻辑
                    if (menuConfigState.selectedMenu != null) {
                      _addSubMenu(ref, menuConfigState.selectedMenu!);
                    }
                  },
                  child: Text(l10n.addSubMenu),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // 实现删除菜单逻辑
                    if (menuConfigState.selectedMenu != null) {
                      ref.read(menuConfigNotifierProvider.notifier).deleteConfig(int.parse(menuConfigState.selectedMenu!.id!));
                    }
                  },
                  child: Text(l10n.deleteMenu),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // 实现添加标签页功能
                    _addTabHeader(ref);
                  },
                  child: Text(l10n.addTab),
                ),
              ],
            ),
          ),
        ),
        
        // 菜单配置树形结构
        Expanded(
          child: menuConfigState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : menuConfigState.error != null
                  ? Center(child: Text('错误：${menuConfigState.error}'))
                  : _buildMenuTree(menuConfigState.configs, ref),
        ),
        
        // 菜单属性编辑区
        _buildMenuPropertyEditor(menuConfigState.selectedMenu, ref),
      ],
    );
  }
  
  // 构建菜单树形结构
  Widget _buildMenuTree(List<SysMenuConfig> configs, WidgetRef ref) {
    // 构建树形结构数据
    final menuMap = <int, SysMenuConfig>{};
    final rootMenus = <SysMenuConfig>[];
    
    for (var menu in configs) {
      menuMap[int.parse(menu.id!)] = menu;
    }
    
    for (var menu in configs) {
      if (menu.parentId == null) {
        rootMenus.add(menu);
      }
    }
    
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: rootMenus.length,
        itemBuilder: (context, index) {
          rootMenus.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
          return _buildMenuItem(context, rootMenus[index], menuMap, ref, 0);
        },
      ),
    );
  }
  
  // 构建菜单项
  Widget _buildMenuItem(BuildContext context, SysMenuConfig menu, Map<int, SysMenuConfig> menuMap, WidgetRef ref, int level) {
    final indent = level * 20.0;
    final isSelected = ref.watch(menuConfigNotifierProvider).selectedMenu?.id == menu.id;
    
    return Column(
      children: [
        InkWell(
          onTap: () {
            ref.read(menuConfigNotifierProvider.notifier).selectMenu(menu);
          },
          child: Container(
            padding: EdgeInsets.only(left: indent + 10, top: 10, bottom: 10, right: 10),
            color: isSelected ? Colors.blue[100] : null,
            child: Row(
              children: [
                // 菜单图标
                if (menu.icon != null && menu.icon!.isNotEmpty)
                  Icon(_getIconData(menu.icon!)),
                const SizedBox(width: 10),
                
                // 菜单名称
                Expanded(child: Text(menu.menuName ?? '')),
                
                // 菜单操作区
              ],
            ),
          ),
        ),
        // 子菜单列表
        if (menuMap.values.any((m) => m.parentId == menu.id))
          Padding(
            padding: EdgeInsets.only(left: indent + 20),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: menuMap.values.where((m) => m.parentId == menu.id).length,
              itemBuilder: (context, index) {
                final subMenus = menuMap.values.where((m) => m.parentId == menu.id).toList();
                subMenus.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
                return _buildMenuItem(context, subMenus[index], menuMap, ref, level + 1);
              },
            ),
          ),
      ],
    );
  }
  
  // 获取图标数据
  IconData _getIconData(String iconName) {
    // 根据图标名称返回对应的IconData
    final iconMap = {
      'dashboard': Icons.dashboard,
      'receipt_long_outlined': Icons.receipt_long_outlined,
      'business_outlined': Icons.business_outlined,
      'shopping_cart_outlined': Icons.shopping_cart_outlined,
      'shopping_bag_outlined': Icons.shopping_bag_outlined,
      'check_circle_outline': Icons.check_circle_outline,
      'attach_money_outlined': Icons.attach_money_outlined,
      'local_shipping_outlined': Icons.local_shipping_outlined,
      'warehouse_outlined': Icons.warehouse_outlined,
      'info_outline': Icons.info_outline,
      'payments_outlined': Icons.payments_outlined,
      'settings_outlined': Icons.settings_outlined,
      'factory_outlined': Icons.factory_outlined,
      'people_outlined': Icons.people_outlined,
      'notifications_outlined': Icons.notifications_outlined,
      'security_outlined': Icons.security_outlined,
      'train_outlined': Icons.train_outlined,
      'business': Icons.business,
      'more_horiz': Icons.more_horiz,
      'arrow_circle_right': Icons.arrow_circle_right,
      'check_circle': Icons.check_circle,
      'people': Icons.people,
      'cloud_upload': Icons.cloud_upload,
      'check_circle_outline': Icons.check_circle_outline,
      'delete_outline': Icons.delete_outline,
      'inventory': Icons.inventory,
      'search': Icons.search,
      'arrow_downward': Icons.arrow_downward,
      'arrow_outward': Icons.arrow_outward,
      'delete': Icons.delete,
      'contact_phone': Icons.contact_phone,
      'location_city': Icons.location_city,
      'person': Icons.person,
      'groups': Icons.groups,
      'work': Icons.work,
      'access_time': Icons.access_time,
      'request_page': Icons.request_page,
      'flight_takeoff': Icons.flight_takeoff,
      'star': Icons.star,
      'payment': Icons.payment,
      'card_giftcard': Icons.card_giftcard,
      'assignment_ind': Icons.assignment_ind,
      'category': Icons.category,
      'monetization_on': Icons.monetization_on,
      'file_copy': Icons.file_copy,
      'assignment': Icons.assignment,
      'assessment': Icons.assessment,
      'local_shipping': Icons.local_shipping,
      'shopping_cart': Icons.shopping_cart,
      'batch_prediction': Icons.batch_prediction,
      'search': Icons.search,
      'trending_up': Icons.trending_up,
      'public': Icons.public,
    };
    
    return iconMap[iconName] ?? Icons.menu;
  }
  
  // 添加根菜单
  void _addRootMenu(WidgetRef ref) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newMenu = SysMenuConfig(
      id: now.toString(), // 使用时间戳字符串作为ID
      parentId: null,
      menuName: '新根菜单',
      icon: 'dashboard',
      routePath: '/new-root',
      displayOrder: 999,
      status: 'DRAFT',
      createdBy: 'admin',
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
      updatedBy: 'admin',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
    ref.read(menuConfigNotifierProvider.notifier).saveConfig(newMenu);
  }
  
  // 添加子菜单
  void _addSubMenu(WidgetRef ref, SysMenuConfig parentMenu) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newMenu = SysMenuConfig(
      id: now.toString(), // 使用时间戳字符串作为ID
      parentId: parentMenu.id,
      menuName: '新子菜单',
      icon: 'dashboard',
      routePath: '/new-sub',
      displayOrder: 999,
      status: 'DRAFT',
      createdBy: 'admin',
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
      updatedBy: 'admin',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
    ref.read(menuConfigNotifierProvider.notifier).saveConfig(newMenu);
  }
  
  // 添加标签页
  void _addTabHeader(WidgetRef ref) {
    final menuConfigState = ref.watch(menuConfigNotifierProvider);
    
    // 显示添加标签页的对话框
    showDialog(
      context: ref.context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final tabNameController = TextEditingController(text: l10n.newTab);
        final routePathController = TextEditingController();
        final displayOrderController = TextEditingController(text: '999');
        
        return AlertDialog(
          title: Text(l10n.addTab),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tabNameController,
                  decoration: InputDecoration(
                    labelText: l10n.tabName,
                    hintText: l10n.tabNameExample,
                  ),
                ),
                TextField(
                  controller: routePathController,
                  decoration: InputDecoration(
                    labelText: l10n.routePath,
                    hintText: l10n.routePathExample,
                  ),
                ),
                TextField(
                  controller: displayOrderController,
                  decoration: InputDecoration(
                    labelText: l10n.displayOrder,
                    hintText: l10n.displayOrderExample,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final tabName = tabNameController.text.trim();
                final routePath = routePathController.text.trim();
                final displayOrder = int.tryParse(displayOrderController.text.trim()) ?? 999;
                
                if (tabName.isEmpty || routePath.isEmpty) {
                  context.showWarningMessage(
                    title: l10n.warning,
                    message: l10n.pleaseFillAllRequiredFields,
                    useDialog: false,
                  );
                  return;
                }
                
                // 保存新的标签页
                final now = DateTime.now().millisecondsSinceEpoch;
                final newTab = SysMenuConfig(
                  id: now.toString(), // 使用时间戳字符串作为ID
                  parentId: menuConfigState.selectedMenu != null ? menuConfigState.selectedMenu!.id : null,
                  menuName: tabName,
                  icon: 'assignment',
                  routePath: routePath,
                  displayOrder: displayOrder,
                  status: 'DRAFT',
                  createdBy: 'admin',
                  createdAt: DateTime.fromMillisecondsSinceEpoch(now),
                  updatedBy: 'admin',
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
                );
                
                await ref.read(menuConfigNotifierProvider.notifier).saveConfig(newTab);
                
                Navigator.pop(context);
                context.showSuccessMessage(
                  title: l10n.success,
                  message: l10n.menuAddedSuccess,
                  operationLog: '标签页添加成功: $tabName',
                );
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }
  
  // 构建菜单属性编辑区
  Widget _buildMenuPropertyEditor(SysMenuConfig? selectedMenu, WidgetRef ref) {
    if (selectedMenu == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100],
        child: const Text('请选择一个菜单项进行编辑'),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('菜单属性编辑', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: selectedMenu.menuName,
            decoration: const InputDecoration(labelText: '菜单名称'),
            onChanged: (value) {
              final updatedMenu = selectedMenu.copyWith(menuName: value);
              ref.read(menuConfigNotifierProvider.notifier).saveConfig(updatedMenu);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: selectedMenu.icon,
            decoration: const InputDecoration(labelText: '菜单图标'),
            onChanged: (value) {
              final updatedMenu = selectedMenu.copyWith(icon: value);
              ref.read(menuConfigNotifierProvider.notifier).saveConfig(updatedMenu);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: selectedMenu.routePath,
            decoration: const InputDecoration(labelText: '路由路径'),
            onChanged: (value) {
              final updatedMenu = selectedMenu.copyWith(routePath: value);
              ref.read(menuConfigNotifierProvider.notifier).saveConfig(updatedMenu);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: selectedMenu.displayOrder.toString(),
            decoration: const InputDecoration(labelText: '显示顺序'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final order = int.tryParse(value) ?? selectedMenu.displayOrder;
              final updatedMenu = selectedMenu.copyWith(displayOrder: order);
              ref.read(menuConfigNotifierProvider.notifier).saveConfig(updatedMenu);
            },
          ),
        ],
      ),
    );
  }
}