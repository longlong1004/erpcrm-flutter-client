import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;
import '../models/order/order.dart';
import '../models/order/order_item.dart';

class ExcelService {
  // 生成订单Excel模板
  Future<void> generateOrderTemplate() async {
    // 创建Excel文件
    final excel = Excel.createExcel();
    
    // 获取默认工作表
    final sheet = excel['订单模板'];
    
    // 设置表头样式
    final headerStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 12,
      bold: true,
      fontColorHex: '#000000',
      backgroundColorHex: '#E0E0E0',
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    
    // 设置数据样式
    final dataStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 12,
      fontColorHex: '#000000',
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    
    // 定义表头，与页面显示字段一致
    final headers = [
      '业务员',
      '订单编号',
      '订单类型',
      '订单编号',
      '提交日期',
      '审批日期',
      '收货人姓名',
      '收货人电话',
      '收货地址',
      '所属路局',
      '站段',
      '公司名称',
      '品牌',
      '单品编码',
      '国铁名称',
      '国铁型号',
      '下单数量',
      '国铁单价',
      '国铁金额',
      '发票申请时间',
      '回款时间',
      '付款时间',
      '供应商',
      '实发名称',
      '实发型号',
      '采购单价',
      '实发数量',
      '单位',
      '采购金额',
      '备注',
      '付款方式',
      '发票类型',
      '进项发票时间',
      '运费',
      '补发货类型',
      '补发货名称',
      '补发货金额',
      '办理费用',
    ];
    
    // 写入表头
    for (var i = 0; i < headers.length; i++) {
      final cellIndex = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0);
      // 使用excel库的正确方式设置单元格值
      sheet.updateCell(cellIndex, headers[i], cellStyle: headerStyle);
      
      // 设置列宽
      sheet.setColWidth(i, 20);
    }
    
    // 写入示例数据
    final sampleData = [
      'admin',
      'ORDER-20250101-001',
      '其它订单',
      'ORDER-20250101-001',
      '2025-01-01',
      '2025-01-02',
      '张三',
      '13800138000',
      '北京市朝阳区',
      '北京铁路局',
      '北京站',
      '测试公司',
      '品牌A',
      'SKU001',
      '商品名称',
      '型号001',
      '10',
      '100.00',
      '1000.00',
      '2025-01-03',
      '2025-01-10',
      '2025-01-15',
      '供应商A',
      '商品名称',
      '型号001',
      '95.00',
      '10',
      '件',
      '950.00',
      '测试订单',
      '在线支付',
      '增值税专用发票',
      '2025-01-20',
      '50.00',
      '无',
      '',
      '',
      '0.00',
    ];
    
