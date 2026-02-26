import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'scrum_ceremony.g.dart';

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

  ScrumCeremony({
    String? id,
    required this.name,
    DateTime? startTime,
    this.endTime,
    List<String>? participants,
    List<String>? notes,
    this.summary,
    this.sentiment,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        participants = participants ?? [],
        notes = notes ?? [];

  factory ScrumCeremony.fromJson(Map<String, dynamic> json) =>
      _$ScrumCeremonyFromJson(json);

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
    );
  }
}
