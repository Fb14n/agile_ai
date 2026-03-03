// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrum_ceremony.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionItem _$ActionItemFromJson(Map<String, dynamic> json) => ActionItem(
  id: json['id'] as String?,
  text: json['text'] as String,
  assignee: json['assignee'] as String?,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$ActionItemToJson(ActionItem instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'assignee': instance.assignee,
  'dueDate': instance.dueDate?.toIso8601String(),
  'completed': instance.completed,
};

ScrumCeremony _$ScrumCeremonyFromJson(Map<String, dynamic> json) => ScrumCeremony(
  id: json['id'] as String?,
  name: json['name'] as String,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  participants: (json['participants'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notes: (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  summary: json['summary'] as String?,
  sentiment: json['sentiment'] as Map<String, dynamic>?,
  actionItems: (json['actionItems'] as List<dynamic>?)
      ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  sprintNumber: json['sprintNumber'] as int?,
  timeboxMinutes: json['timeboxMinutes'] as int?,
);

Map<String, dynamic> _$ScrumCeremonyToJson(ScrumCeremony instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'participants': instance.participants,
  'notes': instance.notes,
  'summary': instance.summary,
  'sentiment': instance.sentiment,
  'actionItems': instance.actionItems.map((e) => e.toJson()).toList(),
  'sprintNumber': instance.sprintNumber,
  'timeboxMinutes': instance.timeboxMinutes,
};
