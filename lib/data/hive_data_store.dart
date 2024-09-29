import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

/// All the [CRUD] operation method for Hive DB
class HiveDataStore {
  // Box name - String
  static const habitBoxName = 'habitBox';

  // Our current box with all the saved data inside - Box<Habit>
  final Box<Habit> box = Hive.box<Habit>(habitBoxName);

  // Add new Habit to Box
  Future<void> addHabit({required Habit habit}) async {
    await box.put(habit.id, habit);
  }

  // Show Habit
  Future<Habit?> getHabit({required String id}) async {
    return box.get(id);
  }

  // Update Habit
  Future<void> updateHabit({required Habit habit}) async {
    await habit.save();
  }

  // Delete Habit
  Future<void> deleteHabit({required Habit habit}) async {
    await habit.delete();
  }

  // Listen to Box Changes
  // using this method we will listen to box changes and update the UI accordingly.
  ValueListenable<Box<Habit>> listenToHabit() => box.listenable();
}
