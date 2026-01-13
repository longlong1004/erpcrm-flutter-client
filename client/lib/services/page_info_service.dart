import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' as rootBundle;

// 页面详细信息数据结构
class PageInfo {
  final String title;
  final String description;
  final List<String> tableHeaders;
  final List<String> actionButtons;
  final String? parentTitle;

  PageInfo({
    required this.title,
    required this.description,
    required this.tableHeaders,
    required this.actionButtons,
    this.parentTitle,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      title: json['title'],
      description: json['description'],
      tableHeaders: List<String>.from(json['tableHeaders']),
      actionButtons: List<String>.from(json['actionButtons']),
      parentTitle: json['parentTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tableHeaders': tableHeaders,
      'actionButtons': actionButtons,
      'parentTitle': parentTitle,
    };
  }
}

// 页面信息管理服务
class PageInfoService {
  static final PageInfoService _instance = PageInfoService._internal();
  factory PageInfoService() => _instance;

  PageInfoService._internal();

  final Map<String, PageInfo> _pageInfoMap = {};
  bool _isInitialized = false;

  // 初始化，从文件加载页面信息
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 从导航数据文件中解析页面信息
      final data = await rootBundle.rootBundle.loadString('lib/assets/navigation_data.txt');
      _parseNavigationData(data);
      _isInitialized = true;
      print('页面信息服务初始化成功，加载了 ${_pageInfoMap.length} 个页面信息');
    } catch (e) {
      print('加载页面信息失败: $e');
      _isInitialized = false;
    }
  }

  // 解析导航数据文件
  void _parseNavigationData(String data) {
    // 这里需要根据实际的文件格式进行解析
    // 目前我们先创建一些默认的页面信息
    _addDefaultPageInfo();
  }

  // 添加默认页面信息
  void _addDefaultPageInfo() {
    // 仪表板页面
    _pageInfoMap['dashboard'] = PageInfo(
      title: '仪表板',
      description: '系统主页面，显示关键业务数据和统计信息',
      tableHeaders: ['指标名称', '数值', '同比', '环比'],
      actionButtons: ['刷新数据', '查看详情'],
    );

    // 订单管理页面
    _pageInfoMap['orders'] = PageInfo(
      title: '订单管理',
      description: '管理系统中的所有订单，包括商城订单、集货商订单等',
      tableHeaders: ['订单编号', '业务员', '客户名称', '订单金额', '状态', '创建时间', '操作'],
      actionButtons: ['新增订单', '导入订单', '批量删除', '查看详情', '编辑', '删除'],
    );

    // 业务管理页面
    _pageInfoMap['businesses'] = PageInfo(
      title: '业务管理',
      description: '管理业务相关的信息，包括国铁信息、先发货管理等',
      tableHeaders: ['业务编号', '业务员', '客户名称', '业务类型', '状态', '创建时间', '操作'],
      actionButtons: ['新增业务', '查看详情', '编辑', '删除'],
    );

    // 商品管理页面
    _pageInfoMap['products'] = PageInfo(
      title: '商品管理',
      description: '管理系统中的商品信息，包括申请上架、已上架商品等',
      tableHeaders: ['商品名称', '品牌', '国铁型号', '单价', '状态', '上架时间', '操作'],
      actionButtons: ['新增商品', '申请上架', '编辑', '删除', '打印合格证', '撤回'],
    );

    // 采购管理页面
    _pageInfoMap['procurement'] = PageInfo(
      title: '采购管理',
      description: '管理采购相关的信息，包括采购单、采购申请等',
      tableHeaders: ['采购单号', '业务员', '供应商', '采购金额', '状态', '创建时间', '操作'],
      actionButtons: ['新增采购申请', '生成合同', '上传凭证', '撤回', '查看详情'],
    );

    // 审批管理页面
    _pageInfoMap['approval'] = PageInfo(
      title: '审批管理',
      description: '管理需要审批的事项，包括待审核和已审核的内容',
      tableHeaders: ['序号', '业务员', '审批源', '创建时间', '审批时间', '操作'],
      actionButtons: ['查看', '审批'],
    );

    // 财务管理页面
    _pageInfoMap['finance'] = PageInfo(
      title: '财务管理',
      description: '管理财务相关的信息，包括应收、应付、发票等',
      tableHeaders: ['业务类型', '订单编号', '金额', '状态', '创建时间', '操作'],
      actionButtons: ['查看', '收款', '付款', '上传发票', '录入发票'],
    );

    // 物流管理页面
    _pageInfoMap['logistics'] = PageInfo(
      title: '物流管理',
      description: '管理物流相关的信息，包括发货、物流跟踪等',
      tableHeaders: ['订单编号', '物流单号', '物流公司', '发货时间', '状态', '操作'],
      actionButtons: ['查看', '发货', '上传发货单', '修改物流信息'],
    );

    // 仓库管理页面
    _pageInfoMap['warehouse'] = PageInfo(
      title: '仓库管理',
      description: '管理仓库相关的信息，包括库存、入库、出库等',
      tableHeaders: ['商品名称', '规格型号', '库存数量', '仓库', '操作'],
      actionButtons: ['新增商品', '入库申请', '出库申请', '报废申请', '查看', '编辑'],
    );

    // 基本信息页面
    _pageInfoMap['basic-info'] = PageInfo(
      title: '基本信息',
      description: '管理系统的基本信息，包括公司信息、客户信息等',
      tableHeaders: ['名称', '类型', '创建时间', '操作'],
      actionButtons: ['新增', '查看', '编辑', '删除'],
    );

    // 工资管理页面
    _pageInfoMap['salary'] = PageInfo(
      title: '工资管理',
      description: '管理员工的工资相关信息，包括考勤、请假、工资发放等',
      tableHeaders: ['员工姓名', '月份', '工资总额', '状态', '操作'],
      actionButtons: ['新增', '统计', '查看', '编辑', '审批'],
    );

    // 系统设置页面
    _pageInfoMap['settings'] = PageInfo(
      title: '系统设置',
      description: '管理系统的基本设置和配置',
      tableHeaders: ['设置项', '当前值', '操作'],
      actionButtons: ['修改', '保存', '重置'],
    );

    // 系统权限页面
    _pageInfoMap['permissions'] = PageInfo(
      title: '系统权限',
      description: '管理系统的用户权限和角色',
      tableHeaders: ['角色名称', '权限描述', '操作'],
      actionButtons: ['新增角色', '分配权限', '编辑', '删除'],
    );
  }

  // 获取页面信息
  PageInfo? getPageInfo(String route) {
    if (!_isInitialized) {
      print('页面信息服务未初始化');
      return null;
    }

    // 提取路由的主要部分作为key
    final routeKey = _extractRouteKey(route);
    return _pageInfoMap[routeKey];
  }

  // 提取路由的主要部分
  String _extractRouteKey(String route) {
    // 移除前导斜杠
    String key = route.startsWith('/') ? route.substring(1) : route;
    
    // 只保留第一级路由作为key
    if (key.contains('/')) {
      key = key.split('/').first;
    }
    
    return key;
  }

  // 获取所有页面信息
  Map<String, PageInfo> getAllPageInfo() {
    if (!_isInitialized) {
      print('页面信息服务未初始化');
      return {};
    }
    return Map.unmodifiable(_pageInfoMap);
  }
}