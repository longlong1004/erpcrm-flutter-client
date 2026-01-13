import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/menu_item.dart';

part 'navigation_provider.g.dart';

// 导航栏数据Provider
@riverpod
List<MenuItem> navigationMenuItems(NavigationMenuItemsRef ref) {
  // 构建完整的导航菜单结构，与sidebar.dart保持一致
  return [
    // 仪表板
    const MenuItem(
      title: '仪表板',
      icon: Icons.dashboard,
      route: '/dashboard',
      description: '系统主页面，显示关键业务数据和统计信息',
      tableHeaders: ['指标名称', '数值', '同比', '环比'],
      actionButtons: ['刷新数据', '查看详情'],
    ),
    
    // 订单管理
    MenuItem(
      title: '订单管理',
      icon: Icons.receipt_long_outlined,
      route: '/orders',
      description: '管理系统中的所有订单，包括国铁订单、对外业务订单等',
      tableHeaders: ['订单编号', '业务员', '客户名称', '订单金额', '状态', '创建时间', '操作'],
      actionButtons: ['新增订单', '导入订单', '批量删除', '查看详情', '编辑', '删除'],
      children: [
        MenuItem(
          title: '国铁订单',
          icon: Icons.train_outlined,
          description: '管理国铁相关订单，包括商城订单、集货商订单等',
          children: [
            MenuItem(
              title: '商城订单', 
              icon: Icons.shopping_cart, 
              description: '管理商城订单，包括待审核、已审核、待发货等状态',
              children: [
                const MenuItem(
                  title: '商城订单总表',
                  icon: Icons.list,
                  route: '/orders/mall/total',
                  description: '商城订单总表，包含完整的订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '发票申请时间', '回款时间', '付款时间', '供应商', '实发名称', '实发型号', '采购单价', '实发数量', '单位', '采购金额', '备注', '付款方式', '发票类型', '进项发票时间', '运费', '补发货类型', '补发货名称', '补发货金额', '办理费用', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '导入信息',
                  icon: Icons.upload,
                  route: '/orders/mall/import',
                  description: '管理导入的商城订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '操作时间', '导入时间', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '待发货',
                  icon: Icons.local_shipping,
                  route: '/orders/mall/pending-delivery',
                  description: '管理待发货的商城订单',
                  tableHeaders: ['业务员', '状态', '订单编号', '下单数量', '匹配数量', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '物流公司', '物流单号', '提交日期', '审批日期', '匹配时间', '操作'],
                  actionButtons: ['修改业务员', '查看', '发货', '编辑', '删除'],
                ),
              ],
            ),
            MenuItem(
              title: '集货商订单', 
              icon: Icons.business, 
              description: '管理集货商订单',
              children: [
                const MenuItem(
                  title: '集货商订单总表',
                  icon: Icons.list,
                  route: '/orders/collector/total',
                  description: '集货商订单总表，包含完整的订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '结算金额', '发票申请时间', '回款时间', '付款时间', '供应商', '实发名称', '实发型号', '采购单价', '实发数量', '单位', '采购金额', '备注', '付款方式', '发票类型', '进项发票时间', '运费', '补发货类型', '补发货名称', '补发货金额', '办理费用', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '导入信息',
                  icon: Icons.upload,
                  route: '/orders/collector/import',
                  description: '管理导入的集货商订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '操作时间', '导入时间', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '待发货',
                  icon: Icons.local_shipping,
                  route: '/orders/collector/pending-delivery',
                  description: '管理待发货的集货商订单',
                  tableHeaders: ['业务员', '状态', '订单编号', '下单数量', '匹配数量', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '物流公司', '物流单号', '提交日期', '审批日期', '匹配时间', '操作'],
                  actionButtons: ['修改业务员', '查看', '发货', '编辑', '上传发货单', '删除'],
                ),
              ],
            ),
            MenuItem(
              title: '其它订单', 
              icon: Icons.more_horiz, 
              description: '管理其它类型的订单',
              children: [
                const MenuItem(
                  title: '其它订单总表',
                  icon: Icons.list,
                  route: '/orders/other/total',
                  description: '其它订单总表，包含完整的订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '订单类型', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '发票申请时间', '回款时间', '付款时间', '供应商', '实发名称', '实发型号', '采购单价', '实发数量', '单位', '采购金额', '备注', '付款方式', '发票类型', '进项发票时间', '运费', '补发货类型', '补发货名称', '补发货金额', '办理费用', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '导入信息',
                  icon: Icons.upload,
                  route: '/orders/other/import',
                  description: '管理导入的其它订单信息',
                  tableHeaders: ['勾选', '业务员', '订单编号', '订单类型', '订单编号', '提交日期', '审批日期', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '品牌', '单品编码', '国铁名称', '国铁型号', '下单数量', '国铁单价', '国铁金额', '操作时间', '导入时间', '操作'],
                  actionButtons: ['导入', '删除'],
                ),
                const MenuItem(
                  title: '待发货',
                  icon: Icons.local_shipping,
                  route: '/orders/other/pending-delivery',
                  description: '管理待发货的其它订单',
                  tableHeaders: ['业务员', '状态', '订单类型', '订单编号', '下单数量', '匹配数量', '收货人姓名', '收货人电话', '收货地址', '所属路局', '站段', '公司名称', '物流公司', '物流单号', '提交日期', '审批日期', '匹配时间', '操作'],
                  actionButtons: ['修改业务员', '查看', '发货', '编辑', '删除'],
                ),
              ],
            ),
            const MenuItem(
              title: '补发货（退换货）', 
              icon: Icons.arrow_circle_right, 
              route: '/orders/replenishment',
              description: '管理补发货订单',
              tableHeaders: ['业务员', '状态', '订单类型', '订单编号', '公司名称', '所属路局', '所属站段', '收货人姓名', '收货人电话', '收货地址', '备注', '创建时间', '操作'],
              actionButtons: ['新增'],
            ),
            const MenuItem(
              title: '办理', 
              icon: Icons.check_circle, 
              route: '/orders/handling',
              description: '办理订单相关业务',
              tableHeaders: ['业务员', '订单编号', '品牌', '站段', '单品编码', '国铁名称', '国铁型号', '单位', '数量', '单价', '合计', '利润', '办理百分比', '办理金额', '时间'],
              actionButtons: ['办理'],
            ),
          ],
        ),
        const MenuItem(
          title: '对外业务订单', 
          icon: Icons.people, 
          route: '/orders/external',
          description: '管理对外业务订单',
          tableHeaders: ['业务员', '状态', '客户公司名称', '公司名称', '物资名称', '规格型号', '单位', '数量', '金额', '操作'],
          actionButtons: ['新增', '导入'],
        ),
      ],
    ),
    
    // 业务管理
    MenuItem(
      title: '业务管理',
      icon: Icons.business_outlined,
      route: '/businesses',
      description: '管理业务相关的信息，包括国铁信息、先发货管理等',
      tableHeaders: ['业务编号', '业务员', '客户名称', '业务类型', '状态', '创建时间', '操作'],
      actionButtons: ['新增业务', '查看详情', '编辑', '删除'],
      children: [
        MenuItem(
          title: '国铁信息专区',
          icon: Icons.info_outline,
          description: '国铁相关信息管理',
          children: [
            MenuItem(
              title: '批量采购', 
              icon: Icons.batch_prediction, 
              description: '管理批量采购信息',
              children: [
                const MenuItem(
                  title: '可参与', 
                  icon: Icons.check_circle_outline, 
                  route: '/businesses/batch-purchase/participable',
                  description: '可参与的批量采购信息',
                  tableHeaders: ['公告名称', '发布时间', '品牌', '商品类别', '参与起止时间', '业务员', '状态', '查看时间', '操作'],
                  actionButtons: ['查看', '报备'],
                ),
                const MenuItem(
                  title: '类目符合', 
                  icon: Icons.category, 
                  route: '/businesses/batch-purchase/category-match',
                  description: '类目符合的批量采购信息',
                  tableHeaders: ['公告名称', '发布时间', '品牌', '商品类别', '参与起止时间', '查看时间', '操作'],
                  actionButtons: ['查看'],
                ),
                const MenuItem(
                  title: '类目不符合', 
                  icon: Icons.category_outlined, 
                  route: '/businesses/batch-purchase/category-not-match',
                  description: '类目不符合的批量采购信息',
                  tableHeaders: ['公告名称', '发布时间', '品牌', '商品类别', '参与起止时间', '查看时间', '操作'],
                  actionButtons: ['查看'],
                ),
              ],
            ),
            const MenuItem(
              title: '招标信息', 
              icon: Icons.assignment, 
              route: '/businesses/bidding',
              description: '管理招标信息',
              tableHeaders: ['公告名称', '发布时间', '状态', '操作'],
              actionButtons: ['查看', '报备'],
            ),
            const MenuItem(
              title: '竞价信息', 
              icon: Icons.assessment, 
              route: '/businesses/auction',
              description: '管理竞价信息',
              tableHeaders: ['公告名称', '发布时间', '状态', '操作'],
              actionButtons: ['查看', '报备'],
            ),
          ],
        ),
        const MenuItem(
          title: '先发货管理', 
          icon: Icons.local_shipping, 
          route: '/businesses/pre-delivery',
          description: '管理先发货业务',
          tableHeaders: ['状态', '业务员', '编号', '公司名称', '所属路局', '所属站段', '客户', '未匹配数量', '品牌', '单品编码', '国铁名称', '国铁型号', '单位', '国铁单价', '实发数量', '金额', '付款情况', '发货情况', '操作'],
          actionButtons: ['查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '先报计划管理', 
          icon: Icons.assignment_add, 
          route: '/businesses/pre-plan',
          description: '管理先报计划业务',
          tableHeaders: ['状态', '业务员', '编号', '公司名称', '所属路局', '所属站段', '客户', '未匹配数量', '品牌', '单品编码', '国铁名称', '国铁型号', '单位', '国铁单价', '金额', '操作'],
          actionButtons: ['查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '线索', 
          icon: Icons.search, 
          route: '/businesses/leads',
          description: '管理业务线索',
          tableHeaders: ['线索来源', '业务员', '公告名称', '客户单位', '联系人', '联系电话', '创建时间', '报名截止时间', '操作'],
          actionButtons: ['我想联系', '暂不联系'],
        ),
        const MenuItem(
          title: '商机', 
          icon: Icons.trending_up, 
          route: '/businesses/opportunities',
          description: '管理商机信息',
          tableHeaders: ['商机来源', '业务员', '公告名称', '客户单位', '联系人', '联系电话', '创建时间', '最后跟进时间', '下次跟进时间', '最新跟进内容', '状态', '操作'],
          actionButtons: ['查看', '暂不联系'],
        ),
        const MenuItem(
          title: '公海池', 
          icon: Icons.public, 
          route: '/businesses/public-pool',
          description: '管理公海池商机',
          tableHeaders: ['商机来源', '业务员', '公告名称', '客户单位', '联系人', '联系电话', '创建时间', '进入公海池时间', '操作'],
          actionButtons: ['查看', '我想联系'],
        ),
      ],
    ),
    
    // 商品管理
    MenuItem(
      title: '商品管理',
      icon: Icons.shopping_cart_outlined,
      route: '/products',
      description: '管理系统中的商品信息，包括申请上架、已上架和回收站',
      children: [
        // 申请上架
        const MenuItem(
          title: '申请上架',
          icon: Icons.cloud_upload,
          route: '/products/apply',
          description: '管理申请上架的商品',
          tableHeaders: ['状态', '业务员', '公司名称', '品牌', '国铁名称', '国铁型号', '单位', '国铁单价', '三级分类', '操作'],
          actionButtons: ['新增商品', '查看', '编辑', '打印合格证', '撤回', '删除'],
        ),
        // 已上架
        const MenuItem(
          title: '已上架',
          icon: Icons.check_circle_outline,
          route: '/products/approved',
          description: '管理已上架的商品',
          tableHeaders: ['状态', '业务员', '上架天数', '未下单天数', '公司名称', '品牌', '商品编码', '单品编码', '国铁名称', '国铁型号', '单位', '国铁单价', '三级分类', '操作'],
          actionButtons: ['导入', '查看', '编辑', '复制', '打印合格证', '删除'],
        ),
        // 回收站
        const MenuItem(
          title: '回收站',
          icon: Icons.delete_outline,
          route: '/products/recycle',
          description: '管理回收站中的商品',
          tableHeaders: ['状态', '业务员', '公司名称', '品牌', '国铁名称', '国铁型号', '单位', '国铁单价', '三级分类', '操作'],
          actionButtons: ['查看', '编辑', '打印合格证'],
        ),
      ],
    ),
    
    // 采购管理
    MenuItem(
      title: '采购管理',
      icon: Icons.shopping_bag_outlined,
      route: '/procurement',
      description: '管理采购相关的信息，包括采购单、采购申请等',
      tableHeaders: ['采购单号', '业务员', '供应商', '采购金额', '状态', '创建时间', '操作'],
      actionButtons: ['新增采购申请', '生成合同', '上传凭证', '撤回', '查看详情'],
      children: [
        const MenuItem(
          title: '采购单', 
          icon: Icons.shopping_cart, 
          route: '/procurement/orders',
          description: '管理采购单',
          tableHeaders: ['业务员', '状态', '订单编号', '公司', '供应商', '数量', '金额', '备注', '创建时间', '付款凭证', '操作'],
          actionButtons: ['查看', '上传凭证', '撤回'],
        ),
        const MenuItem(
          title: '采购申请', 
          icon: Icons.assignment_add, 
          route: '/procurement/applications',
          description: '管理采购申请',
          tableHeaders: ['业务员', '状态', '公司', '采购物资名称', '型号', '数量', '单价', '单位', '金额', '操作'],
          actionButtons: ['查看', '编辑', '撤回'],
        ),
      ],
    ),
    
    // 审批管理
    MenuItem(
      title: '审批管理',
      icon: Icons.check_circle_outline,
      route: '/approval',
      description: '管理需要审批的事项，包括待审核和已审核的内容',
      tableHeaders: ['序号', '业务员', '审批源', '创建时间', '操作'],
      actionButtons: ['查看', '审批'],
      children: [
        const MenuItem(
          title: '待审核', 
          icon: Icons.pending, 
          route: '/approval/pending',
          description: '管理待审核的事项',
          tableHeaders: ['序号', '业务员', '审批源', '创建时间', '操作'],
          actionButtons: ['查看', '审批'],
        ),
        const MenuItem(
          title: '已审核', 
          icon: Icons.check_circle, 
          route: '/approval/approved',
          description: '管理已审核的事项',
          tableHeaders: ['序号', '业务员', '审批源', '创建时间', '审批时间', '操作'],
          actionButtons: ['查看'],
        ),
      ],
    ),
    
    // 财务管理
    MenuItem(
      title: '财务管理',
      icon: Icons.attach_money_outlined,
      route: '/finance',
      description: '管理财务相关的信息，包括应收、应付、发票等',
      tableHeaders: ['业务类型', '订单编号', '金额', '状态', '创建时间', '操作'],
      actionButtons: ['查看', '收款', '付款', '上传发票', '录入发票'],
      children: [
        MenuItem(
          title: '应收',
          icon: Icons.arrow_upward,
          description: '管理应收账款',
          children: [
            const MenuItem(
              title: '商城应收', 
              icon: Icons.shopping_cart, 
              route: '/finance/receivable/mall',
              description: '管理商城应收账款',
              tableHeaders: ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'],
              actionButtons: ['查看', '收款'],
            ),
            const MenuItem(
              title: '集货商应收', 
              icon: Icons.business, 
              route: '/finance/receivable/collector',
              description: '管理集货商应收账款',
              tableHeaders: ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'],
              actionButtons: ['查看', '收款'],
            ),
            const MenuItem(
              title: '其它业务应收', 
              icon: Icons.more_horiz, 
              route: '/finance/receivable/other',
              description: '管理其它业务应收账款',
              tableHeaders: ['业务员', '状态', '业务类型', '订单编号', '所属路局', '所属站段', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'],
              actionButtons: ['查看', '收款'],
            ),
            const MenuItem(
              title: '对外业务应收', 
              icon: Icons.people, 
              route: '/finance/receivable/external',
              description: '管理对外业务应收账款',
              tableHeaders: ['业务员', '状态', '客户公司名称', '联系人', '联系电话', '国铁名称', '国铁型号', '国铁单价', '单位', '应收金额', '操作'],
              actionButtons: ['查看', '收款'],
            ),
          ],
        ),
        const MenuItem(
          title: '应付', 
          icon: Icons.arrow_downward, 
          route: '/finance/payable',
          description: '管理应付账款',
          tableHeaders: ['业务员', '订单编号', '状态', '类型', '付款方', '付款方式', '收款方', '联系人', '单据类型', '应付欠款', '欠款类型', '采购凭证', '国铁凭证', '付款日期', '操作'],
          actionButtons: ['查看', '付款', '付款申请单', '驳回'],
        ),
        MenuItem(
          title: '发票',
          icon: Icons.receipt,
          description: '管理发票信息',
          children: [
            const MenuItem(
              title: '进项发票', 
              icon: Icons.arrow_downward, 
              route: '/finance/invoice/incoming',
              description: '管理进项发票',
              tableHeaders: ['业务员', '状态', '类型', '订单编号', '供应商', '付款金额', '付款日期', '发票号', '发票金额', '开票日期', '操作'],
              actionButtons: ['查看', '上传', '录入'],
            ),
            const MenuItem(
              title: '销项发票', 
              icon: Icons.arrow_outward, 
              route: '/finance/invoice/outgoing',
              description: '管理销项发票',
              tableHeaders: ['录入时间', '公司名称', '申请单号', '申请时间', '账单编号', '发票类型', '发票抬头', '纳税人识别码', '开户银行', '银行账户', '注册地址', '注册电话', '收票人姓名', '收票人地址', '收票人电话', '明细', '总金额', '备注', '结果', '发票状态', '开票状态', '操作'],
              actionButtons: ['修改', '编辑', '开票'],
            ),
          ],
        ),
        const MenuItem(
          title: '其它收入', 
          icon: Icons.add_circle, 
          route: '/finance/income/other',
          description: '管理其它收入',
          tableHeaders: ['业务员', '编号', '付款单位', '收款单位', '收入类型', '收款金额', '备注', '操作'],
          actionButtons: ['查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '其他支出', 
          icon: Icons.remove_circle, 
          route: '/finance/expense/other',
          description: '管理其他支出',
          tableHeaders: ['业务员', '编号', '付款单位', '收款单位', '支出类型', '支出金额', '备注', '操作'],
          actionButtons: ['查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '报销', 
          icon: Icons.receipt_long, 
          route: '/finance/reimbursement',
          description: '管理报销事项',
          tableHeaders: ['业务员', '状态', '报销类型', '关联单号', '公司名称', '报销金额', '报销凭证', '备注', '操作'],
          actionButtons: ['查看', '编辑', '撤回', '上传', '删除'],
        ),
      ],
    ),
    
    // 物流管理
    MenuItem(
      title: '物流管理',
      icon: Icons.local_shipping_outlined,
      route: '/logistics',
      description: '管理物流相关的信息，包括发货、物流跟踪等',
      tableHeaders: ['订单编号', '物流单号', '物流公司', '发货时间', '状态', '操作'],
      actionButtons: ['查看', '发货', '上传发货单', '修改物流信息'],
      children: [
        const MenuItem(
          title: '先发货物流', 
          icon: Icons.local_shipping, 
          route: '/logistics/pre-delivery',
          description: '管理先发货物流信息',
          tableHeaders: ['业务员', '状态', '发货类型', '编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'],
          actionButtons: ['查看', '发货'],
        ),
        const MenuItem(
          title: '商城订单物流', 
          icon: Icons.shopping_cart, 
          route: '/logistics/mall',
          description: '管理商城订单物流信息',
          tableHeaders: ['业务员', '状态', '发货类型', '订单编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'],
          actionButtons: ['查看', '发货'],
        ),
        const MenuItem(
          title: '集货商订单物流', 
          icon: Icons.business, 
          route: '/logistics/collector',
          description: '管理集货商订单物流信息',
          tableHeaders: ['业务员', '状态', '发货类型', '订单编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'],
          actionButtons: ['查看', '发货'],
        ),
        const MenuItem(
          title: '其它业务物流', 
          icon: Icons.more_horiz, 
          route: '/logistics/other',
          description: '管理其它业务物流信息',
          tableHeaders: ['业务员', '状态', '发货类型', '订单编号', '客户名称', '物资名称', '规格型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'],
          actionButtons: ['查看', '发货'],
        ),
      ],
    ),
    
    // 仓库管理
    MenuItem(
      title: '仓库管理',
      icon: Icons.warehouse_outlined,
      route: '/warehouse',
      description: '管理仓库相关的信息，包括库存、入库、出库等',
      tableHeaders: ['商品名称', '规格型号', '库存数量', '仓库', '操作'],
      actionButtons: ['新增商品', '入库申请', '出库申请', '报废申请', '查看', '编辑'],
      children: [
        const MenuItem(
          title: '库存商品', 
          icon: Icons.inventory, 
          route: '/warehouse/inventory',
          description: '管理库存商品',
          tableHeaders: ['序号', '货架号', '关联单品编码', '商品名称', '商品型号', '单位', '仓库', '库存数量', '备注', '实物图片', '操作'],
          actionButtons: ['查看', '编辑'],
        ),
        const MenuItem(
          title: '商品查询', 
          icon: Icons.search, 
          route: '/warehouse/search',
          description: '查询商品信息',
          tableHeaders: ['序号', '商品名称', '商品型号', '单位', '实物图片', '备注', '操作'],
          actionButtons: ['编辑', '删除'],
        ),
        const MenuItem(
          title: '入库申请', 
          icon: Icons.arrow_downward, 
          route: '/warehouse/warehousing',
          description: '管理入库申请',
          tableHeaders: ['业务员', '状态', '入库单号', '商品名称', '商品型号', '备注', '创建时间', '操作'],
          actionButtons: ['查看', '编辑', '撤回'],
        ),
        const MenuItem(
          title: '出库申请', 
          icon: Icons.arrow_outward, 
          route: '/warehouse/delivery',
          description: '管理出库申请',
          tableHeaders: ['业务员', '状态', '出库单号', '商品名称', '商品型号', '备注', '创建时间', '操作'],
          actionButtons: ['查看', '编辑', '撤回'],
        ),
        const MenuItem(
          title: '报废', 
          icon: Icons.delete, 
          route: '/warehouse/scrap',
          description: '管理报废商品',
          tableHeaders: ['业务员', '状态', '报废单号', '商品名称', '商品型号', '备注', '创建时间', '操作'],
          actionButtons: ['查看', '编辑', '撤回'],
        ),
      ],
    ),
    
    // 基本信息
    MenuItem(
      title: '基本信息',
      icon: Icons.info_outline,
      route: '/basic-info',
      description: '管理系统的基本信息，包括公司信息、客户信息等',
      tableHeaders: ['名称', '类型', '创建时间', '操作'],
      actionButtons: ['新增', '查看', '编辑', '删除'],
      children: [
        const MenuItem(
          title: '公司信息', 
          icon: Icons.business, 
          route: '/basic-info/company',
          description: '管理公司信息',
          tableHeaders: ['序号', '公司名称', '税号', '地址', '开户行', '账户', '品牌', '联系人', '联系电话', '型号前缀', '合同前缀', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        MenuItem(
          title: '客户信息',
          icon: Icons.people,
          description: '管理客户信息',
          children: [
            const MenuItem(
              title: '路局站段', 
              icon: Icons.location_city, 
              route: '/basic-info/customer/railway',
              description: '管理路局站段信息',
              tableHeaders: ['序号', '路局', '站段', '未下单天数', '操作'],
              actionButtons: ['新增', '查看', '编辑', '删除'],
            ),
            const MenuItem(
              title: '客户联系方式', 
              icon: Icons.contact_phone, 
              route: '/basic-info/customer/contacts',
              description: '管理客户联系方式',
              tableHeaders: ['序号', '业务员', '路局', '站段', '联系人', '联系电话', '科室', '职位', '备注', '操作'],
              actionButtons: ['新增', '查看', '编辑', '删除'],
            ),
          ],
        ),
        const MenuItem(
          title: '供应商信息', 
          icon: Icons.business, 
          route: '/basic-info/supplier',
          description: '管理供应商信息',
          tableHeaders: ['序号', '业务员', '供应商名称', '联系人', '联系电话', '备注', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '单位', 
          icon: Icons.category, 
          route: '/basic-info/unit',
          description: '管理单位信息',
          tableHeaders: ['序号', '单位', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '三级分类', 
          icon: Icons.sort, 
          route: '/basic-info/category',
          description: '管理三级分类信息',
          tableHeaders: ['序号', '公司名称', '分类', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '税收分类', 
          icon: Icons.monetization_on, 
          route: '/basic-info/tax-category',
          description: '管理税收分类信息',
          tableHeaders: ['序号', '税收分类编码', '税收分类编码短码', '商品名称', '商品和服务分类简称', '说明', '增值税税率', '关键字', '是否汇总项', '增值税特殊管理', '增值税政策依据', '消费税政策依据', '消费税政策', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '模板', 
          icon: Icons.file_copy, 
          route: '/basic-info/template',
          description: '管理模板信息',
          tableHeaders: ['序号', '模版名称', '关联对象', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '员工信息', 
          icon: Icons.person, 
          route: '/basic-info/employee',
          description: '管理员工信息',
          tableHeaders: ['序号', '登录账号', '业务员', '联系方式', '所属部门', '所属岗位', '创建时间', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '部门', 
          icon: Icons.groups, 
          route: '/basic-info/department',
          description: '管理部门信息',
          tableHeaders: ['序号', '部门名称', '负责人', '联系电话', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '岗位', 
          icon: Icons.work, 
          route: '/basic-info/position',
          description: '管理岗位信息',
          tableHeaders: ['序号', '岗位名称', '操作'],
          actionButtons: ['新增', '查看', '编辑', '删除'],
        ),
      ],
    ),
    
    // 薪酬管理
    MenuItem(
      title: '薪酬管理',
      icon: Icons.payments_outlined,
      route: '/salary',
      description: '管理员工的薪酬相关信息，包括考勤、请假、工资发放等',
      tableHeaders: ['员工姓名', '月份', '工资总额', '状态', '操作'],
      actionButtons: ['新增', '统计', '查看', '编辑', '审批'],
      children: [
        const MenuItem(
          title: '考勤', 
          icon: Icons.access_time, 
          route: '/salary/attendance',
          description: '管理员工考勤信息',
          tableHeaders: ['业务员', '状态', '操作'],
          actionButtons: ['新增', '统计', '查看'],
        ),
        const MenuItem(
          title: '请假', 
          icon: Icons.request_page, 
          route: '/salary/leave',
          description: '管理员工请假信息',
          tableHeaders: ['业务员', '状态', '请假时间', '请假理由', '操作'],
          actionButtons: ['申请', '查看', '撤回', '删除'],
        ),
        const MenuItem(
          title: '出差', 
          icon: Icons.flight_takeoff, 
          route: '/salary/business-trip',
          description: '管理员工出差信息',
          tableHeaders: ['业务员', '状态', '出差时间', '出差站段', '出差地点', '操作'],
          actionButtons: ['申请', '查看', '撤回', '删除'],
        ),
        const MenuItem(
          title: '积分', 
          icon: Icons.star, 
          route: '/salary/points',
          description: '管理员工积分信息',
          tableHeaders: ['业务员', '剩余积分', '积分变动', '备注', '操作'],
          actionButtons: ['新增', '统计', '查看', '编辑'],
        ),
        const MenuItem(
          title: '工资', 
          icon: Icons.payment, 
          route: '/salary/salary',
          description: '管理员工工资信息',
          tableHeaders: ['业务员', '日期', '工资', '操作'],
          actionButtons: ['新增', '统计', '查看'],
        ),
        const MenuItem(
          title: '其它奖金', 
          icon: Icons.card_giftcard, 
          route: '/salary/bonus',
          description: '管理员工其它奖金信息',
          tableHeaders: ['业务员', '日期', '奖金', '操作'],
          actionButtons: ['新增', '统计', '查看'],
        ),
      ],
    ),
    
    // 系统设置
    MenuItem(
      title: '系统设置',
      icon: Icons.settings_outlined,
      route: '/settings',
      description: '管理系统的基本设置和配置',
      tableHeaders: ['设置项', '当前值', '操作'],
      actionButtons: ['修改', '保存', '重置'],
      children: [
        const MenuItem(
          title: '流程设计',
          icon: Icons.assignment_ind,
          route: '/settings/process-design',
          description: '设计和管理系统中的审批流程',
          tableHeaders: ['流程名称', '流程类型', '创建时间', '状态', '操作'],
          actionButtons: ['创建流程', '查看详情', '编辑', '删除'],
        ),
        const MenuItem(
          title: '替换审批人',
          icon: Icons.swap_horiz,
          route: '/settings/approval-delegate',
          description: '管理审批人的临时代理规则，允许批量设置代理关系',
          tableHeaders: ['原审核人', '代理审核人', '时间范围', '状态', '操作'],
        ),
        const MenuItem(
          title: '日志管理',
          icon: Icons.history,
          route: '/settings/log-management',
          description: '查看和管理系统日志，包括操作日志、系统日志等',
          tableHeaders: ['日志类型', '操作人', '操作内容', '操作时间', 'IP地址'],
          actionButtons: ['搜索', '过滤', '导出', '清除'],
        ),
        const MenuItem(
          title: '系统参数',
          icon: Icons.tune,
          route: '/settings/system-parameters',
          description: '管理系统的各种参数配置',
          tableHeaders: ['参数名称', '参数键', '参数值', '参数说明', '操作'],
          actionButtons: ['搜索', '分组查看', '导入', '导出', '修改', '重置'],
        ),
        const MenuItem(
          title: '数据字典',
          icon: Icons.book,
          route: '/settings/data-dictionary',
          description: '管理系统中的数据字典项',
          tableHeaders: ['字典编码', '字典名称', '字典项编码', '字典项名称', '排序', '状态', '操作'],
          actionButtons: ['添加', '编辑', '删除', '启用/禁用'],
        ),
        const MenuItem(
          title: '系统扩展工厂',
          icon: Icons.factory_outlined,
          route: '/settings/system-factory',
          description: '动态管理系统UI和导航结构，包括动态字段配置和动态导航菜单',
          tableHeaders: ['配置项', '状态', '创建时间', '操作'],
          actionButtons: ['保存到本地', '同步', '模拟发布', '正式发布'],
        ),
        const MenuItem(
          title: '日志管理',
          icon: Icons.history,
          route: '/settings/log-management',
          description: '查看和管理系统操作日志，支持按时间、用户、操作类型筛选',
          tableHeaders: ['日志ID', '操作人', '操作类型', '操作内容', '操作时间', 'IP地址'],
          actionButtons: ['查看详情', '导出日志', '清空日志'],
          requiredPermissions: ['LOG_MANAGEMENT'],
        ),
        const MenuItem(
          title: '系统参数',
          icon: Icons.tune,
          route: '/settings/system-parameters',
          description: '配置系统全局参数，包括系统名称、版本、邮件服务器等',
          tableHeaders: ['参数名', '参数值', '参数类型', '参数描述', '修改时间'],
          actionButtons: ['修改参数', '重置参数', '导出参数'],
          requiredPermissions: ['SYSTEM_PARAMETER_MANAGEMENT'],
        ),
        const MenuItem(
          title: '数据字典',
          icon: Icons.book,
          route: '/settings/data-dictionary',
          description: '管理系统数据字典，包括代码表、枚举值等基础数据',
          tableHeaders: ['字典类型', '字典编码', '字典名称', '排序', '状态'],
          actionButtons: ['添加字典', '编辑字典', '删除字典', '导入/导出'],
          requiredPermissions: ['DATA_DICTIONARY_MANAGEMENT'],
        ),
      ],
    ),
    
    // CRM管理系统
    MenuItem(
      title: 'CRM管理系统',
      icon: Icons.people_outlined,
      route: '/customers',
      description: '管理客户关系，包括客户信息、联系人记录、销售机会等',
      children: [
        const MenuItem(
          title: '客户管理',
          icon: Icons.person,
          route: '/customers',
          description: '管理系统中的客户信息',
          tableHeaders: ['业务员', '客户名称', '客户类型', '所属行业', '创建时间', '操作'],
          actionButtons: ['新增客户', '查看', '编辑', '删除', '导出'],
        ),
        const MenuItem(
          title: '客户分类',
          icon: Icons.category,
          route: '/customers/categories',
          description: '管理客户分类信息',
          tableHeaders: ['分类名称', '描述', '创建时间', '操作'],
          actionButtons: ['新增分类', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '客户标签',
          icon: Icons.label,
          route: '/customers/tags',
          description: '管理客户标签信息',
          tableHeaders: ['标签名称', '使用次数', '创建时间', '操作'],
          actionButtons: ['新增标签', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '客户联系记录',
          icon: Icons.history,
          route: '/customers/contact-logs',
          description: '管理客户联系记录',
          tableHeaders: ['业务员', '客户名称', '联系人', '联系方式', '联系时间', '内容', '操作'],
          actionButtons: ['新增记录', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: '销售机会',
          icon: Icons.trending_up,
          route: '/customers/sales-opportunities',
          description: '管理销售机会',
          tableHeaders: ['业务员', '客户名称', '机会名称', '预计金额', '成功概率', '状态', '操作'],
          actionButtons: ['新增机会', '查看', '编辑', '删除', '导出'],
        ),
        const MenuItem(
          title: '联系人管理',
          icon: Icons.contacts,
          route: '/customers/contacts',
          description: '管理客户联系人信息',
          tableHeaders: ['业务员', '客户名称', '联系人姓名', '职位', '联系电话', '邮箱', '操作'],
          actionButtons: ['新增联系人', '查看', '编辑', '删除'],
        ),
        const MenuItem(
          title: 'AI智能分析机器人',
          icon: Icons.analytics_outlined,
          route: '/customers/ai-analysis',
          description: 'AI驱动的销售数据分析与决策支持，包括客户等级、客户画像、销售趋势等',
          tableHeaders: ['分析类型', '分析结果', '置信度', '更新时间', '操作'],
          actionButtons: ['生成报告', '查看详情', '导出', '刷新'],
        ),
      ],
    ),
    
    // 消息通知
    MenuItem(
      title: '消息通知',
      icon: Icons.notifications_outlined,
      route: '/notifications',
      description: '管理系统中的消息通知',
      tableHeaders: ['通知标题', '类型', '发送者', '接收时间', '状态', '操作'],
      actionButtons: ['查看详情', '标记已读', '删除', '设置'],
      children: [
        const MenuItem(
          title: '通知列表',
          icon: Icons.list,
          route: '/notifications',
          description: '查看所有消息通知',
          tableHeaders: ['通知标题', '类型', '发送者', '接收时间', '状态', '操作'],
          actionButtons: ['查看详情', '标记已读', '删除'],
        ),
        const MenuItem(
          title: '通知设置',
          icon: Icons.settings,
          route: '/notifications/settings',
          description: '设置消息通知偏好，包括铃声、震动等',
          tableHeaders: ['设置项', '当前值', '操作'],
          actionButtons: ['修改', '保存', '重置'],
        ),
      ],
    ),
    
    // 系统权限
    const MenuItem(
      title: '系统权限',
      icon: Icons.security_outlined,
      route: '/permissions',
      description: '管理系统的用户权限和角色',
      tableHeaders: ['角色名称', '权限描述', '操作'],
      actionButtons: ['新增角色', '分配权限', '编辑', '删除'],
    ),
  ];
}

// 扁平化处理导航菜单，获取所有带有route的菜单项
@riverpod
List<MenuItem> allNavigationItems(AllNavigationItemsRef ref) {
  final menuItems = ref.watch(navigationMenuItemsProvider);
  final List<MenuItem> allItems = [];
  
  void _flattenMenuItems(List<MenuItem> items) {
    for (final item in items) {
      if (item.route != null) {
        allItems.add(item);
      }
      if (item.children != null && item.children!.isNotEmpty) {
        _flattenMenuItems(item.children!);
      }
    }
  }
  
  _flattenMenuItems(menuItems);
  return allItems;
}
