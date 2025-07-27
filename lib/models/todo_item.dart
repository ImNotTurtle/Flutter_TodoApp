import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_task_time.dart';
import 'package:uuid/uuid.dart';

final _kUuid = Uuid();

class TodoItem {
  final String id;
  String groupId;
  String title;
  bool isCompleted;
  DateTime _date;
  bool includeTime;
  TodoTaskTime? taskTime;

  DateTime get date => DateTime(_date.year, _date.month, _date.day);
  TimeOfDay get time => TimeOfDay(hour: _date.hour, minute: _date.minute);

  set time(TimeOfDay t) {
    _date = DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  set date(DateTime d) {
    _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute);
  }

  TodoItem({
    String? id,
    required this.groupId,
    required this.title,
    bool? isCompleted,
    DateTime? date,
    this.includeTime = false,
    this.taskTime,
  }) : isCompleted = isCompleted ?? false,
       _date = date ?? DateTime.now(),
       id = id ?? _kUuid.v4();

  TodoItem.createDummy({required this.groupId})
    : id = _kUuid.v4(),
      title = '',
      isCompleted = false,
      _date = DateTime.now(),
      includeTime = false,
      taskTime = null;

  TodoItem copyWith({
    String? id,
    String? groupId,
    String? title,
    bool? isCompleted,
    DateTime? date,
    bool? includeTime,
    TodoTaskTime? taskTime,
  }) {
    return TodoItem(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      includeTime: includeTime ?? this.includeTime,
      taskTime: taskTime ?? this.taskTime,
    );
  }

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'group_id': groupId,
    'title': title,
    'is_completed': isCompleted,
    'date': _date.toIso8601String(),
    'include_time': includeTime,
    'task_time_string': taskTime?.toString(),
  };
}

factory TodoItem.fromJson(Map<String, dynamic> json) {
  return TodoItem(
    id: json['id'],
    groupId: json['group_id'],
    title: json['title'],
    isCompleted: json['is_completed'], // <-- Lấy từ 'is_completed'
    date: DateTime.parse(json['date']),
    includeTime: json['include_time'] ?? false, // <-- Lấy từ 'include_time'
    taskTime: json['task_time_string'] != null
        ? TodoTaskTime.fromString(json['task_time_string'])
        : null,
  );
  }
}
