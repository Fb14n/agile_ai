// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectTeamMember _$ProjectTeamMemberFromJson(Map<String, dynamic> json) =>
    ProjectTeamMember(
      id: json['id'] as String?,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'Developer',
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$ProjectTeamMemberToJson(ProjectTeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'name': instance.name,
      'role': instance.role,
      'active': instance.active,
    };
