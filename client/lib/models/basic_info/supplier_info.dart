class SupplierInfo {
  final int? id;
  final String salesperson;
  final String supplierName;
  final String contactPerson;
  final String contactPhone;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierInfo({
    this.id,
    required this.salesperson,
    required this.supplierName,
    required this.contactPerson,
    required this.contactPhone,
    this.remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    return SupplierInfo(
      id: json['id'],
      salesperson: json['salesperson'],
      supplierName: json['supplierName'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salesperson': salesperson,
      'supplierName': supplierName,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SupplierInfo copyWith({
    int? id,
    String? salesperson,
    String? supplierName,
    String? contactPerson,
    String? contactPhone,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierInfo(
      id: id ?? this.id,
      salesperson: salesperson ?? this.salesperson,
      supplierName: supplierName ?? this.supplierName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}