import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project_context.g.dart';

@JsonSerializable()
class ProjectContext {
  final String id;
  final String projectId;
  final ContextType contextType;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectContext({
    String? id,
    required this.projectId,
    required this.contextType,
    required this.key,
    required this.value,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ProjectContext.fromJson(Map<String, dynamic> json) => _$ProjectContextFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectContextToJson(this);

  ProjectContext copyWith({
    String? value,
    DateTime? updatedAt,
  }) {
    return ProjectContext(
      id: id,
      projectId: projectId,
      contextType: contextType,
      key: key,
      value: value ?? this.value,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

enum ContextType {
  teamInfo,
  techStack,
  definitionOfDone,
  sprintGoal,
  customNote;

  String toJson() => name;
  static ContextType fromJson(String json) => values.firstWhere((v) => v.name == json);

  String get displayName {
    switch (this) {
      case ContextType.teamInfo:
        return 'Team Information';
      case ContextType.techStack:
        return 'Tech Stack';
      case ContextType.definitionOfDone:
        return 'Definition of Done';
      case ContextType.sprintGoal:
        return 'Sprint Goal';
      case ContextType.customNote:
        return 'Custom Note';
    }
  }
}
