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
  Map<DateTime, Map<String, int>> dataOfDay;

  @HiveField(5)
  Map<DateTime, int> datasets;

  @HiveField(6)
  int colorValue;

  @HiveField(7)
  int iconCodePoint;

  @HiveField(8)
  String? iconFontFamily;

  Habit({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.dataOfDay,
    required this.datasets,
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
    required Map<DateTime, Map<String, int>> dataOfDay,
    Map<DateTime, int>? datasets,
    required Color color,
    required IconData iconData,
  }) =>
      Habit(
        id: const Uuid().v1(),
        time: time,
        title: title,
        description: description ?? '',
        dataOfDay: dataOfDay,
        datasets: datasets ?? {},
        color: color,
        iconData: iconData,
      );

  static int calculateCurrentStreak(Map<DateTime, Map<String, int>> dataOfDay) {
    // Normalize today's date to ignore time
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Initialize streak count
    int streak = 0;

    // Start from today and iterate backwards
    while (dataOfDay.containsKey(today)) {
      final dayData = dataOfDay[today];
      if (dayData?['current'] != dayData?['target']) {
        // If today's task is incomplete, stop streak calculation
        if (today ==
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day)) {
          today = today.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      // Increment streak and move to the previous day
      streak++;
      today = today.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
