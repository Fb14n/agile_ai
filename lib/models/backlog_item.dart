import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'backlog_item.g.dart';

enum BacklogStatus { todo, inProgress, done, removed }

@JsonSerializable()
class BacklogItem {
  final String id;
  String title;
  String description;
  int? storyPoints;
  BacklogStatus status;
  int? sprintNumber;
  List<String> acceptanceCriteria;
  final DateTime createdAt;

  BacklogItem({
    String? id,
    required this.title,
    this.description = '',
    this.storyPoints,
    this.status = BacklogStatus.todo,
    this.sprintNumber,
    List<String>? acceptanceCriteria,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        acceptanceCriteria = acceptanceCriteria ?? [],
        createdAt = createdAt ?? DateTime.now();

  factory BacklogItem.fromJson(Map<String, dynamic> json) => _$BacklogItemFromJson(json);
  Map<String, dynamic> toJson() => _$BacklogItemToJson(this);

  BacklogItem copyWith({
    String? title,
    String? description,
    int? storyPoints,
    BacklogStatus? status,
    int? sprintNumber,
    bool clearSprintNumber = false,
    List<String>? acceptanceCriteria,
  }) {
    return BacklogItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      storyPoints: storyPoints ?? this.storyPoints,
      status: status ?? this.status,
      sprintNumber: clearSprintNumber ? null : (sprintNumber ?? this.sprintNumber),
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
      createdAt: createdAt,
    );
  }
}
