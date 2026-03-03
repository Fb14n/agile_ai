// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
  id: json['id'] as String?,
  name: json['name'] as String,
  role: json['role'] as String? ?? 'Developer',
  colorHex: json['colorHex'] as String?,
);

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': instance.role,
  'colorHex': instance.colorHex,
};
