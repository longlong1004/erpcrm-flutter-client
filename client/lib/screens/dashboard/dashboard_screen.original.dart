import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/dashboard_provider.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/shortcut_key_handler.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardAsyncValue = ref.watch(dashboardProvider);
    return ShortcutKeyHandler(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // 顶部操作栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '请输入客户名称、联系人姓名...',
                                hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 新增功能
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('新增', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 核心指标区域
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 业务回顾标签栏
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTagButton('我的'),
                        _buildTagButton('我负责的'),
                        _buildTagButton('昨天'),
                        _buildTagButton('今天', isActive: true),
                        _buildTagButton('上周'),
                        _buildTagButton('本周'),
                        _buildTagButton('上月'),
                        _buildTagButton('本月'),
                        _buildTagButton('上季度'),
                        _buildTagButton('本季度'),
                        _buildTagButton('去年'),
                        _buildTagButton('今年'),
                        _buildTagButton('全部', isOutline: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 核心指标卡片
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('新增客户数', '149家'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard('新增商机数', '27个'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard('商机预估金额', '717.51万元'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard('新增跟进数', '67次'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard('赢单数', '14个'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 业务关注和销售趋势图表区域
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧业务关注区域
                  Expanded(
                    flex: 3,
                    child: _buildBusinessFocusCard(),
                  ),
                  const SizedBox(width: 24),
                  // 右侧销售趋势图表
                  Expanded(
                    flex: 5,
                    child: _buildSalesTrendCard(),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 底部快速操作区域
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(Icons.add, '新增产品', '快速创建新产品'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(Icons.shopping_cart, '处理订单', '管理和处理销售订单'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(Icons.people, '管理客户', '维护客户信息'),
                  ),
                ],
              ),
              


            ],
          ),
        ),
    );
  }

  // 构建标签按钮
  Widget _buildTagButton(String label, {bool isActive = false, bool isOutline = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0066CC) : (isOutline ? Colors.transparent : const Color(0xFFF5F9FF)),
          borderRadius: BorderRadius.circular(16),
          border: isOutline ? Border.all(color: const Color(0xFF0066CC), width: 1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.white : const Color(0xFF666666),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 构建指标卡片
  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }

  // 构建业务关注卡片
  Widget _buildBusinessFocusCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '业务关注',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066CC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('跟进中', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 业务关注列表
          Column(
            children: [
              _buildBusinessItem('业务关注1', '北京铁路局北京西站', '李经理', '已跟进'),
              _buildBusinessItem('业务关注2', '上海铁路局上海站', '王经理', '待跟进'),
              _buildBusinessItem('业务关注3', '广州铁路局广州站', '张经理', '已跟进'),
              _buildBusinessItem('业务关注4', '成都铁路局成都站', '刘经理', '待跟进'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 底部操作
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('查看更多', style: TextStyle(color: Color(0xFF0066CC))),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Color(0xFF0066CC), size: 16),
                label: const Text('新增', style: TextStyle(color: Color(0xFF0066CC))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建业务关注列表项
  Widget _buildBusinessItem(String title, String company, String contact, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$company - $contact',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == '已跟进' ? const Color(0xFFE8F5E8) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: status == '已跟进' ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建销售趋势卡片
  Widget _buildSalesTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '销售趋势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 16, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  const Text('日', style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
                  const SizedBox(width: 16),
                  const Icon(Icons.refresh, size: 16, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  const Text('月', style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
                  const SizedBox(width: 16),
                  const Icon(Icons.settings, size: 16, color: Color(0xFF9E9E9E)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 日期选择器
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('12月29日', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(width: 8),
                const Text('→', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(width: 8),
                const Text('1月4日', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 周日期
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeekDay('日', '29'),
              _buildWeekDay('一', '30'),
              _buildWeekDay('二', '31'),
              _buildWeekDay('三', '1'),
              _buildWeekDay('四', '2'),
              _buildWeekDay('五', '3', isToday: true),
              _buildWeekDay('六', '4'),
            ],
          ),
          const SizedBox(height: 20),
          
          // 销售趋势图表
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('销售趋势图表区域'),
            ),
          ),
        ],
      ),
    );
  }

  // 构建周日期
  Widget _buildWeekDay(String day, String date, {bool isToday = false}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isToday ? const Color(0xFF0066CC) : const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF0066CC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isToday ? null : Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.white : const Color(0xFF1F1F1F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建快速操作卡片
  Widget _buildQuickActionCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0066CC), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  // 使用标签页系统添加新标签页的辅助方法
  void _navigateToTab(BuildContext context, WidgetRef ref, String title, String route) {
    ref.read(tabProvider.notifier).addTab(
      title: title,
      route: route,
    );
    context.go(route);
  }

  void onRefresh() {
    ref.invalidate(dashboardProvider);
  }
}