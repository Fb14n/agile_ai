import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project_team_member.g.dart';

@JsonSerializable()
class ProjectTeamMember {
  final String id;
  final String projectId;
  final String name;
  final String role;
  final bool active;

  ProjectTeamMember({
    String? id,
    required this.projectId,
    required this.name,
    this.role = 'Developer',
    this.active = true,
  }) : id = id ?? const Uuid().v4();

  factory ProjectTeamMember.fromJson(Map<String, dynamic> json) => _$ProjectTeamMemberFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectTeamMemberToJson(this);

  ProjectTeamMember copyWith({
    String? name,
    String? role,
    bool? active,
  }) {
    return ProjectTeamMember(
      id: id,
      projectId: projectId,
      name: name ?? this.name,
      role: role ?? this.role,
      active: active ?? this.active,
    );
  }

  static const List<String> availableRoles = [
    'Product Owner',
    'Scrum Master',
    'Backend Developer',
    'Frontend Developer',
    'Full-Stack Developer',
    'UX Designer',
    'UI Designer',
    'QA Engineer',
    'DevOps Engineer',
    'Tech Lead',
    'Stakeholder',
  ];
}
