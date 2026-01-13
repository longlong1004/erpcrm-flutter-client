class ProcurementApplication {
  final int id;
  final String salesman;
  final String company;
  final String materialName;
  final String model;
  final double quantity;
  final double unitPrice;
  final String unit;
  final double amount;
  final String status;
  final DateTime createdAt;

  ProcurementApplication({
    required this.id,
    required this.salesman,
    required this.company,
    required this.materialName,
    required this.model,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  // 从JSON创建ProcurementApplication实例
  factory ProcurementApplication.fromJson(Map<String, dynamic> json) {
    return ProcurementApplication(
      id: json['id'] as int,
      salesman: json['salesman'] as String,
      company: json['company'] as String,
      materialName: json['materialName'] as String,
      model: json['model'] as String,
      quantity: json['quantity'] as double,
      unitPrice: json['unitPrice'] as double,
      unit: json['unit'] as String,
      amount: json['amount'] as double,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 将ProcurementApplication实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salesman': salesman,
      'company': company,
      'materialName': materialName,
      'model': model,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unit': unit,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 创建新采购申请的工厂方法
  factory ProcurementApplication.create({
    required String salesman,
    required String company,
    required String materialName,
    required String model,
    required double quantity,
    required double unitPrice,
    required String unit,
  }) {
    final amount = quantity * unitPrice;
    return ProcurementApplication(
      id: DateTime.now().millisecondsSinceEpoch, // 使用时间戳作为临时ID
      salesman: salesman,
      company: company,
      materialName: materialName,
      model: model,
      quantity: quantity,
      unitPrice: unitPrice,
      unit: unit,
      amount: amount,
      status: '待审批', // 初始状态为待审批
      createdAt: DateTime.now(),
    );
  }
}
