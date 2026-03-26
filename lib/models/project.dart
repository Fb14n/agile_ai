import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int teamSize;
  final int sprintLengthWeeks;
  final int currentSprintNumber;
  final double averageVelocity;
  final ProjectStatus status;

  Project({
    String? id,
    required this.name,
    required this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.teamSize = 5,
    this.sprintLengthWeeks = 2,
    this.currentSprintNumber = 1,
    this.averageVelocity = 0.0,
    this.status = ProjectStatus.active,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
    int? teamSize,
    int? sprintLengthWeeks,
    int? currentSprintNumber,
    double? averageVelocity,
    ProjectStatus? status,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      teamSize: teamSize ?? this.teamSize,
      sprintLengthWeeks: sprintLengthWeeks ?? this.sprintLengthWeeks,
      currentSprintNumber: currentSprintNumber ?? this.currentSprintNumber,
      averageVelocity: averageVelocity ?? this.averageVelocity,
      status: status ?? this.status,
    );
  }
}

enum ProjectStatus {
  active,
  archived;

  String toJson() => name;
  static ProjectStatus fromJson(String json) => values.firstWhere((v) => v.name == json);
}
