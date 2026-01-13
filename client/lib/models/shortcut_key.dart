import 'package:json_annotation/json_annotation.dart';

part 'shortcut_key.g.dart';

@JsonSerializable()
class ShortcutKey {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'description')
  final String description;
  
  @JsonKey(name: 'defaultKey')
  final String defaultKey;
  
  @JsonKey(name: 'currentKey')
  final String? currentKey;

  ShortcutKey({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultKey,
    this.currentKey,
  });

  factory ShortcutKey.fromJson(Map<String, dynamic> json) => 
      _$ShortcutKeyFromJson(json);

  Map<String, dynamic> toJson() => _$ShortcutKeyToJson(this);

  ShortcutKey copyWith({
    String? currentKey,
  }) {
    return ShortcutKey(
      id: id,
      name: name,
      description: description,
      defaultKey: defaultKey,
      currentKey: currentKey ?? this.currentKey,
    );
  }

  String get displayName {
    final key = currentKey ?? defaultKey;
    return key;
  }
}
