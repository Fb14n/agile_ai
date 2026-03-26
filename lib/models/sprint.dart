import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'sprint.g.dart';

@JsonSerializable()
class Sprint {
  final String id;
  final String projectId;
  final int sprintNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String goal;
  final int plannedStoryPoints;
  final int completedStoryPoints;
  final SprintStatus status;

  Sprint({
    String? id,
    required this.projectId,
    required this.sprintNumber,
    required this.startDate,
    required this.endDate,
    this.goal = '',
    this.plannedStoryPoints = 0,
    this.completedStoryPoints = 0,
    this.status = SprintStatus.planning,
  }) : id = id ?? const Uuid().v4();

  factory Sprint.fromJson(Map<String, dynamic> json) => _$SprintFromJson(json);
  Map<String, dynamic> toJson() => _$SprintToJson(this);

  Sprint copyWith({
    String? goal,
    int? plannedStoryPoints,
    int? completedStoryPoints,
    SprintStatus? status,
  }) {
    return Sprint(
      id: id,
      projectId: projectId,
      sprintNumber: sprintNumber,
      startDate: startDate,
      endDate: endDate,
      goal: goal ?? this.goal,
      plannedStoryPoints: plannedStoryPoints ?? this.plannedStoryPoints,
      completedStoryPoints: completedStoryPoints ?? this.completedStoryPoints,
      status: status ?? this.status,
    );
  }

  double get completionRate {
    if (plannedStoryPoints == 0) return 0.0;
    return (completedStoryPoints / plannedStoryPoints) * 100;
  }

  int get remainingStoryPoints => plannedStoryPoints - completedStoryPoints;
}

enum SprintStatus {
  planning,
  active,
  completed;

  String toJson() => name;
  static SprintStatus fromJson(String json) => values.firstWhere((v) => v.name == json);
}
