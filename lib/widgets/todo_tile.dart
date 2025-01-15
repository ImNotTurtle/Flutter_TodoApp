import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/date_time_selector.dart';

class TodoTile extends ConsumerStatefulWidget {
  const TodoTile({
    super.key,
    required this.index,
    required this.todo,
    required this.provider,
    bool? editable,
  }) : editable = editable ?? false;

  final int index;
  final TodoItem todo;
  final StateNotifierProvider<TodoStateNotifier, List<TodoItem>> provider;
  final bool editable;
  @override
  ConsumerState<TodoTile> createState() {
    return _TodoTileState();
  }
}

class _TodoTileState extends ConsumerState<TodoTile> {
  bool isCompleted = false;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.todo.isCompleted;
    titleController = TextEditingController();
    titleController.text = widget.todo.title;
  }

  @override
  Widget build(BuildContext context) {
    return widget.editable == false ? buildCheckboxListTile() : buildListTile();
  }

  Widget buildCheckboxListTile() {
    var datetime = DateFormat('HH:mm dd/MM/yy').format(widget.todo.date);
    return CheckboxListTile(
      value: isCompleted,
      secondary: Text((widget.index + 1).toString()),
      subtitle: Text(datetime),
      title: Text(widget.todo.title),
      onChanged: (newValue) {
        setState(() {
          isCompleted = newValue ?? false;
        });
        ref.read(widget.provider.notifier).updateTodoCompletion(widget.index, isCompleted);
      },
    );
  }

  Widget buildListTile() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(width: 1.0, color: Colors.white)),
      child: ListTile(
        leading: Text((widget.index + 1).toString()),
        title: TextField(
          controller: titleController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          onChanged:(value) {
            ref.read(widget.provider.notifier).updateTodoTitle(widget.index, value);
          },
        ),
        subtitle: DateTimeSelector(
          initialTime: widget.todo.time,
          initialDate: widget.todo.date,
          onTimeSelect: (newTime) {
            ref.read(widget.provider.notifier).updateTodoTime(widget.index, newTime);
          },
          onDateSelect: (newDate) {
            ref.read(widget.provider.notifier).updateTodoDate(widget.index, newDate);
          },
        ),
        trailing: IconButton(
          icon: Icon(Icons.highlight_remove),
          onPressed: () {
            ref.read(widget.provider.notifier).deleteTodo(widget.index);
          },
        ),
      ),
    );
  }
}
