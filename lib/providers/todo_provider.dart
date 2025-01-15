// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:todo_app/models/todo_item.dart';
// import 'package:path/path.dart' as path;

// class TodoStateNotifier extends StateNotifier<List<TodoItem>> {
//   TodoStateNotifier() : super([]);

//   final List<TodoItem> _tempTodos = [];
//   final List<TodoItem> _allTodos = [];

//   void _validate(int index, List<TodoItem> list) {
//     if (index < 0 || index >= list.length) {
//       throw Exception('Invalid index');
//     }
//   }

//   // Sao chép dữ liệu từ state hiện tại sang _tempTodos
//   void startEdit() {
//     print('in edit mode');
//     _tempTodos.clear();
//     for(var i in state){
//       _tempTodos.add(i.copy());
//     }
//   }

//   void addTodo(TodoItem item) {
//     item.index = state.length;
//     state = [...state, item];
//   }

//   void createTodo() {
//     TodoItem item = TodoItem.createDummy();
//     addTodo(item);
//   }

//   void deleteTodo(int index) {
//     _validate(index, _tempTodos);
//     for (int i = index + 1; i < _tempTodos.length; i++) {
//       _tempTodos[i].index = i - 1;
//     }
//     _tempTodos.removeAt(index);
//   }

//   void updateTodoCompletion(int index, bool isCompleted) {
//     _validate(index, state);
//     state[index].isCompleted = isCompleted;
//   }

//   void updateTodoTitle(int index, String newTitle) {
//     _validate(index, _tempTodos);
//     _tempTodos[index].title = newTitle;
//     // print('edit in temp');
//   }

//   void updateTodoTime(int index, TimeOfDay newTime) {
//     _validate(index, _tempTodos);
//     var date = _tempTodos[index].date;
//     _tempTodos[index].date = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       newTime.hour,
//       newTime.minute,
//     );
//   }

//   void test(){
//     print('state:');
//     for(var i in state){
//       print('\t${i.index} ${i.title}');
//     }
//     print('temp todo:');
//     for(var i in _tempTodos){
//       print('\t${i.index} ${i.title}');
//     }
//   }

//   void updateTodoDate(int index, DateTime newDate) {
//     _validate(index, _tempTodos);
//     var date = _tempTodos[index].date;
//     _tempTodos[index].date = DateTime(
//       newDate.year,
//       newDate.month,
//       newDate.day,
//       date.hour,
//       date.minute,
//     );
//   }

//   // Sao chép _tempTodos vào state chính
//   void saveChanges() {
//     print('leave edit mode');
//     state = List<TodoItem>.from(_tempTodos);
//   }

//   String getAllTodosJson() {
//     List<Map<String, dynamic>> todosJson =
//         state.map((todo) => todo.toJson()).toList();
//     return jsonEncode(todosJson);
//   }

//   void loadTodosFromJson(String jsonString) {
//     if (jsonString.isEmpty) return;

//     List<dynamic> jsonList = jsonDecode(jsonString);
//     List<TodoItem> newState =
//         jsonList.map((jsonItem) {
//           return TodoItem.fromJson(jsonItem);
//         }).toList();

//     for (int i = 0; i < newState.length; i++) {
//       newState[i].index = i;
//     }

//     state = newState;
//   }

//   void loadFromFile() async {
//     var dir = await getApplicationDocumentsDirectory();
//     var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
//     if (await file.exists() == false) {
//       await file.create(recursive: true);
//     }
//     var content = file.readAsStringSync();
//     loadTodosFromJson(content);
//   }

//   void saveToFile() async {
//     var dir = await getApplicationDocumentsDirectory();
//     var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
//     if (await file.exists()) {
//       var content = getAllTodosJson();
//       await file.writeAsString(content);
//     }
//   }
// }

// final todoProvider = StateNotifierProvider<TodoStateNotifier, List<TodoItem>>((
//   ref,
// ) {
//   return TodoStateNotifier();
// });

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:path/path.dart' as path;

class TodoStateNotifier extends StateNotifier<List<TodoItem>> {
  TodoStateNotifier() : super([]);

  final List<TodoItem> _tempTodos = []; //save current state of provider to allow cancel changes

  void _validate(int index, List<TodoItem> list) {
    if (index < 0 || index >= list.length) {
      throw Exception('Invalid index');
    }
  }

  void startEdit() {
    //save current state of provider
    _tempTodos.clear();
    for(var i in state){
      _tempTodos.add(i.copy());
    }
  }

  void addTodo(TodoItem item) {
    item.index = state.length;
    state = [...state, item];
    // _tempTodos = state;
  }

  void createTodo() {
    TodoItem item = TodoItem.createDummy();
    addTodo(item);
  }

  void deleteTodo(int index) {
    _validate(index, state);
    for (int i = index + 1; i < state.length; i++) {
      state[i].index = i - 1;
    }
    state = [...state]..removeAt(index);
  }

  void updateTodoCompletion(int index, bool isCompleted) {
    _validate(index, state);
    state[index].isCompleted = isCompleted;
  }

  void updateTodoTitle(int index, String newTitle) {
    _validate(index, state);
    state[index].title = newTitle;
  }

  void updateTodoTime(int index, TimeOfDay newTime) {
    _validate(index, state);
    var date = state[index].date;
    state[index].date = DateTime(
      date.year,
      date.month,
      date.day,
      newTime.hour,
      newTime.minute,
    );
  }

  // void test(){
  //   print('state:');
  //   for(var i in state){
  //     print('\t${i.index} ${i.title}');
  //   }
  //   print('all todo:');
  //   for(var i in _allTodos){
  //     print('\t${i.index} ${i.title}');
  //   }
  //   print('temp todo:');
  //   for(var i in _tempTodos){
  //     print('\t${i.index} ${i.title}');
  //   }
  // }

  void updateTodoDate(int index, DateTime newDate) {
    _validate(index, state);
    var date = state[index].date;
    state[index].date = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      date.hour,
      date.minute,
    );
  }


  void saveChanges() {
    //current state already applied
  }

  void cancelChanges(){
    //roll back to before edit state
    state = [for (var i in _tempTodos) i.copy()];
  }

  String getAllTodosJson() {
    List<Map<String, dynamic>> todosJson =
        state.map((todo) => todo.toJson()).toList();
    return jsonEncode(todosJson);
  }

  void loadTodosFromJson(String jsonString) {
    if (jsonString.isEmpty) return;

    List<dynamic> jsonList = jsonDecode(jsonString);
    List<TodoItem> newState =
        jsonList.map((jsonItem) {
          return TodoItem.fromJson(jsonItem);
        }).toList();

    for (int i = 0; i < newState.length; i++) {
      newState[i].index = i;
    }
    
    state = newState;
  }

  void loadFromFile() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
    if (await file.exists() == false) {
      await file.create(recursive: true);
    }
    var content = file.readAsStringSync();
    loadTodosFromJson(content);
  }

  void saveToFile() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
    if (await file.exists()) {
      var content = getAllTodosJson();
      await file.writeAsString(content);
    }
  }
}

final todoProvider = StateNotifierProvider<TodoStateNotifier, List<TodoItem>>((
  ref,
) {
  return TodoStateNotifier();
});
