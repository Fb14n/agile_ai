import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'scrum_ceremony.g.dart';

@JsonSerializable()
class ActionItem {
  final String id;
  final String text;
  final String? assignee;
  final DateTime? dueDate;
  bool completed;

  ActionItem({
    String? id,
    required this.text,
    this.assignee,
    this.dueDate,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  factory ActionItem.fromJson(Map<String, dynamic> json) => _$ActionItemFromJson(json);
  Map<String, dynamic> toJson() => _$ActionItemToJson(this);

  ActionItem copyWith({
    String? text,
    String? assignee,
    DateTime? dueDate,
    bool? completed,
  }) {
    return ActionItem(
      id: id,
      text: text ?? this.text,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }
}

@JsonSerializable()
class ScrumCeremony {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> participants;
  final List<String> notes;
  final String? summary;
  final Map<String, dynamic>? sentiment;
  final List<ActionItem> actionItems;
  final int? sprintNumber;
  final int timeboxMinutes;

  ScrumCeremony({
    String? id,
    required this.name,
    DateTime? startTime,
    this.endTime,
    List<String>? participants,
    List<String>? notes,
    this.summary,
    this.sentiment,
    List<ActionItem>? actionItems,
    this.sprintNumber,
    int? timeboxMinutes,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        participants = participants ?? [],
        notes = notes ?? [],
        actionItems = actionItems ?? [],
        timeboxMinutes = timeboxMinutes ?? _defaultTimebox(name);

  static int _defaultTimebox(String name) {
    switch (name) {
      case 'Daily Standup':
        return 15;
      case 'Sprint Planning':
        return 240;
      case 'Sprint Review':
        return 60;
      case 'Sprint Retrospective':
        return 90;
      case 'Backlog Refinement':
        return 120;
      default:
        return 60;
    }
  }

  factory ScrumCeremony.fromJson(Map<String, dynamic> json) => _$ScrumCeremonyFromJson(json);
  Map<String, dynamic> toJson() => _$ScrumCeremonyToJson(this);

  ScrumCeremony copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? participants,
    List<String>? notes,
    String? summary,
    Map<String, dynamic>? sentiment,
    List<ActionItem>? actionItems,
    int? sprintNumber,
    int? timeboxMinutes,
  }) {
    return ScrumCeremony(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participants: participants ?? this.participants,
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
      sentiment: sentiment ?? this.sentiment,
      actionItems: actionItems ?? this.actionItems,
      sprintNumber: sprintNumber ?? this.sprintNumber,
      timeboxMinutes: timeboxMinutes ?? this.timeboxMinutes,
    );
  }
}
