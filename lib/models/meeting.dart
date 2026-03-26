import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'meeting.g.dart';

@JsonSerializable()
class Meeting {
  final String id;
  final String projectId;
  final String? sprintId;
  final MeetingType type;
  final DateTime date;
  final int durationMinutes;
  final List<String> participants;
  final String summary;
  final List<String> actionItems;
  final double? sentimentScore;

  Meeting({
    String? id,
    required this.projectId,
    this.sprintId,
    required this.type,
    DateTime? date,
    this.durationMinutes = 0,
    List<String>? participants,
    this.summary = '',
    List<String>? actionItems,
    this.sentimentScore,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        participants = participants ?? [],
        actionItems = actionItems ?? [];

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingToJson(this);

  Meeting copyWith({
    String? sprintId,
    int? durationMinutes,
    List<String>? participants,
    String? summary,
    List<String>? actionItems,
    double? sentimentScore,
  }) {
    return Meeting(
      id: id,
      projectId: projectId,
      sprintId: sprintId ?? this.sprintId,
      type: type,
      date: date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      participants: participants ?? this.participants,
      summary: summary ?? this.summary,
      actionItems: actionItems ?? this.actionItems,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }
}

enum MeetingType {
  daily,
  planning,
  review,
  retrospective,
  refinement;

  String toJson() => name;
  static MeetingType fromJson(String json) => values.firstWhere((v) => v.name == json);

  String get displayName {
    switch (this) {
      case MeetingType.daily:
        return 'Daily Standup';
      case MeetingType.planning:
        return 'Sprint Planning';
      case MeetingType.review:
        return 'Sprint Review';
      case MeetingType.retrospective:
        return 'Sprint Retrospective';
      case MeetingType.refinement:
        return 'Backlog Refinement';
    }
  }
}
