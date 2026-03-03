import 'package:json_annotation/json_annotation.dart';

part 'sprint_data.g.dart';

@JsonSerializable()
class SprintData {
  final int sprintNumber;
  final int? velocity;
  final int? plannedPoints;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? goal;
  final double? sentimentScore;

  const SprintData({
    required this.sprintNumber,
    this.velocity,
    this.plannedPoints,
    this.startDate,
    this.endDate,
    this.goal,
    this.sentimentScore,
  });

  factory SprintData.fromJson(Map<String, dynamic> json) => _$SprintDataFromJson(json);
  Map<String, dynamic> toJson() => _$SprintDataToJson(this);

  SprintData copyWith({
    int? velocity,
    int? plannedPoints,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    double? sentimentScore,
  }) {
    return SprintData(
      sprintNumber: sprintNumber,
      velocity: velocity ?? this.velocity,
      plannedPoints: plannedPoints ?? this.plannedPoints,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }
}
