// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  id: json['id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  teamSize: (json['teamSize'] as num?)?.toInt() ?? 5,
  sprintLengthWeeks: (json['sprintLengthWeeks'] as num?)?.toInt() ?? 2,
  currentSprintNumber: (json['currentSprintNumber'] as num?)?.toInt() ?? 1,
  averageVelocity: (json['averageVelocity'] as num?)?.toDouble() ?? 0.0,
  status:
      $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']) ??
      ProjectStatus.active,
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'teamSize': instance.teamSize,
  'sprintLengthWeeks': instance.sprintLengthWeeks,
  'currentSprintNumber': instance.currentSprintNumber,
  'averageVelocity': instance.averageVelocity,
  'status': instance.status,
};

const _$ProjectStatusEnumMap = {
  ProjectStatus.active: 'active',
  ProjectStatus.archived: 'archived',
};
