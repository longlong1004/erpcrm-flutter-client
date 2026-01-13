import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';
import 'package:erpcrm_client/providers/permissions_provider.dart';
import 'package:erpcrm_client/providers/auth_provider.dart';
import 'package:erpcrm_client/utils/storage.dart';
import 'package:erpcrm_client/screens/settings/shortcut_key_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const SettingsScreen({super.key, this.child});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(permissionsNotifierProvider.notifier).loadSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditSettingDialog(SettingItem setting) {
    final controller = TextEditingController(text: setting.value?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑 ${setting.name}'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (setting.description.isNotEmpty) ...[
                  Text(
                    setting.description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 16),
                ],
                if (setting.type == SettingType.string || setting.type == SettingType.number)
                  TextFormField(
                    controller: controller,
                    keyboardType: setting.type == SettingType.number ? TextInputType.number : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: setting.name,
                      border: const OutlineInputBorder(),
                      suffixText: setting.unit,
                    ),
                    validator: (value) {
                      if (setting.required && (value == null || value.isEmpty)) {
                        return '此项为必填项';
                      }
                      return null;
                    },
                  )
                else if (setting.type == SettingType.textarea)
                  TextFormField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: setting.name,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (setting.required && (value == null || value.isEmpty)) {
                        return '此项为必填项';
                      }
                      return null;
                    },
                  )
                else if (setting.type == SettingType.boolean)
                  SwitchListTile(
                    title: Text(setting.name),
                    value: controller.text.toLowerCase() == 'true',
                    onChanged: (value) {
                      controller.text = value.toString();
                    },
                  )
                else if (setting.type == SettingType.select && setting.options != null)
                  DropdownButtonFormField<String>(
                    value: controller.text.isEmpty ? null : controller.text,
                    decoration: InputDecoration(
                      labelText: setting.name,
                      border: const OutlineInputBorder(),
                    ),
                    items: setting.options!.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value']?.toString(),
                        child: Text(option['label']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.text = value;
                      }
                    },
                  )
                else if (setting.type == SettingType.password)
                  TextFormField(
                    controller: controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: setting.name,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (setting.required && (value == null || value.isEmpty)) {
                        return '此项为必填项';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: setting.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                dynamic newValue;
                switch (setting.type) {
                  case SettingType.number:
                    newValue = double.tryParse(controller.text) ?? 0;
                    break;
                  case SettingType.boolean:
                    newValue = controller.text.toLowerCase() == 'true';
                    break;
                  default:
                    newValue = controller.text;
                }

                final updatedSetting = setting.copyWith(value: newValue);
                final success = await ref.read(permissionsNotifierProvider.notifier).updateSetting(updatedSetting);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('设置已保存')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingDialog(SettingItem setting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: Text('确定要将"${setting.name}"重置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(permissionsNotifierProvider.notifier).resetSetting(setting.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设置已重置')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '原密码',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入原密码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '新密码',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入新密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '确认新密码',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认新密码';
                    }
                    if (value != newPasswordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码修改成功')),
                );
              }
            },
            child: const Text('确认修改'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: ref.watch(authProvider).user?.name ?? '');
    final emailController = TextEditingController(text: ref.watch(authProvider).user?.username ?? '');
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑个人资料'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('个人资料已更新')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果有子路由内容，直接显示子路由内容
    if (widget.child != null) {
      return widget.child!;
    }

    // 否则显示默认的设置页面
    return MainLayout(
      title: '系统设置',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统设置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor: const Color(0xFF616161),
                    indicatorColor: const Color(0xFF1976D2),
                    tabs: const [
                      Tab(text: '系统设置'),
                      Tab(text: '账户设置'),
                      Tab(text: '通知设置'),
                      Tab(text: '快捷键设置'),
                    ],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSystemSettingsTab(),
                        _buildAccountSettingsTab(),
                        _buildNotificationSettingsTab(),
                        _buildShortcutKeySettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSettingsTab() {
    final state = ref.watch(permissionsNotifierProvider);
    final systemSettings = state.settings.where((s) => s.category == 'system').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: systemSettings.isEmpty
          ? const Center(
              child: Text(
                '暂无系统设置',
                style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
              ),
            )
          : ListView.builder(
              itemCount: systemSettings.length,
              itemBuilder: (context, index) {
                final setting = systemSettings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      setting.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (setting.description.isNotEmpty)
                          Text(
                            setting.description,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '当前值: ${setting.value ?? setting.defaultValue ?? '未设置'}',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (setting.editable)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                            onPressed: () => _showEditSettingDialog(setting),
                          ),
                        if (!setting.isSystem)
                          IconButton(
                            icon: const Icon(Icons.restore, color: Color(0xFFFF9800)),
                            onPressed: () => _showResetSettingDialog(setting),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAccountSettingsTab() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '个人信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem('用户名', user?.username ?? '-'),
                  _buildProfileItem('姓名', user?.name ?? '-'),
                  _buildProfileItem('部门', user?.department ?? '-'),
                  _buildProfileItem('职位', user?.position ?? '-'),
                  _buildProfileItem('手机号', user?.phoneNumber ?? '-'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑资料'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: const Icon(Icons.lock),
                        label: const Text('修改密码'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '安全设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security, color: Color(0xFF1976D2)),
                    title: const Text('两步验证'),
                    subtitle: const Text('启用两步验证以提高账户安全性'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('功能开发中')),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history, color: Color(0xFF1976D2)),
                    title: const Text('登录历史'),
                    subtitle: const Text('查看最近的登录记录'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsTab() {
    final state = ref.watch(permissionsNotifierProvider);
    final notificationSettings = state.settings.where((s) => s.category == 'notification').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: notificationSettings.isEmpty
          ? const Center(
              child: Text(
                '暂无通知设置',
                style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
              ),
            )
          : ListView.builder(
              itemCount: notificationSettings.length,
              itemBuilder: (context, index) {
                final setting = notificationSettings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: SwitchListTile(
                    title: Text(
                      setting.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: setting.description.isNotEmpty
                        ? Text(
                            setting.description,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                          )
                        : null,
                    value: setting.value == true || setting.value?.toString().toLowerCase() == 'true',
                    onChanged: (value) async {
                      final updatedSetting = setting.copyWith(value: value);
                      final success = await ref.read(permissionsNotifierProvider.notifier).updateSetting(updatedSetting);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('设置已保存')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShortcutKeySettingsTab() {
    return const ShortcutKeySettingsScreen();
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
