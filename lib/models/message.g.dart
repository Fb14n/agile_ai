// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String?,
  text: json['text'] as String,
  isUser: json['isUser'] as bool,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'isUser': instance.isUser,
  'timestamp': instance.timestamp.toIso8601String(),
  'type': _$MessageTypeEnumMap[instance.type]!,
  'metadata': instance.metadata,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.ceremony: 'ceremony',
  MessageType.insight: 'insight',
  MessageType.goal: 'goal',
  MessageType.sentiment: 'sentiment',
};
