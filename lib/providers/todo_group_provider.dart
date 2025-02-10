import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/providers/todo_provider.dart';

class TodoGroupStateNotifier extends StateNotifier<List<TodoGroup>> {
  TodoGroupStateNotifier() : super([]);

  List<TodoGroup> get groups => state;

  void addGroup(TodoGroup group) {
    state = [...state, group];
  }

  void addMany(List<TodoGroup> groups) {
    state = [...state, ...groups];
  }

  int createGroup({String? title}) {
    final newGroup = TodoGroup.createEmpty();
    if (title != null) {
      newGroup.title = title;
    }
    addGroup(newGroup);
    return state.length - 1;
  }

  void deleteGroup(WidgetRef ref, int index) {
    _validate(index);

    //invalidate provider
    ref.invalidate(
      todoProvider(state[index].id),
    ); //dispose provider associate with the id

    state = [...state]..removeAt(index);
  }

  String getId(int index) {
    _validate(index);
    return state[index].id;
  }

  void updateGroupTitle(int index, String newTitle) {
    _validate(index);

    state[index].title = newTitle;
  }

  void updateTodoGroup(String id, List<TodoItem> newTodos) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    state[index].todoItems = newTodos;
  }

  void _validate(int index) {
    if (index < 0 || index >= state.length) {
      throw Exception('Invalid index $index');
    }
  }

  void fromJson(List<dynamic> json) {
    try{

    final list = json.map((item) => TodoGroup.fromJson(item)).toList();
    addMany(list);
    }
    catch(e){
      return;
    }
  }

  List<Map<String, dynamic>> toJson() {
    return state.map((item) => item.toJson()).toList();
  }
}

final todoGroupProvider =
    StateNotifierProvider<TodoGroupStateNotifier, List<TodoGroup>>((ref) {
      return TodoGroupStateNotifier();
    });
