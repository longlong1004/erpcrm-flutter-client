import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/permissions_provider.dart';
import 'package:erpcrm_client/models/permissions/permission_model.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  bool _isAddingRole = false;
  String _newRoleName = '';
  String _newRoleCode = '';
  String _newRoleDescription = '';
  List<String> _selectedPermissionIds = [];
  
  // 编辑权限相关状态
  bool _isEditingPermission = false;
  Permission? _editingPermission;
  String _editPermissionName = '';
  String _editPermissionCode = '';
  String _editPermissionType = 'button';
  String _editPermissionDescription = '';
  String? _editPermissionParentId;
  bool _editPermissionIsMenu = false;

  // 用户角色关联相关状态
  String _selectedUserId = '';
  List<String> _selectedUserRoleIds = [];
  bool _isAssigningRoles = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 加载权限相关数据
    final notifier = ref.read(permissionsNotifierProvider.notifier);
    notifier.loadPermissions();
    notifier.loadRoles();
    notifier.loadUserRoles();
    notifier.loadOperationLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionsState = ref.watch(permissionsNotifierProvider);

    return MainLayout(
      title: '系统权限',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕宽度调整内边距和间距
          final padding = constraints.maxWidth > 768 ? 24.0 : 16.0;
          final isMobile = constraints.maxWidth <= 768;
          
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Text(
                  '系统权限',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                SizedBox(height: isMobile ? 24.0 : 32.0),

                // 标签页
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '角色管理'),
                    Tab(text: '权限管理'),
                    Tab(text: '用户角色'),
                    Tab(text: '操作日志'),
                  ],
                  labelColor: const Color(0xFF1E88E5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1E88E5),
                  indicatorWeight: 2,
                  onTap: (index) {
                    setState(() {
                      _isAddingRole = false;
                    });
                  },
                  isScrollable: isMobile, // 小屏幕标签页可滚动
                ),
                SizedBox(height: isMobile ? 16.0 : 24.0),

                // 标签页内容
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRolesTab(permissionsState, constraints),
                      _buildPermissionsTab(permissionsState, constraints),
                      _buildUserRolesTab(permissionsState, constraints),
                      _buildOperationLogsTab(permissionsState, constraints),
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

  // 构建角色管理标签页
  Widget _buildRolesTab(PermissionsState state, BoxConstraints constraints) {
    final filteredRoles = ref.watch(rolesSearchProvider(_searchKeyword));
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索和添加角色按钮
        if (isMobile)
          // 小屏幕垂直排列
          Column(
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
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingRole = true;
                    _newRoleName = '';
                    _newRoleCode = '';
                    _newRoleDescription = '';
                    _selectedPermissionIds = [];
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('新增角色'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          )
        else
          // 大屏幕水平排列
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
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
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingRole = true;
                    _newRoleName = '';
                    _newRoleCode = '';
                    _newRoleDescription = '';
                    _selectedPermissionIds = [];
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('新增角色'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
        SizedBox(height: isMobile ? 16.0 : 24.0),

        // 添加角色表单
        if (_isAddingRole)
          Expanded(
            child: _buildAddRoleForm(state, constraints),
          )
        else
          Expanded(
            child: _buildRolesList(filteredRoles, state, constraints),
          ),
      ],
    );
  }

  // 构建添加角色表单
  Widget _buildAddRoleForm(PermissionsState state, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth <= 768;
    final formKey = GlobalKey<FormState>();
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '新增角色',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: isMobile ? 16.0 : 24.0),

              // 角色基本信息
              if (isMobile)
                // 小屏幕垂直排列
                Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '角色名称',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _newRoleName = value;
                        });
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '角色名称不能为空';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '角色编码',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _newRoleCode = value;
                        });
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '角色编码不能为空';
                        }
                        // 角色编码格式验证（只能包含字母、数字和下划线）
                        final codeRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
                        if (!codeRegExp.hasMatch(value!)) {
                          return '角色编码只能包含字母、数字和下划线';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              else
                // 大屏幕水平排列
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '角色名称',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _newRoleName = value;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '角色名称不能为空';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '角色编码',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _newRoleCode = value;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '角色编码不能为空';
                          }
                          // 角色编码格式验证（只能包含字母、数字和下划线）
                          final codeRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
                          if (!codeRegExp.hasMatch(value!)) {
                            return '角色编码只能包含字母、数字和下划线';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              SizedBox(height: isMobile ? 12.0 : 16.0),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: '角色描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: isMobile ? 2 : 3,
                onChanged: (value) {
                  setState(() {
                    _newRoleDescription = value;
                  });
                },
              ),
              SizedBox(height: isMobile ? 16.0 : 24.0),

              // 权限选择
              Text(
                '选择权限',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: isMobile ? 12.0 : 16.0),

              // 权限树
              Expanded(
                child: _buildPermissionTree(state.permissions),
              ),
              SizedBox(height: isMobile ? 16.0 : 24.0),

              // 表单操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingRole = false;
                      });
                    },
                    child: const Text('取消'),
                  ),
                  SizedBox(width: isMobile ? 8.0 : 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();
                        _createRole();
                      } else {
                        // 表单验证失败，显示提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('表单验证失败，请检查输入'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('保存'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建角色列表
  Widget _buildRolesList(List<Role> roles, PermissionsState state, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth <= 768;
    
    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return Card(
          margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 角色信息
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          role.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isMobile ? 14.0 : 16.0,
                          ),
                        ),
                        Row(
                          children: [
                            if (role.isSystem)
                              Chip(
                                label: const Text(
                                  '系统角色',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.grey[100],
                                labelStyle: const TextStyle(color: Colors.grey),
                              ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                role.enable ? '启用' : '禁用',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: role.enable ? Colors.green[50] : Colors.red[50],
                              labelStyle: TextStyle(
                                color: role.enable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 12.0 : 14.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 12.0 : 14.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 操作按钮
                Row(
                  mainAxisAlignment: isMobile ? MainAxisAlignment.spaceAround : MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _editRole(role);
                      },
                      icon: Icon(Icons.edit, size: isMobile ? 16.0 : 20.0),
                      label: Text('编辑', style: TextStyle(fontSize: isMobile ? 12.0 : 14.0)),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: isMobile ? 4.0 : 8.0)),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8.0 : 16.0),
                    TextButton.icon(
                      onPressed: () {
                        _assignPermissions(role);
                      },
                      icon: Icon(Icons.lock_outline, size: isMobile ? 16.0 : 20.0),
                      label: Text('分配权限', style: TextStyle(fontSize: isMobile ? 12.0 : 14.0)),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: isMobile ? 4.0 : 8.0)),
                      ),
                    ),
                    if (!role.isSystem)
                      SizedBox(width: isMobile ? 8.0 : 16.0),
                    if (!role.isSystem)
                      TextButton.icon(
                        onPressed: () {
                          _deleteRole(role);
                        },
                        icon: Icon(Icons.delete, size: isMobile ? 16.0 : 20.0),
                        label: Text('删除', style: TextStyle(fontSize: isMobile ? 12.0 : 14.0)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: isMobile ? 4.0 : 8.0),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
    );
  }

  // 构建权限管理标签页
  Widget _buildPermissionsTab(PermissionsState state, BoxConstraints constraints) {
    final filteredPermissions = ref.watch(permissionsSearchProvider(_searchKeyword));
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索栏
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
        SizedBox(height: isMobile ? 16.0 : 24.0),

        // 权限列表
        Expanded(
          child: ListView.builder(
            itemCount: filteredPermissions.length,
            itemBuilder: (context, index) {
              final permission = filteredPermissions[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                elevation: 1,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 权限信息
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                permission.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 14.0 : 16.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      permission.type,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue[50],
                                    labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      permission.isMenu ? '菜单' : '按钮',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.green[50],
                                    labelStyle: const TextStyle(color: Colors.green),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      permission.enable ? '启用' : '禁用',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: permission.enable ? Colors.green[50] : Colors.red[50],
                                    labelStyle: TextStyle(
                                      color: permission.enable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            permission.code,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 12.0 : 14.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            permission.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 12.0 : 14.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 操作按钮
                      Row(
                        mainAxisAlignment: isMobile ? MainAxisAlignment.spaceAround : MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _editPermission(permission);
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text('编辑', style: TextStyle(fontSize: isMobile ? 12.0 : 14.0)),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: isMobile ? 4.0 : 8.0)),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8.0 : 16.0),
                          TextButton.icon(
                            onPressed: () {
                              _togglePermissionStatus(permission);
                            },
                            icon: Icon(permission.enable ? Icons.visibility_off : Icons.visibility, size: 16),
                            label: Text(permission.enable ? '禁用' : '启用', style: TextStyle(fontSize: isMobile ? 12.0 : 14.0)),
                            style: TextButton.styleFrom(
                              foregroundColor: permission.enable ? Colors.red : Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: isMobile ? 4.0 : 8.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
          ),
        ),
      ],
    );
  }

  // 构建用户角色管理标签页
  Widget _buildUserRolesTab(PermissionsState state, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth <= 768;
    
    // 模拟用户数据
    final users = [
      {'id': '1', 'name': 'admin', 'username': 'admin', 'email': 'admin@example.com'},
      {'id': '2', 'name': 'manager', 'username': 'manager', 'email': 'manager@example.com'},
      {'id': '3', 'name': 'operator', 'username': 'operator', 'email': 'operator@example.com'},
      {'id': '4', 'name': 'user1', 'username': 'user1', 'email': 'user1@example.com'},
      {'id': '5', 'name': 'user2', 'username': 'user2', 'email': 'user2@example.com'},
    ];
    
    // 获取用户的角色列表
    List<String> getUserRoleNames(String userId) {
      return state.userRoles
          .where((userRole) => userRole.userId == userId)
          .map((userRole) => userRole.roleName)
          .toList();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        Text(
          '用户角色管理',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: isMobile ? 16.0 : 24.0),
        
        // 操作按钮
        ElevatedButton.icon(
          onPressed: () {
            // 显示用户选择对话框
            _showUserSelectDialog(users);
          },
          icon: const Icon(Icons.add),
          label: const Text('为用户分配角色'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
          ),
        ),
        SizedBox(height: isMobile ? 16.0 : 24.0),
        
        // 用户角色列表
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final roleNames = getUserRoleNames(user['id']!);
              
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                elevation: 1,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户基本信息
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name']!, 
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 14.0 : 16.0,
                                ),
                              ),
                              Text(
                                '${user['username']} (${user['email']})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isMobile ? 12.0 : 14.0,
                                ),
                              ),
                            ],
                          ),
                          // 操作按钮
                          TextButton.icon(
                            onPressed: () {
                              _showAssignRolesDialog(user['id']!, user['name']!);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('分配角色'),
                          ),
                        ],
                      ),
                      
                      // 用户角色列表
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: roleNames.map((roleName) {
                          return Chip(
                            label: Text(roleName),
                            backgroundColor: Colors.blue[50],
                            labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
            padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
          ),
        ),
      ],
    );
  }
  
  // 显示用户选择对话框
  void _showUserSelectDialog(List<Map<String, dynamic>> users) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择用户'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name']!),
                subtitle: Text(user['username']!),
                onTap: () {
                  Navigator.pop(context);
                  _showAssignRolesDialog(user['id']!, user['name']!);
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
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
  
  // 显示为用户分配角色对话框
  void _showAssignRolesDialog(String userId, String userName) {
    setState(() {
      _selectedUserId = userId;
      _isAssigningRoles = true;
      _selectedUserRoleIds = [];
    });
    
    // 获取用户当前的角色ID列表
    final currentUserRoles = ref.read(permissionsNotifierProvider).userRoles
        .where((userRole) => userRole.userId == userId)
        .map((userRole) => userRole.roleId)
        .toList();
    
    setState(() {
      _selectedUserRoleIds = List.from(currentUserRoles);
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('为用户 "$userName" 分配角色'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择角色:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 16),
                
                // 角色选择列表
                _buildRoleSelectionList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isAssigningRoles = false;
              });
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _assignRolesToUser();
            },
            child: const Text('保存'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建角色选择列表
  Widget _buildRoleSelectionList() {
    final roles = ref.read(permissionsNotifierProvider).roles;
    
    return Column(
      children: roles.map((role) {
        final isSelected = _selectedUserRoleIds.contains(role.id);
        
        return CheckboxListTile(
          title: Text(role.name),
          subtitle: Text(role.description),
          value: isSelected,
          onChanged: (checked) {
            setState(() {
              if (checked ?? false) {
                _selectedUserRoleIds.add(role.id);
              } else {
                _selectedUserRoleIds.remove(role.id);
              }
            });
          },
          secondary: role.isSystem ? Chip(
            label: const Text('系统角色'),
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ) : null,
        );
      }).toList(),
    );
  }
  
  // 为用户分配角色
  void _assignRolesToUser() {
    setState(() {
      _isAssigningRoles = true;
    });
    
    ref.read(permissionsNotifierProvider.notifier)
        .assignRolesToUser(_selectedUserId, _selectedUserRoleIds)
        .then((success) {
      setState(() {
        _isAssigningRoles = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('角色分配成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('角色分配失败'), backgroundColor: Colors.red),
        );
      }
    }).catchError((error) {
      setState(() {
        _isAssigningRoles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('角色分配失败: ${error.toString()}'), backgroundColor: Colors.red),
      );
    });
  }
  
  // 构建操作日志标签页
  Widget _buildOperationLogsTab(PermissionsState state, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth <= 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索栏
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索日志...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16.0 : 24.0),

        // 日志列表
        Expanded(
          child: ListView.builder(
            itemCount: state.operationLogs.length,
            itemBuilder: (context, index) {
              final log = state.operationLogs[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                elevation: 1,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 操作内容和时间
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              log.operationContent,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: isMobile ? 14.0 : 16.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            log.operationTime.toString().substring(0, 19),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 12.0 : 14.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 6.0 : 8.0),
                      
                      // 操作用户和模块
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.userName} (${log.userId})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 12.0 : 14.0,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4.0 : 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  log.operationModule,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue[50],
                                labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                              ),
                              Text(
                                '${log.operationType}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isMobile ? 12.0 : 14.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4.0 : 8.0),
                      
                      // IP地址
                      Text(
                        'IP: ${log.clientIp}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12.0 : 14.0,
                        ),
                      ),
                      
                      // 错误信息
                      if (log.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '错误信息: ${log.errorMessage}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: isMobile ? 12.0 : 14.0,
                            ),
                            maxLines: isMobile ? 2 : null,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
          ),
        ),
      ],
    );
  }

  // 验证角色信息
  bool _validateRoleInfo() {
    if (_newRoleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('角色名称不能为空'), backgroundColor: Colors.red),
      );
      return false;
    }
    
    if (_newRoleCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('角色编码不能为空'), backgroundColor: Colors.red),
      );
      return false;
    }
    
    // 角色编码格式验证（只能包含字母、数字和下划线）
    final codeRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!codeRegExp.hasMatch(_newRoleCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('角色编码只能包含字母、数字和下划线'), backgroundColor: Colors.red),
      );
      return false;
    }
    
    // 检查是否选择了权限
    if (_selectedPermissionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个权限'), backgroundColor: Colors.red),
      );
      return false;
    }
    
    return true;
  }
  
  // 创建角色
  void _createRole() {
    // 检查是否选择了权限
    if (_selectedPermissionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个权限'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final newRole = Role(
      id: '', // 由服务器生成
      name: _newRoleName,
      code: _newRoleCode,
      description: _newRoleDescription,
      permissionIds: _selectedPermissionIds,
      enable: true,
      isSystem: false,
      sort: 0,
    );
    
    ref.read(permissionsNotifierProvider.notifier)
        .createRole(newRole)
        .then((success) {
      if (success) {
        setState(() {
          _isAddingRole = false;
          _newRoleName = '';
          _newRoleCode = '';
          _newRoleDescription = '';
          _selectedPermissionIds = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('角色创建成功')),
        );
      }
    });
  }

  // 编辑角色
  void _editRole(Role role) {
    // 重置表单状态
    setState(() {
      _isAddingRole = true;
      _newRoleName = role.name;
      _newRoleCode = role.code;
      _newRoleDescription = role.description;
      _selectedPermissionIds = List.from(role.permissionIds);
    });
  }

  // 分配权限
  void _assignPermissions(Role role) {
    // 显示权限分配对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('为角色 "${role.name}" 分配权限'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: _buildPermissionTree(
              ref.read(permissionsNotifierProvider).permissions,
              initialSelectedIds: role.permissionIds,
              onSelectionChanged: (selectedIds) {
                _selectedPermissionIds = selectedIds;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(permissionsNotifierProvider.notifier)
                  .assignPermissionsToRole(role.id, _selectedPermissionIds)
                  .then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('权限分配成功')),
                  );
                }
              });
            },
            child: const Text('保存'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }

  // 删除角色
  void _deleteRole(Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除角色 "${role.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(permissionsNotifierProvider.notifier)
                  .deleteRole(role.id)
                  .then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('角色删除成功')),
                  );
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 编辑权限
  void _editPermission(Permission permission) {
    setState(() {
      _isEditingPermission = true;
      _editingPermission = permission;
      _editPermissionName = permission.name;
      _editPermissionCode = permission.code;
      _editPermissionType = permission.type;
      _editPermissionDescription = permission.description;
      _editPermissionParentId = permission.parentId;
      _editPermissionIsMenu = permission.isMenu;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑权限'),
        content: SizedBox(
          width: 500,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _editPermissionName,
                  decoration: const InputDecoration(
                    labelText: '权限名称',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _editPermissionName = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '权限名称不能为空';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editPermissionCode,
                  decoration: const InputDecoration(
                    labelText: '权限编码',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _editPermissionCode = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '权限编码不能为空';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _editPermissionType,
                  decoration: const InputDecoration(
                    labelText: '权限类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'menu', child: Text('菜单')),
                    DropdownMenuItem(value: 'button', child: Text('按钮')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _editPermissionType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editPermissionDescription,
                  decoration: const InputDecoration(
                    labelText: '权限描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    setState(() {
                      _editPermissionDescription = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('是否为菜单'),
                  value: _editPermissionIsMenu,
                  onChanged: (value) {
                    setState(() {
                      _editPermissionIsMenu = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isEditingPermission = false;
                _editingPermission = null;
              });
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _savePermission();
            },
            child: const Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }

  // 保存权限
  void _savePermission() {
    if (_editingPermission == null) return;
    
    if (_editPermissionName.isEmpty || _editPermissionCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('权限名称和编码不能为空'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final updatedPermission = Permission(
      id: _editingPermission!.id,
      name: _editPermissionName,
      code: _editPermissionCode,
      type: _editPermissionType,
      description: _editPermissionDescription,
      parentId: _editPermissionParentId,
      childrenIds: _editingPermission!.childrenIds,
      path: _editingPermission!.path,
      icon: _editingPermission!.icon,
      isMenu: _editPermissionIsMenu,
      enable: _editingPermission!.enable,
      sort: _editingPermission!.sort,
    );
    
    ref.read(permissionsNotifierProvider.notifier)
        .updatePermission(updatedPermission)
        .then((success) {
      if (success) {
        Navigator.pop(context);
        setState(() {
          _isEditingPermission = false;
          _editingPermission = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('权限更新成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('权限更新失败'), backgroundColor: Colors.red),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('权限更新失败: ${error.toString()}'), backgroundColor: Colors.red),
      );
    });
  }

  // 切换权限状态
  void _togglePermissionStatus(Permission permission) {
    ref.read(permissionsNotifierProvider.notifier)
        .togglePermissionStatus(permission.id)
        .then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('权限状态已切换')),
        );
      }
    });
  }
  
  // 构建权限树，支持初始选中和选择变化回调
  Widget _buildPermissionTree(List<Permission> permissions, {
    List<String> initialSelectedIds = const [],
    Function(List<String>)? onSelectionChanged,
  }) {
    // 构建权限树结构
    final rootPermissions = permissions
        .where((permission) => permission.parentId == null)
        .toList();
    
    return Column(
      children: rootPermissions.map((permission) {
        return _buildPermissionTreeNode(permission, permissions, 
            initialSelectedIds, onSelectionChanged);
      }).toList(),
    );
  }
  
  // 构建权限树节点，支持初始选中和选择变化回调
  Widget _buildPermissionTreeNode(Permission permission, List<Permission> allPermissions, 
      List<String> initialSelectedIds, Function(List<String>)? onSelectionChanged) {
    final children = allPermissions
        .where((p) => p.parentId == permission.id)
        .toList();
    
    // 检查当前节点是否被选中
    final isSelected = initialSelectedIds.contains(permission.id);
    
    // 检查是否有子节点被选中
    final hasSelectedChild = children.any((child) => initialSelectedIds.contains(child.id));
    // 检查所有子节点是否都被选中
    final allChildrenSelected = children.isNotEmpty && 
        children.every((child) => initialSelectedIds.contains(child.id));
    
    // 计算父节点的选中状态
    final indeterminate = !isSelected && hasSelectedChild;
    
    return ExpansionTile(
      initiallyExpanded: isSelected || hasSelectedChild, // 如果有选中的子节点，自动展开
      title: Row(
        children: [
          Checkbox(
            value: isSelected,
            tristate: true, // 支持半选状态
            onChanged: (checked) {
              setState(() {
                if (checked ?? false) {
                  // 选中当前节点和所有子节点
                  _selectPermissionWithChildren(permission, allPermissions);
                } else {
                  // 取消选中当前节点和所有子节点
                  _deselectPermissionWithChildren(permission, allPermissions);
                }
                
                // 通知父组件选择变化
                if (onSelectionChanged != null) {
                  onSelectionChanged(_selectedPermissionIds);
                }
              });
            },
          ),
          Expanded(
            child: Text(permission.name),
          ),
          Chip(
            label: Text(
              permission.type,
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: Colors.blue[50],
            labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
          ),
        ],
      ),
      children: children.map((child) {
        return Padding(
          padding: const EdgeInsets.only(left: 24),
          child: _buildPermissionTreeNode(
            child,
            allPermissions,
            initialSelectedIds,
            onSelectionChanged,
          ),
        );
      }).toList(),
    );
  }
  
  // 选中权限及其所有子权限
  void _selectPermissionWithChildren(Permission permission, List<Permission> allPermissions) {
    // 添加当前权限
    if (!_selectedPermissionIds.contains(permission.id)) {
      _selectedPermissionIds.add(permission.id);
    }
    
    // 递归添加所有子权限
    final children = allPermissions
        .where((p) => p.parentId == permission.id)
        .toList();
    
    for (final child in children) {
      _selectPermissionWithChildren(child, allPermissions);
    }
  }
  
  // 取消选中权限及其所有子权限
  void _deselectPermissionWithChildren(Permission permission, List<Permission> allPermissions) {
    // 移除当前权限
    _selectedPermissionIds.remove(permission.id);
    
    // 递归移除所有子权限
    final children = allPermissions
        .where((p) => p.parentId == permission.id)
        .toList();
    
    for (final child in children) {
      _deselectPermissionWithChildren(child, allPermissions);
    }
  }
}
