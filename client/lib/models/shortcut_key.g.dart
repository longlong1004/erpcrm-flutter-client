// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortcutKey _$ShortcutKeyFromJson(Map<String, dynamic> json) => ShortcutKey(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      defaultKey: json['defaultKey'] as String,
      currentKey: json['currentKey'] as String?,
    );

Map<String, dynamic> _$ShortcutKeyToJson(ShortcutKey instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'defaultKey': instance.defaultKey,
      'currentKey': instance.currentKey,
    };
