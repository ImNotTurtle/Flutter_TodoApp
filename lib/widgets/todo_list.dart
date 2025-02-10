import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_tile.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    bool? editable,
    required this.todoItems,
    required this.provider,
    required this.onReorder,
  }) : editable = editable ?? false;

  final List<TodoItem> todoItems;
  final bool editable;
  final StateNotifierProvider<TodoStateNotifier, List<TodoItem>> provider;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return widget.editable
        ? ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: widget.todoItems.length + 1,
          itemBuilder: (ctx, index) {
            if (index != widget.todoItems.length) {
              return TodoTile(
                key: GlobalKey(),
                index: widget.todoItems[index].index!,
                todo: widget.todoItems[index],
                provider: widget.provider,
                editable: widget.editable,
              );
            } else {
              return SizedBox(key: GlobalKey(), height: 300);
            }
          },
          onReorder: (oldIndex, newIndex) {
            widget.onReorder(oldIndex, newIndex);
          },
        )
        : ListView.builder(
          itemCount: widget.todoItems.length + 1,
          itemBuilder: (ctx, index) {
            if (index != widget.todoItems.length) {
              return TodoTile(
                key: GlobalKey(),
                index: widget.todoItems[index].index!,
                todo: widget.todoItems[index],
                provider: widget.provider,
                editable: widget.editable,
              );
            }
            else{
              return const SizedBox(height: 300);
            }
          },
        );
  }
}
