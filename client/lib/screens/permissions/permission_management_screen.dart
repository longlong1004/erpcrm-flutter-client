import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/permissions/permission_model.dart';
import 'package:erpcrm_client/providers/permissions_provider.dart';

class PermissionManagementScreen extends ConsumerStatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  ConsumerState<PermissionManagementScreen> createState() => _PermissionManagementScreenState();
}

class _PermissionManagementScreenState extends ConsumerState<PermissionManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final notifier = ref.read(permissionsNotifierProvider.notifier);
    notifier.loadPermissions();
    notifier.loadRoles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionsState = ref.watch(permissionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('权限管理'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth > 768 ? 24.0 : 16.0;
          final isMobile = constraints.maxWidth <= 768;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '权限列表'),
                    Tab(text: '角色列表'),
                  ],
                  labelColor: const Color(0xFF1E88E5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1E88E5),
                  indicatorWeight: 2,
                  isScrollable: isMobile,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPermissionsTab(permissionsState, constraints),
                      _buildRolesTab(permissionsState, constraints),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionsTab(PermissionsState state, BoxConstraints constraints) {
    final filteredPermissions = state.permissions.where((p) =>
      p.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      p.code.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索权限...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredPermissions.length,
            itemBuilder: (context, index) {
              final permission = filteredPermissions[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(permission.name),
                  subtitle: Text('${permission.code} - ${permission.description}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(permission.type),
                        backgroundColor: Colors.blue[50],
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(permission.enable ? '启用' : '禁用'),
                        backgroundColor: permission.enable ? Colors.green[50] : Colors.red[50],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRolesTab(PermissionsState state, BoxConstraints constraints) {
    final filteredRoles = state.roles.where((r) =>
      r.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      r.code.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索角色...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRoles.length,
            itemBuilder: (context, index) {
              final role = filteredRoles[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(role.name),
                  subtitle: Text('${role.code} - ${role.description}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role.isSystem)
                        Chip(
                          label: const Text('系统角色'),
                          backgroundColor: Colors.grey[100],
                        ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(role.enable ? '启用' : '禁用'),
                        backgroundColor: role.enable ? Colors.green[50] : Colors.red[50],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}