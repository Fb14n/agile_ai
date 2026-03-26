// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
  id: json['id'] as String?,
  projectId: json['projectId'] as String,
  sprintId: json['sprintId'] as String?,
  type: $enumDecode(_$MeetingTypeEnumMap, json['type']),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
  participants: (json['participants'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  summary: json['summary'] as String? ?? '',
  actionItems: (json['actionItems'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'sprintId': instance.sprintId,
  'type': instance.type,
  'date': instance.date.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'participants': instance.participants,
  'summary': instance.summary,
  'actionItems': instance.actionItems,
  'sentimentScore': instance.sentimentScore,
};

const _$MeetingTypeEnumMap = {
  MeetingType.daily: 'daily',
  MeetingType.planning: 'planning',
  MeetingType.review: 'review',
  MeetingType.retrospective: 'retrospective',
  MeetingType.refinement: 'refinement',
};
