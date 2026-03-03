import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  Message({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.type = MessageType.text,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

enum MessageType {
  text,
  ceremony,
  insight,
  goal,
  sentiment,
  actionItem,
  impediment,
  risk,
  assessment,
  tip,
}
