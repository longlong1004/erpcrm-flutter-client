class RailwayStation {
  final int? id;
  final String railwayBureau;
  final String station;
  final int? daysWithoutOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  RailwayStation({
    this.id,
    required this.railwayBureau,
    required this.station,
    this.daysWithoutOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RailwayStation.fromJson(Map<String, dynamic> json) {
    return RailwayStation(
      id: json['id'],
      railwayBureau: json['railwayBureau'],
      station: json['station'],
      daysWithoutOrder: json['daysWithoutOrder'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'railwayBureau': railwayBureau,
      'station': station,
      'daysWithoutOrder': daysWithoutOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RailwayStation copyWith({
    int? id,
    String? railwayBureau,
    String? station,
    int? daysWithoutOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RailwayStation(
      id: id ?? this.id,
      railwayBureau: railwayBureau ?? this.railwayBureau,
      station: station ?? this.station,
      daysWithoutOrder: daysWithoutOrder ?? this.daysWithoutOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}