import 'package:flutter/material.dart';

class TodoItem {
  //this index should useful when having changes in filtered list
  //to keep track where it original is in the provider
  int? index;

  String title;
  bool isCompleted;
  DateTime _date;
  bool includeTime;

  DateTime get date => DateTime(_date.year, _date.month, _date.day);
  TimeOfDay get time => TimeOfDay(hour: date.hour, minute: date.minute);

  set time(TimeOfDay t) {
    _date = DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  set date(DateTime d) {
    _date = DateTime(d.year, d.month, d.day, date.hour, date.minute);
  }

  TodoItem({
    required this.title,
    bool? isCompleted,
    DateTime? date,
    this.index,
    includeTime,
  }) : isCompleted = isCompleted ?? false,
       _date = date ?? DateTime.now(),
       includeTime = includeTime ?? (date != null);

  TodoItem.createDummy()
    : title = 'Untitled',
      isCompleted = false,
      _date = DateTime.now(),
      includeTime = false;

  TodoItem copyWith({String? title, bool? isCompleted}) {
    return TodoItem(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  TodoItem copy() {
    return TodoItem(
      title: title,
      isCompleted: isCompleted,
      index: index,
      date: date,
      includeTime: includeTime,
    );
  }

  void setIndex(int index) {
    this.index = index;
  }

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

  void update({
    String? title,
    bool? isCompleted,
    DateTime? date,
    TimeOfDay? time,
  }) {
    title = title ?? this.title;
    isCompleted = isCompleted ?? this.isCompleted;
    date = date ?? this.date;
    time = time ?? this.time;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'includeTime': includeTime,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isCompleted: json['isCompleted'],
      date: DateTime.parse(json['date']),
    )..includeTime = json['includeTime'] ?? false;
  }
}
