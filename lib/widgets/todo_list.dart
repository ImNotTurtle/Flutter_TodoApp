import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_tile.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    bool? editable,
    required this.todoItems,
    required this.provider,
  }) : editable = editable ?? false;

  final List<TodoItem> todoItems;
  final bool editable;
  final StateNotifierProvider<TodoStateNotifier, List<TodoItem>> provider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todoItems.length,
      itemBuilder:
          (ctx, index) => TodoTile(
            key: GlobalKey(),
            index: todoItems[index].index!,
            todo: todoItems[index],
            provider: provider,
            editable: editable,
          ),
    );
  }
}
