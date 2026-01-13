class CompanyInfo {
  final int? id;
  final String companyName;
  final String taxId;
  final String address;
  final String bankName;
  final String bankAccount;
  final String brand;
  final String contactPerson;
  final String contactPhone;
  final String modelPrefix;
  final String contractPrefix;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyInfo({
    this.id,
    required this.companyName,
    required this.taxId,
    required this.address,
    required this.bankName,
    required this.bankAccount,
    required this.brand,
    required this.contactPerson,
    required this.contactPhone,
    required this.modelPrefix,
    required this.contractPrefix,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'],
      companyName: json['companyName'],
      taxId: json['taxId'],
      address: json['address'],
      bankName: json['bankName'],
      bankAccount: json['bankAccount'],
      brand: json['brand'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      modelPrefix: json['modelPrefix'],
      contractPrefix: json['contractPrefix'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'taxId': taxId,
      'address': address,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'brand': brand,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'modelPrefix': modelPrefix,
      'contractPrefix': contractPrefix,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CompanyInfo copyWith({
    int? id,
    String? companyName,
    String? taxId,
    String? address,
    String? bankName,
    String? bankAccount,
    String? brand,
    String? contactPerson,
    String? contactPhone,
    String? modelPrefix,
    String? contractPrefix,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      taxId: taxId ?? this.taxId,
      address: address ?? this.address,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      brand: brand ?? this.brand,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      modelPrefix: modelPrefix ?? this.modelPrefix,
      contractPrefix: contractPrefix ?? this.contractPrefix,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}