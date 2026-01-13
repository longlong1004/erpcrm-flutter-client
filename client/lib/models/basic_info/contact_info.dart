class ContactInfo {
  final int? id;
  final String salesperson;
  final String railwayBureau;
  final String station;
  final String contactPerson;
  final String contactPhone;
  final String department;
  final String position;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactInfo({
    this.id,
    required this.salesperson,
    required this.railwayBureau,
    required this.station,
    required this.contactPerson,
    required this.contactPhone,
    required this.department,
    required this.position,
    this.remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      id: json['id'],
      salesperson: json['salesperson'],
      railwayBureau: json['railwayBureau'],
      station: json['station'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      department: json['department'],
      position: json['position'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salesperson': salesperson,
      'railwayBureau': railwayBureau,
      'station': station,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'department': department,
      'position': position,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContactInfo copyWith({
    int? id,
    String? salesperson,
    String? railwayBureau,
    String? station,
    String? contactPerson,
    String? contactPhone,
    String? department,
    String? position,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactInfo(
      id: id ?? this.id,
      salesperson: salesperson ?? this.salesperson,
      railwayBureau: railwayBureau ?? this.railwayBureau,
      station: station ?? this.station,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      department: department ?? this.department,
      position: position ?? this.position,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}