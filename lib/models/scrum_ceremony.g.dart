// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrum_ceremony.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScrumCeremony _$ScrumCeremonyFromJson(Map<String, dynamic> json) =>
    ScrumCeremony(
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
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      summary: json['summary'] as String?,
      sentiment: json['sentiment'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ScrumCeremonyToJson(ScrumCeremony instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'participants': instance.participants,
      'notes': instance.notes,
      'summary': instance.summary,
      'sentiment': instance.sentiment,
    };
