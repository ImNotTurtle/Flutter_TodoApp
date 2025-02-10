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
  late TodoItem ownTodo;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.todo.isCompleted;
    titleController = TextEditingController();
    titleController.text = widget.todo.title;
    ownTodo = widget.todo;
  }

  @override
  Widget build(BuildContext context) {
    return widget.editable == false ? buildCheckboxListTile() : buildListTile();
  }

  //show widget in non-editable mode
  Widget buildCheckboxListTile() {
    var datetime = DateFormat('HH:mm dd/MM/yy').format(ownTodo.date);
    return Card(
      child: CheckboxListTile(
        value: isCompleted,
        secondary: Text(
          (widget.index + 1).toString(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: ownTodo.includeTime ? Text(datetime) : null,
        title: Text(ownTodo.title),
        onChanged: (newValue) {
          setState(() {
            isCompleted = newValue ?? false;
          });
          ownTodo.isCompleted = isCompleted;
          ref.read(widget.provider.notifier).updateTodo(ref, widget.index, ownTodo);
        },
      ),
    );
  }

  //show widget in editable mode
  Widget buildListTile() {
    return Card(
      child: ListTile(
        leading: Wrap(
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: Icon(Icons.drag_indicator, color: Theme.of(context).colorScheme.onSurface.withAlpha(100),),
            ),
            const SizedBox(width: 6.0),
            Text(
              (widget.index + 1).toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        title: TextField(
          controller: titleController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) {
            ownTodo.title = value;
            ref
                .read(widget.provider.notifier)
                .updateTodo(ref, widget.index, ownTodo);
          },
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: ownTodo.includeTime,
                  onChanged: (value) {
                    setState(() => ownTodo.includeTime = value ?? false);
                  },
                ),
                Text('Include time'),
              ],
            ),
            if (ownTodo.includeTime == true) ...[
              DateTimeSelector(
                initialTime: ownTodo.time,
                initialDate: ownTodo.date,
                onTimeSelect: (newTime) {
                  ownTodo.time = newTime;
                  ref
                      .read(widget.provider.notifier)
                      .updateTodo(ref, widget.index, ownTodo);
                },
                onDateSelect: (newDate) {
                  ownTodo.date = newDate;
                  ref
                      .read(widget.provider.notifier)
                      .updateTodoDate(ref, widget.index, newDate);
                },
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.highlight_remove),
          onPressed: () {
            ref.read(widget.provider.notifier).deleteTodo(ref, widget.index);
          },
        ),
      ),
    );
  }
}
