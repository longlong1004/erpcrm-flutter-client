-- 权限系统初始化数据

-- 1. 插入权限数据
INSERT INTO permissions (id, name, description, resource, action, created_at, updated_at) VALUES
-- 用户管理权限
(1, 'user:create', '创建用户', 'user', 'create', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'user:read', '查看用户', 'user', 'read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'user:update', '更新用户', 'user', 'update', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'user:delete', '删除用户', 'user', 'delete', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- 客户管理权限
(5, 'customer:create', '创建客户', 'customer', 'create', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 'customer:read', '查看客户', 'customer', 'read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 'customer:update', '更新客户', 'customer', 'update', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, 'customer:delete', '删除客户', 'customer', 'delete', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- 产品管理权限
(9, 'product:create', '创建产品', 'product', 'create', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(10, 'product:read', '查看产品', 'product', 'read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(11, 'product:update', '更新产品', 'product', 'update', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(12, 'product:delete', '删除产品', 'product', 'delete', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- 订单管理权限
(13, 'order:create', '创建订单', 'order', 'create', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(14, 'order:read', '查看订单', 'order', 'read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(15, 'order:update', '更新订单', 'order', 'update', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(16, 'order:delete', '删除订单', 'order', 'delete', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(17, 'order:approve', '审批订单', 'order', 'approve', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- 财务管理权限
(18, 'finance:read', '查看财务', 'finance', 'read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(19, 'finance:create', '创建财务记录', 'finance', 'create', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(20, 'finance:update', '更新财务', 'finance', 'update', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(21, 'finance:report', '财务报表', 'finance', 'report', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- 系统管理权限
(22, 'system:config', '系统配置', 'system', 'config', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(23, 'system:log', '系统日志', 'system', 'log', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(24, 'system:backup', '数据备份', 'system', 'backup', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(25, 'system:restore', '数据恢复', 'system', 'restore', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 2. 插入角色权限关联数据
-- 管理员拥有所有权限
INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),  -- 用户管理
(1, 5), (1, 6), (1, 7), (1, 8),  -- 客户管理
(1, 9), (1, 10), (1, 11), (1, 12), -- 产品管理
(1, 13), (1, 14), (1, 15), (1, 16), (1, 17), -- 订单管理
(1, 18), (1, 19), (1, 20), (1, 21), -- 财务管理
(1, 22), (1, 23), (1, 24), (1, 25); -- 系统管理

-- 经理拥有大部分权限，除了系统级操作
INSERT INTO role_permissions (role_id, permission_id) VALUES
(2, 1), (2, 2), (2, 3),  -- 用户管理（不能删除）
(2, 5), (2, 6), (2, 7), (2, 8),  -- 客户管理
(2, 9), (2, 10), (2, 11), (2, 12), -- 产品管理
(2, 13), (2, 14), (2, 15), (2, 16), (2, 17), -- 订单管理
(2, 18), (2, 19), (2, 20), (2, 21); -- 财务管理

-- 员工拥有基础业务权限
INSERT INTO role_permissions (role_id, permission_id) VALUES
(3, 6), -- 查看客户
(3, 10), -- 查看产品
(3, 14), -- 查看订单
(3, 13), -- 创建订单
(3, 15); -- 更新订单

-- 销售员拥有销售相关权限
INSERT INTO role_permissions (role_id, permission_id) VALUES
(4, 5), (4, 6), (4, 7), -- 客户管理
(4, 9), (4, 10), (4, 11), -- 产品管理
(4, 13), (4, 14), (4, 15), (4, 16), -- 订单管理
(4, 18); -- 查看财务

-- 财务人员拥有财务相关权限
INSERT INTO role_permissions (role_id, permission_id) VALUES
(5, 14), -- 查看订单
(5, 18), (5, 19), (5, 20), (5, 21); -- 财务管理全部权限