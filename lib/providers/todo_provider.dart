import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:path/path.dart' as path;
import 'package:todo_app/providers/todo_group_provider.dart';
import 'package:todo_app/models/todo_group.dart';

class TodoStateNotifier extends StateNotifier<List<TodoItem>> {
  TodoStateNotifier({
    required this.id,
    List<TodoItem>? items,
  }) : super(items ?? []){
    //assign index
    if(items != null){
      for(int i = 0; i < items.length; i++){
        state[i].index = i;
      }
    }
  }

  String id;
  List<TodoItem> get todos => state;

  final List<TodoItem> _tempTodos =
      []; //save current state of provider to allow cancel changes

  void _validate(int index, List<TodoItem> list) {
    if (index < 0 || index >= list.length) {
      throw Exception('Invalid index');
    }
  }

  void startEdit() {
    //save current state of provider
    _tempTodos.clear();
    for (var i in state) {
      _tempTodos.add(i.copy());
    }
  }

  void addTodo(WidgetRef ref, TodoItem item) {
    item.index = state.length;
    state = [...state, item];
  }

  void createTodo(WidgetRef ref) {
    TodoItem item = TodoItem.createDummy();
    addTodo(ref, item);
  }

  void deleteTodo(WidgetRef ref, int index) {
    _validate(index, state);
    for (int i = index + 1; i < state.length; i++) {
      state[i].index = i - 1;
    }
    state = [...state]..removeAt(index);

    _notifyUpdate(ref);
  }

  void moveTodo(WidgetRef ref, int oldIndex, int newIndex) {
    final item = state.removeAt(oldIndex);
    state = [...state]..insert(newIndex, item);

    _notifyUpdate(ref);
  }

  void updateTodo(WidgetRef ref, int index, TodoItem newTodo) {
    _validate(index, state);
    state[index] = newTodo;

    _notifyUpdate(ref);
  }

  void updateTodoCompletion(WidgetRef ref, int index, bool isCompleted) {
    _validate(index, state);
    state[index].isCompleted = isCompleted;

    _notifyUpdate(ref);
  }

  void updateTodoTitle(WidgetRef ref, int index, String newTitle) {
    _validate(index, state);
    state[index].title = newTitle;
    
    _notifyUpdate(ref);
  }

  void updateTodoTime(WidgetRef ref, int index, TimeOfDay newTime) {
    _validate(index, state);
    var date = state[index].date;
    state[index].date = DateTime(
      date.year,
      date.month,
      date.day,
      newTime.hour,
      newTime.minute,
    );
    
    _notifyUpdate(ref);
  }

  void updateTodoDate(WidgetRef ref, int index, DateTime newDate) {
    _validate(index, state);
    var date = state[index].date;
    state[index].date = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      date.hour,
      date.minute,
    );
    
    _notifyUpdate(ref);
  }

  void saveChanges(WidgetRef ref) {
    //current state already applied

    //refresh indexes due to reorder operations
    var newState = state;
    for (var i = 0; i < newState.length; i++) {
      newState[i].setIndex(i);
    }
    
    _notifyUpdate(ref);
  }

  void cancelChanges(WidgetRef ref) {
    //roll back to before edit state
    state = [for (var i in _tempTodos) i.copy()];

    
    _notifyUpdate(ref);
  }

  void _notifyUpdate(WidgetRef ref) {
    ref.read(todoGroupProvider.notifier).updateTodoGroup(id, state);
  }
}

// final todoProvider = StateNotifierProvider<TodoStateNotifier, List<TodoItem>>((
//   ref,
// ) {
//   return TodoStateNotifier();
// });

final todoProvider =
    StateNotifierProvider.family<TodoStateNotifier, List<TodoItem>, String>((
      ref,
      id,
    ) {
      final todoGroups = ref.watch(todoGroupProvider);

      final todoGroup = todoGroups.firstWhere(
        (item) => item.id == id,
        orElse: () => TodoGroup.createEmpty(),
      );
      return TodoStateNotifier(id: id, items: todoGroup.todoItems);
    });
