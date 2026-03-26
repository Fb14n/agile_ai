// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStory _$UserStoryFromJson(Map<String, dynamic> json) => UserStory(
  id: json['id'] as String?,
  projectId: json['projectId'] as String,
  sprintId: json['sprintId'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  storyPoints: (json['storyPoints'] as num?)?.toInt() ?? 0,
  priority:
      $enumDecodeNullable(_$StoryPriorityEnumMap, json['priority']) ??
      StoryPriority.medium,
  status:
      $enumDecodeNullable(_$StoryStatusEnumMap, json['status']) ??
      StoryStatus.todo,
  acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserStoryToJson(UserStory instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'sprintId': instance.sprintId,
  'title': instance.title,
  'description': instance.description,
  'storyPoints': instance.storyPoints,
  'priority': instance.priority,
  'status': instance.status,
  'acceptanceCriteria': instance.acceptanceCriteria,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$StoryPriorityEnumMap = {
  StoryPriority.low: 'low',
  StoryPriority.medium: 'medium',
  StoryPriority.high: 'high',
  StoryPriority.critical: 'critical',
};

const _$StoryStatusEnumMap = {
  StoryStatus.todo: 'todo',
  StoryStatus.inProgress: 'inProgress',
  StoryStatus.done: 'done',
};
