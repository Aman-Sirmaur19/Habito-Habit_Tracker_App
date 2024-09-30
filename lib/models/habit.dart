import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  final String id;
  DateTime time;
  String title;
  String description;
  int current;
  int target;
  Map<DateTime, int> datasets;
  int streak;

  Habit({
    @HiveField(0) required this.id,
    @HiveField(1) required this.time,
    @HiveField(2) required this.title,
    @HiveField(3) required this.description,
    @HiveField(4) required this.current,
    @HiveField(5) required this.target,
    @HiveField(6) required this.datasets,
    @HiveField(6) required this.streak,
  });

  // create new habit
  factory Habit.create({
    required DateTime time,
    required String title,
    String? description,
    int? current,
    required int target,
    Map<DateTime, int>? datasets,
    int? streak,
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
      );
}
