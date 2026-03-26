// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectContext _$ProjectContextFromJson(Map<String, dynamic> json) =>
    ProjectContext(
      id: json['id'] as String?,
      projectId: json['projectId'] as String,
      contextType: $enumDecode(_$ContextTypeEnumMap, json['contextType']),
      key: json['key'] as String,
      value: json['value'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectContextToJson(ProjectContext instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'contextType': instance.contextType,
      'key': instance.key,
      'value': instance.value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ContextTypeEnumMap = {
  ContextType.teamInfo: 'teamInfo',
  ContextType.techStack: 'techStack',
  ContextType.definitionOfDone: 'definitionOfDone',
  ContextType.sprintGoal: 'sprintGoal',
  ContextType.customNote: 'customNote',
};
