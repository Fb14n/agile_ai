import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_story.g.dart';

@JsonSerializable()
class UserStory {
  final String id;
  final String projectId;
  final String? sprintId;
  final String title;
  final String description;
  final int storyPoints;
  final StoryPriority priority;
  final StoryStatus status;
  final List<String> acceptanceCriteria;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStory({
    String? id,
    required this.projectId,
    this.sprintId,
    required this.title,
    this.description = '',
    this.storyPoints = 0,
    this.priority = StoryPriority.medium,
    this.status = StoryStatus.todo,
    List<String>? acceptanceCriteria,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        acceptanceCriteria = acceptanceCriteria ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserStory.fromJson(Map<String, dynamic> json) => _$UserStoryFromJson(json);
  Map<String, dynamic> toJson() => _$UserStoryToJson(this);

  UserStory copyWith({
    String? sprintId,
    String? title,
    String? description,
    int? storyPoints,
    StoryPriority? priority,
    StoryStatus? status,
    List<String>? acceptanceCriteria,
    DateTime? updatedAt,
  }) {
    return UserStory(
      id: id,
      projectId: projectId,
      sprintId: sprintId ?? this.sprintId,
      title: title ?? this.title,
      description: description ?? this.description,
      storyPoints: storyPoints ?? this.storyPoints,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

enum StoryPriority {
  low,
  medium,
  high,
  critical;

  String toJson() => name;
  static StoryPriority fromJson(String json) => values.firstWhere((v) => v.name == json);
}

enum StoryStatus {
  todo,
  inProgress,
  done;

  String toJson() => name;
  static StoryStatus fromJson(String json) => values.firstWhere((v) => v.name == json);
}
