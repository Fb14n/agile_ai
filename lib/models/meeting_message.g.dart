// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingMessage _$MeetingMessageFromJson(Map<String, dynamic> json) =>
    MeetingMessage(
      id: json['id'] as String?,
      meetingId: json['meetingId'] as String,
      isUser: json['isUser'] as bool,
      content: json['content'] as String,
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
          MessageType.user,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MeetingMessageToJson(MeetingMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meetingId': instance.meetingId,
      'isUser': instance.isUser,
      'content': instance.content,
      'messageType': instance.messageType,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.assistant: 'assistant',
  MessageType.system: 'system',
  MessageType.analysis: 'analysis',
  MessageType.suggestion: 'suggestion',
  MessageType.warning: 'warning',
};
