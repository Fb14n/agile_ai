import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'meeting_message.g.dart';

@JsonSerializable()
class MeetingMessage {
  final String id;
  final String meetingId;
  final bool isUser;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  MeetingMessage({
    String? id,
    required this.meetingId,
    required this.isUser,
    required this.content,
    this.messageType = MessageType.user,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        metadata = metadata ?? {};

  factory MeetingMessage.fromJson(Map<String, dynamic> json) => _$MeetingMessageFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingMessageToJson(this);
}

enum MessageType {
  user,
  assistant,
  system,
  analysis,
  suggestion,
  warning;

  String toJson() => name;
  static MessageType fromJson(String json) => values.firstWhere((v) => v.name == json);
}
