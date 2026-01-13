import 'package:hive_flutter/hive_flutter.dart';

part 'tab_item.g.dart';

@HiveType(typeId: 30)
class TabItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String route;
  
  @HiveField(3)
  final String? subtitle;
  
  @HiveField(4)
  final bool isActive;
  
  @HiveField(5)
  final Map<String, dynamic>? params;
  
  @HiveField(6)
  final Map<String, dynamic>? queryParams;
  
  @HiveField(7)
  final Map<String, dynamic>? state;

  TabItem({
    required this.id,
    required this.title,
    required this.route,
    this.subtitle,
    required this.isActive,
    this.params,
    this.queryParams,
    this.state,
  });

  factory TabItem.create({
    required String title,
    required String route,
    String? subtitle,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? state,
  }) {
    return TabItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      route: route,
      subtitle: subtitle,
      isActive: true,
      params: params,
      queryParams: queryParams,
      state: state,
    );
  }

  TabItem copyWith({
    String? id,
    String? title,
    String? route,
    String? subtitle,
    bool? isActive,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? state,
  }) {
    return TabItem(
      id: id ?? this.id,
      title: title ?? this.title,
      route: route ?? this.route,
      subtitle: subtitle ?? this.subtitle,
      isActive: isActive ?? this.isActive,
      params: params ?? this.params,
      queryParams: queryParams ?? this.queryParams,
      state: state ?? this.state,
    );
  }
}
