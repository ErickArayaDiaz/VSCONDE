// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskHistoryAdapter extends TypeAdapter<TaskHistory> {
  @override
  final int typeId = 2;

  @override
  TaskHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskHistory(
      title: fields[0] as String,
      description: fields[1] as String,
      status: fields[2] as String,
      updatedAt: fields[3] as DateTime,
      version: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TaskHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