    for (var i = 0; i < headers.length; i++) {
      final cellIndex = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1);
      // 使用excel库的正确方式设置单元格值，确保所有表头都有示例数据
      sheet.updateCell(cellIndex, i < sampleData.length ? sampleData[i] : '', cellStyle: dataStyle);
    }
    
    // 保存文件
    final fileBytes = excel.encode()!;
    
    // 在Web平台上下载文件
    final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)..setAttribute('download', '订单模板.xlsx')..click();
    html.Url.revokeObjectUrl(url);
  }
  
  // 导入订单Excel文件
  Future<List<Order>> importOrdersFromExcel() async {
    // 选择文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    
    if (result == null || result.files.isEmpty) {
      throw Exception('未选择文件');
    }
    
    // 读取文件字节
    Uint8List bytes;
    if (result.files.single.bytes != null) {
      // 直接使用bytes（Web平台）
      bytes = result.files.single.bytes!;
    } else {
      // 对于其他平台，使用文件路径读取
      final filePath = result.files.single.path!;
      final file = html.File([], filePath);
      final reader = html.FileReader();
      reader.readAsArrayBuffer(html.File([], filePath));
      await reader.onLoad.first;
      bytes = Uint8List.fromList(reader.result as List<int>);
    }
    
    // 解析Excel文件
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;
    
    final orders = <Order>[];
    final orderItems = <OrderItem>[];
    
    // 从第二行开始读取数据（第一行是表头）
    for (var i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      
      // 跳过空行
      if (row.isEmpty || row[0]?.value == null) continue;
      
      // 解析订单数据
      final orderNumber = row[0]?.value?.toString() ?? '';
      final submittedDateStr = row[1]?.value?.toString() ?? '';
      final consigneeName = row[2]?.value?.toString() ?? '';
      final consigneePhone = row[3]?.value?.toString() ?? '';
      final shippingAddress = row[4]?.value?.toString() ?? '';
      final railwayBureau = row[5]?.value?.toString() ?? '';
      final station = row[6]?.value?.toString() ?? '';
      final companyName = row[7]?.value?.toString() ?? '';
      final brand = row[8]?.value?.toString() ?? '';
      final productCode = row[9]?.value?.toString() ?? '';
      final railwayName = row[10]?.value?.toString() ?? '';
      final railwayModel = row[11]?.value?.toString() ?? '';
      final unit = row[12]?.value?.toString() ?? '';
      final quantityStr = row[13]?.value?.toString() ?? '';
      final priceStr = row[14]?.value?.toString() ?? '';
      final amountStr = row[15]?.value?.toString() ?? '';
      final supplier = row[16]?.value?.toString() ?? '';
      final paymentMethod = row[17]?.value?.toString() ?? '';
      final invoiceType = row[18]?.value?.toString() ?? '';
      final notes = row[19]?.value?.toString() ?? '';
      
      // 转换数值类型
      final quantity = int.tryParse(quantityStr) ?? 0;
      final unitPrice = double.tryParse(priceStr) ?? 0.0;
      final subtotal = double.tryParse(amountStr) ?? 0.0;
      final submittedDate = DateTime.tryParse(submittedDateStr) ?? DateTime.now();
      
      // 创建订单项目
      final orderItem = OrderItem(
        id: DateTime.now().millisecondsSinceEpoch + i,
        productId: 0, // 临时ID，实际会由服务器生成
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
        productName: railwayName,
        productSku: productCode,
      );
      
      orderItems.add(orderItem);
      
      // 查找是否已存在该订单编号的订单
      final existingOrderIndex = orders.indexWhere((order) => order.orderNumber == orderNumber);
      
      if (existingOrderIndex == -1) {
        // 创建新订单
        final order = Order(
          id: DateTime.now().millisecondsSinceEpoch + i,
          orderNumber: orderNumber,
          userId: 0, // 临时用户ID，实际会由服务器生成
          orderItems: [orderItem],
          totalAmount: subtotal,
          status: 'PENDING',
          paymentMethod: paymentMethod,
          paymentStatus: 'UNPAID',
          shippingAddress: shippingAddress,
          billingAddress: shippingAddress,
          shippingMethod: '快递',
          trackingNumber: null,
          notes: notes,
          createdAt: submittedDate,
          updatedAt: submittedDate,
        );
        
        orders.add(order);
      } else {
        // 添加到现有订单
        final existingOrder = orders[existingOrderIndex];
        final updatedOrderItems = [...existingOrder.orderItems, orderItem];
        final updatedTotalAmount = updatedOrderItems.fold(0.0, (sum, item) => sum + item.subtotal);
        
        orders[existingOrderIndex] = Order(
          id: existingOrder.id,
          orderNumber: existingOrder.orderNumber,
          userId: existingOrder.userId,
          orderItems: updatedOrderItems,
          totalAmount: updatedTotalAmount,
          status: existingOrder.status,
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: existingOrder.paymentStatus,
          shippingAddress: existingOrder.shippingAddress,
          billingAddress: existingOrder.billingAddress,
          shippingMethod: existingOrder.shippingMethod,
          trackingNumber: existingOrder.trackingNumber,
          notes: existingOrder.notes,
          createdAt: existingOrder.createdAt,
          updatedAt: existingOrder.updatedAt,
        );
      }
    }
    
    return orders;
  }
  
  // 生成Excel模板并下载
  Future<void> downloadOrderTemplate() async {
    await generateOrderTemplate();
  }
}
