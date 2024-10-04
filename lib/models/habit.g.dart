// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Cast the map directly to Map<DateTime, int>
    final datasets = (fields[6] as Map).map<DateTime, int>(
      (key, value) => MapEntry(key as DateTime, value as int),
    );

    return Habit(
      id: fields[0] as String,
      time: fields[1] as DateTime,
      title: fields[2] as String,
      description: fields[3] as String,
      current: fields[4] as int,
      target: fields[5] as int,
      datasets: datasets,
      streak: fields[7] as int,
      isTodayTaskDone: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.current)
      ..writeByte(5)
      ..write(obj.target)
      ..writeByte(6)
      ..write(obj.datasets)
      ..writeByte(7)
      ..write(obj.streak)
      ..writeByte(8)
      ..write(obj.isTodayTaskDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
