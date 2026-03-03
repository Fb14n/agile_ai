// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlog_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$BacklogStatusEnumMap = {
  BacklogStatus.todo: 'todo',
  BacklogStatus.inProgress: 'inProgress',
  BacklogStatus.done: 'done',
  BacklogStatus.removed: 'removed',
};

BacklogItem _$BacklogItemFromJson(Map<String, dynamic> json) => BacklogItem(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  storyPoints: json['storyPoints'] as int?,
  status: $enumDecodeNullable(_$BacklogStatusEnumMap, json['status']) ?? BacklogStatus.todo,
  sprintNumber: json['sprintNumber'] as int?,
  acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BacklogItemToJson(BacklogItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'storyPoints': instance.storyPoints,
  'status': _$BacklogStatusEnumMap[instance.status]!,
  'sprintNumber': instance.sprintNumber,
  'acceptanceCriteria': instance.acceptanceCriteria,
  'createdAt': instance.createdAt.toIso8601String(),
};
