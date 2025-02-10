import 'package:todo_app/models/todo_item.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class TodoGroup {
  String id;
  String title;
  List<TodoItem> todoItems;

  TodoGroup({required this.title, required this.todoItems, String? id}) : id = id ?? uuid.v4();
  TodoGroup.createEmpty() : this(title: 'Untitled', todoItems: []);

  TodoGroup copy() {
    return TodoGroup(
      title: title,
      todoItems: todoItems.map((item) => item.copy()).toList(),
    );
  }

  void update({String? title, List<TodoItem>? todoItems}) {
    if (title != null) {
      this.title = title;
    }

    if (todoItems != null) {
      this.todoItems = todoItems;
    }
  }

  factory TodoGroup.fromJson(Map<String, dynamic> json) {
    return TodoGroup(
      title: json['title'],
      todoItems:
          (json['todoItems'] as List)
              .map((item) => TodoItem.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'todoItems': todoItems.map((item) => item.toJson()).toList(),
    };
  }
}
