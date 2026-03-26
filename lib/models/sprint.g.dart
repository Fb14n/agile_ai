// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sprint _$SprintFromJson(Map<String, dynamic> json) => Sprint(
  id: json['id'] as String?,
  projectId: json['projectId'] as String,
  sprintNumber: (json['sprintNumber'] as num).toInt(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  goal: json['goal'] as String? ?? '',
  plannedStoryPoints: (json['plannedStoryPoints'] as num?)?.toInt() ?? 0,
  completedStoryPoints: (json['completedStoryPoints'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$SprintStatusEnumMap, json['status']) ??
      SprintStatus.planning,
);

Map<String, dynamic> _$SprintToJson(Sprint instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'sprintNumber': instance.sprintNumber,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'goal': instance.goal,
  'plannedStoryPoints': instance.plannedStoryPoints,
  'completedStoryPoints': instance.completedStoryPoints,
  'status': instance.status,
};

const _$SprintStatusEnumMap = {
  SprintStatus.planning: 'planning',
  SprintStatus.active: 'active',
  SprintStatus.completed: 'completed',
};
