// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintData _$SprintDataFromJson(Map<String, dynamic> json) => SprintData(
  sprintNumber: json['sprintNumber'] as int,
  velocity: json['velocity'] as int?,
  plannedPoints: json['plannedPoints'] as int?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  goal: json['goal'] as String?,
  sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SprintDataToJson(SprintData instance) => <String, dynamic>{
  'sprintNumber': instance.sprintNumber,
  'velocity': instance.velocity,
  'plannedPoints': instance.plannedPoints,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'goal': instance.goal,
  'sentimentScore': instance.sentimentScore,
};
