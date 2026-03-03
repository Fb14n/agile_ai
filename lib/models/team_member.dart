import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'team_member.g.dart';

@JsonSerializable()
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String colorHex;

  TeamMember({
    String? id,
    required this.name,
    this.role = 'Developer',
    String? colorHex,
  })  : id = id ?? const Uuid().v4(),
        colorHex = colorHex ?? _defaultColors[name.hashCode.abs() % _defaultColors.length];

  static const List<String> _defaultColors = [
    '#6750A4', '#B5179E', '#0077B6', '#2D6A4F',
    '#E76F51', '#F4A261', '#264653', '#457B9D',
  ];

  static const List<String> availableRoles = [
    'Product Owner',
    'Scrum Master',
    'Developer',
    'UX Designer',
    'QA Engineer',
    'Tech Lead',
    'Stakeholder',
  ];

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);

  TeamMember copyWith({String? name, String? role, String? colorHex}) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
