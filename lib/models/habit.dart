import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  int current;

  @HiveField(5)
  int target;

  @HiveField(6)
  Map<DateTime, int> datasets;

  @HiveField(7)
  int streak;

  @HiveField(8)
  bool isTodayTaskDone;

  @HiveField(9)
  int colorValue; // Store Color as int

  @HiveField(10)
  int iconCodePoint; // Store IconData's codePoint as int

  @HiveField(11)
  String? iconFontFamily; // Optional fontFamily for IconData

  Habit({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.datasets,
    required this.streak,
    required this.isTodayTaskDone,
    required Color color,
    required IconData iconData,
  })  : colorValue = color.value,
        // Save color as int
        iconCodePoint = iconData.codePoint,
        // Save IconData's codePoint
        iconFontFamily = iconData.fontFamily; // Save IconData's fontFamily

  // Accessor for `Color`
  Color get color => Color(colorValue);

  // Accessor for `IconData`
  IconData get iconData => IconData(iconCodePoint, fontFamily: iconFontFamily);

  // Factory for creating a new habit
  factory Habit.create({
    required DateTime time,
    required String title,
    String? description,
    int? current,
    required int target,
    Map<DateTime, int>? datasets,
    int? streak,
    required bool isTodayTaskDone,
    required Color color,
    required IconData iconData,
  }) =>
      Habit(
        id: const Uuid().v1(),
        time: time,
        title: title,
        description: description ?? '',
        current: current ?? 0,
        target: target,
        datasets: datasets ?? {},
        streak: streak ?? 0,
        isTodayTaskDone: isTodayTaskDone,
        color: color,
        iconData: iconData,
      );
}
