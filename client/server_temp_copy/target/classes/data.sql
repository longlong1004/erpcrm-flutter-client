-- ERP+CRM国铁商城系统 初始化数据
-- 插入基础业务数据

-- 1. 插入角色数据
INSERT INTO roles (id, name, description, created_at, updated_at) VALUES
(1, 'ROLE_ADMIN', '系统管理员', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'ROLE_MANAGER', '部门经理', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'ROLE_EMPLOYEE', '普通员工', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'ROLE_SALES', '销售员', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'ROLE_FINANCE', '财务人员', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 2. 插入用户数据
INSERT INTO users (id, username, email, password_hash, role_id, created_at, updated_at, is_active) VALUES
(1, 'admin', 'admin@erpcrm.com', '$2a$10$9l5V8K9Y8Q9X9Q9X9Q9Q9O9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
(2, 'manager', 'manager@erpcrm.com', '$2a$10$8l4V7K8Y8Q9X9Q9X9Q9Q9O9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
(3, 'sales1', 'sales1@erpcrm.com', '$2a$10$7l3V6K7Y8Q9X9Q9X9Q9Q9O9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
(4, 'finance1', 'finance1@erpcrm.com', '$2a$10$6l2V5K6Y8Q9X9Q9X9Q9Q9O9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X9Q9X', 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- 3. 插入客户分类
INSERT INTO customer_categories (id, name, description, created_at, updated_at) VALUES
(1, '国铁企业', '国家铁路局及其下属企业', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, '铁路供应商', '铁路相关设备和材料供应商', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, '工程承包商', '铁路工程建设承包企业', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, '服务企业', '为铁路提供服务的各类企业', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, '其他企业', '其他类型企业客户', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 4. 插入产品分类
INSERT INTO product_categories (id, name, description, created_at, updated_at) VALUES
(1, '轨道设备', '铁路轨道相关设备', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, '信号系统', '铁路信号控制设备', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, '电气设备', '铁路电气化相关设备', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, '通信设备', '铁路通信相关设备', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, '工程机械', '铁路工程建设机械', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, '安全设备', '铁路安全防护设备', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, '配件材料', '铁路配件和维护材料', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, '技术服务', '铁路相关技术服务', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 5. 插入客户数据
INSERT INTO customers (id, customer_code, name, contact_person, phone, email, address, customer_type, created_by, created_at, updated_at) VALUES
(1, 'CUST001', '中国铁路北京局集团有限公司', '张三', '010-12345678', 'beijing@railway.cn', '北京市海淀区复兴路10号', 'enterprise', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'CUST002', '中国铁路上海局集团有限公司', '李四', '021-87654321', 'shanghai@railway.cn', '上海市静安区天目东路80号', 'enterprise', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'CUST003', '中铁轨道装备集团股份有限公司', '王五', '022-88888888', 'crrc@crrc.com', '天津市东丽区华明高新区', 'enterprise', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'CUST004', '中国铁路通信信号股份有限公司', '赵六', '010-51888888', 'crsc@crsc.com', '北京市丰台区南四环西路188号', 'enterprise', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'CUST005', '中铁电气化局集团有限公司', '钱七', '010-51888888', 'eeb@eeb.com', '北京市石景山区鲁谷路74号', 'enterprise', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 6. 插入产品数据
INSERT INTO products (id, product_code, name, category_id, description, price, cost, stock_quantity, min_stock, unit, status, created_at, updated_at) VALUES
(1, 'PROD001', '高速铁路轨道扣件', 1, '用于固定高速铁路轨道的扣件系统', 120.50, 85.30, 5000, 500, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'PROD002', '铁路信号机控制系统', 2, '铁路信号控制机及配套设备', 85000.00, 62000.00, 50, 10, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'PROD003', '接触网悬挂系统', 3, '电气化铁路接触网悬挂装置', 15000.00, 11000.00, 200, 30, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'PROD004', '铁路无线通信设备', 4, '铁路调度通信系统设备', 45000.00, 32000.00, 80, 15, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'PROD005', '轨道铺设机', 5, '自动化轨道铺设机械设备', 2800000.00, 2100000.00, 5, 1, '台', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 'PROD006', '铁路防护栏系统', 6, '铁路沿线安全防护栏', 280.00, 195.00, 3000, 300, '米', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 'PROD007', '铁路道岔系统', 1, '铁路道岔转换控制系统', 120000.00, 85000.00, 30, 5, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, 'PROD008', '轨道维护工具套装', 7, '轨道维护专用工具组合', 3200.00, 2300.00, 150, 20, '套', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 7. 插入供应商数据
INSERT INTO suppliers (id, supplier_code, name, contact_person, phone, email, address, status, created_at, updated_at) VALUES
(1, 'SUP001', '中铁轨道设备有限公司', '周总', '0311-88886666', 'zhou@ztgd.com', '河北省石家庄市裕华区', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'SUP002', '中国铁路信号技术有限公司', '吴经理', '010-67891234', 'wu@crs.com', '北京市大兴区科创十一街', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'SUP003', '中车电气技术有限公司', '郑主任', '0379-66668888', 'zheng@crec.com', '河南省洛阳市高新区', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 8. 插入仓库数据
INSERT INTO warehouses (id, warehouse_code, name, address, manager_name, manager_phone, capacity, status, created_at, updated_at) VALUES
(1, 'WH001', '北京中心仓库', '北京市房山区良乡镇', '仓库管理员1', '010-51381234', 10000, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'WH002', '上海南翔仓库', '上海市嘉定区南翔镇', '仓库管理员2', '021-69172345', 8000, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'WH003', '天津滨海仓库', '天津市滨海新区', '仓库管理员3', '022-65283456', 6000, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 9. 插入订单数据
INSERT INTO orders (id, order_no, customer_id, total_amount, status, order_date, delivery_address, contact_person, contact_phone, created_by, created_at, updated_at) VALUES
(1, 'ORD20231223001', 1, 850000.00, 'confirmed', CURRENT_TIMESTAMP, '北京市海淀区复兴路10号', '张三', '010-12345678', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'ORD20231223002', 2, 450000.00, 'confirmed', CURRENT_TIMESTAMP, '上海市静安区天目东路80号', '李四', '021-87654321', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'ORD20231223003', 3, 1200000.00, 'processing', CURRENT_TIMESTAMP, '天津市东丽区华明高新区', '王五', '022-88888888', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 10. 插入订单明细数据
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price, discount, subtotal) VALUES
(1, 1, 2, 5, 85000.00, 5000.00, 420000.00),
(2, 1, 3, 10, 15000.00, 1000.00, 149000.00),
(3, 1, 4, 6, 45000.00, 2000.00, 268000.00),
(4, 2, 2, 2, 85000.00, 0.00, 170000.00),
(5, 2, 4, 2, 45000.00, 1000.00, 89000.00),
(6, 2, 6, 100, 280.00, 500.00, 27500.00),
(7, 3, 5, 1, 2800000.00, 50000.00, 2750000.00);

-- 11. 插入部门数据
INSERT INTO departments (id, name, code, description, parent_id, manager_id, created_at, updated_at) VALUES
(1, '总经办', 'GEN_OFFICE', '公司最高管理机构', NULL, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, '销售部', 'SALES', '负责产品销售和客户关系', 1, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, '财务部', 'FINANCE', '负责财务管理和会计核算', 1, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, '技术部', 'TECH', '负责技术支持和产品研发', 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, '运营部', 'OPERATION', '负责日常运营和管理', 1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);