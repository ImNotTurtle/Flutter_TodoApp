import 'package:flutter/material.dart';

class TodoItem {
  TodoItem({required this.title, bool? isCompleted, DateTime? date, this.index})
    : isCompleted = isCompleted ?? false,
      date = date ?? DateTime.now()
      ;
  TodoItem.createDummy()
    : title = 'Untitled',
      isCompleted = false,
      date = DateTime.now();

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
    );
  }

  //this index should useful when having changes in filtered list
  //to keep track where it original is in the provider
  int? index;

  String title;
  bool isCompleted;
  DateTime date;

  TimeOfDay get time => TimeOfDay(hour: date.hour, minute: date.minute);

  void setIndex(int index) {
    this.index = index;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isCompleted: json['isCompleted'],
      date: DateTime.parse(json['date']),
    );
  }
}
