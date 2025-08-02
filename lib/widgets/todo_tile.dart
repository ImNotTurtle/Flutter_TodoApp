import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/date_time_selector.dart';
import 'package:todo_app/widgets/todo_task_time_widget.dart';

class TodoTile extends ConsumerStatefulWidget {
  const TodoTile({
    super.key,
    required this.displayIndex,
    required this.todoId,
    required this.groupId,
    required this.editable,
  });

  final int displayIndex;
  final String todoId;
  final String groupId;
  final bool editable;

  @override
  ConsumerState<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends ConsumerState<TodoTile> {
  late final TextEditingController _titleController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    // 1. Khởi tạo controller rỗng, việc đồng bộ sẽ diễn ra trong hàm build
    _titleController = TextEditingController();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditingTitle) {
        setState(() {
          _isEditingTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Lắng nghe sự thay đổi của một todo item cụ thể
    final todoAsync = ref.watch(todoProvider(widget.groupId));

    // Tìm item trong state data, nếu state không phải data thì không làm gì
    final todo = todoAsync.value?.firstWhere(
      (t) => t.id == widget.todoId,
      orElse: () => TodoItem.error,
    );

    // Nếu không tìm thấy todo (đang tải, lỗi, hoặc đã bị xóa), hiển thị container rỗng
    if (todo == null || todo == TodoItem.error) {
      return const SizedBox.shrink();
    }

    // 3. Đồng bộ controller một cách an toàn trong hàm build
    if (_titleController.text != todo.title) {
      _titleController.text = todo.title;
    }

    final todoNotifier = ref.read(todoProvider(widget.groupId).notifier);
    final cardTheme = Theme.of(context).cardTheme;
    final Color cardColor =
        todo.isCompleted
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.7)
            : cardTheme.color ?? Theme.of(context).colorScheme.surface;

    final TextStyle textStyle = TextStyle(
      color:
          todo.isCompleted
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
              : Theme.of(context).colorScheme.onSurface,
      decoration:
          todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Card(
      margin: cardTheme.margin,
      elevation: cardTheme.elevation,
      color: cardColor,
      shape: cardTheme.shape,
      child:
          widget.editable
              ? _buildEditable(context, todo, todoNotifier, textStyle)
              : _buildNonEditable(context, todo, todoNotifier, textStyle),
    );
  }

  Widget _buildNonEditable(
    BuildContext context,
    TodoItem currentTodo,
    TodoNotifier todoNotifier, // Sửa kiểu dữ liệu
    TextStyle textStyle,
  ) {
    return ListTile(
      leading: Text((widget.displayIndex + 1).toString(), style: textStyle),
      title: Text(currentTodo.title, style: textStyle),
      subtitle: _buildSubtitle(context, currentTodo, todoNotifier, false),
      trailing: Checkbox(
        value: currentTodo.isCompleted,
        onChanged: (newValue) {
          todoNotifier.updateTodoCompleteState(currentTodo.id, newValue ?? false);
        },
      ),
      onTap: () {
        final newState = !currentTodo.isCompleted;
        todoNotifier.updateTodoCompleteState(currentTodo.id, newState);
      },
    );
  }

  Widget _buildEditable(
    BuildContext context,
    TodoItem currentTodo,
    TodoNotifier notifier, // Sửa kiểu dữ liệu
    TextStyle textStyle,
  ) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: widget.displayIndex,
            child: const Icon(Icons.drag_indicator, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text((widget.displayIndex + 1).toString(), style: textStyle),
        ],
      ),
      title:
          _isEditingTitle
              ? TextField(
                key: ValueKey('title_field_${currentTodo.id}'),
                controller: _titleController,
                focusNode: _focusNode,
                maxLines: null,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'Todo title',
                ),
                onChanged: (value) {
                  notifier.updateTodoTitle(currentTodo.id, value);
                },
                style: textStyle,
              )
              : InkWell(
                onTap: () {
                  setState(() {
                    _isEditingTitle = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focusNode.requestFocus();
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    currentTodo.title.isEmpty
                        ? 'Todo title'
                        : currentTodo.title,
                    style:
                        currentTodo.title.isEmpty
                            ? textStyle.copyWith(color: Colors.grey[600])
                            : textStyle,
                  ),
                ),
              ),
      subtitle: _buildSubtitle(context, currentTodo, notifier, true),
      trailing: IconButton(
        icon: const Icon(Icons.highlight_remove),
        onPressed: () {
          notifier.deleteTodo(currentTodo.id);
        },
      ),
    );
  }

  Widget? _buildSubtitle(
    BuildContext context,
    TodoItem currentTodo,
    TodoNotifier notifier, // Sửa kiểu dữ liệu
    bool isEditableMode,
  ) {
    if (isEditableMode) {
      return Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: currentTodo.includeTime,
                onChanged: (value) {
                  // Chỗ này cần có hàm updateTodoItem trong TodoNotifier
                },
              ),
              const Text('Include time'),
            ],
          ),
          if (currentTodo.includeTime)
            DateTimeSelector(
              initialTime: currentTodo.time,
              initialDate: currentTodo.date,
              onTimeSelect: (newTime) {
                // Chỗ này cần có hàm updateTodoItem trong TodoNotifier
              },
              onDateSelect: (newDate) {
                // Chỗ này cần có hàm updateTodoItem trong TodoNotifier
              },
            ),
        ],
      );
    } else {
      String datetimeFormatted =
          currentTodo.includeTime
              ? DateFormat('HH:mm dd/MM/yy').format(currentTodo.date)
              : DateFormat('dd/MM/yy').format(currentTodo.date);

      List<Widget> children = [];
      if (currentTodo.includeTime) {
        children.add(Text(datetimeFormatted));
      }
      if (currentTodo.taskTime != null) {
        children.add(
          TodoTaskTimeWidget(taskTime: currentTodo.taskTime, isEditable: false),
        );
      }
      if (children.isEmpty) return null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
  }
}
