import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/providers/todo_provider.dart'; // Import todo_provider
import 'package:todo_app/widgets/date_time_selector.dart'; // Đảm bảo import này
import 'package:todo_app/widgets/todo_task_time_widget.dart'; // Đảm bảo import này

class TodoTile extends ConsumerWidget {
  // Đổi từ ConsumerStatefulWidget sang ConsumerWidget
  const TodoTile({
    super.key,
    required this.displayIndex, // Đổi tên từ 'index' thành 'displayIndex' cho rõ ràng
    required this.todo,
    required this.editable,
  });

  final int displayIndex; // Index dùng để hiển thị (1-based)
  final TodoItem todo;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Thêm WidgetRef ref
    // Lấy notifier cho nhóm công việc mà todo này thuộc về
    final todoNotifier = ref.read(todoProvider(todo.groupId).notifier);

    final cardTheme = Theme.of(context).cardTheme;

    final Color cardColor =
        todo.isCompleted
            ? Theme.of(context).colorScheme.surface.withValues(
              alpha: 0.5,
            ) // Màu nền mờ hơn
            : cardTheme.color ??
                Theme.of(
                  context,
                ).colorScheme.surface; // Sử dụng màu từ theme hoặc fallback

    final TextStyle textStyle = TextStyle(
      color:
          todo.isCompleted
              ? Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.6,
              ) // Chữ mờ hơn
              : Theme.of(context).colorScheme.onSurface,
      decoration:
          todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Card(
      margin: Theme.of(context).cardTheme.margin,
      elevation: Theme.of(context).cardTheme.elevation,
      color: cardColor,
      shape: Theme.of(context).cardTheme.shape,
      child:
          editable == false
              ? _buildTodoTileNonEditable(
                context,
                todo,
                todoNotifier,
                textStyle,
              )
              : _buildTodoTileEditable(context, todoNotifier, todo, textStyle),
    );
  }

  // Phương thức riêng cho chế độ không chỉnh sửa
  Widget _buildTodoTileNonEditable(
    BuildContext context,
    TodoItem currentTodo,
    TodoStateNotifier todoNotifier,
    TextStyle textStyle,
  ) {
    String datetimeFormatted =
        currentTodo.includeTime
            ? DateFormat('HH:mm dd/MM/yy').format(currentTodo.date)
            : DateFormat('dd/MM/yy').format(currentTodo.date);

    return ListTile(
      leading: Text(
        (displayIndex + 1).toString(),
        style: textStyle.copyWith(
          color: textStyle.color?.withValues(
            alpha: textStyle.color!.a,
          ), // Đảm bảo màu số thứ tự cũng mờ theo
        ),
      ),
      subtitle: _buildSubtitle(context, currentTodo, datetimeFormatted, false),
      title: Text(currentTodo.title, style: textStyle),
      trailing: Checkbox(
        value: currentTodo.isCompleted,
        onChanged: (newValue) {
          // Gọi trực tiếp notifier để cập nhật trạng thái hoàn thành
          todoNotifier.updateTodoItem(
            todoId: currentTodo.id,
            isCompleted: newValue ?? false,
          );
        },
      ),
      onTap: () {
        todoNotifier.updateTodoItem(
          todoId: currentTodo.id,
          isCompleted: !currentTodo.isCompleted,
        );
      },
    );
  }

  // Phương thức riêng cho chế độ chỉnh sửa
  Widget _buildTodoTileEditable(
    BuildContext context,
    TodoStateNotifier notifier,
    TodoItem currentTodo,
    TextStyle textStyle,
  ) {
    return ListTile(
      leading: Wrap(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            // Lấy index động từ danh sách hiện tại của provider state
            index: displayIndex,
            child: Icon(
              Icons.drag_indicator,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            (displayIndex + 1)
                .toString(), // Sử dụng displayIndex cho mục đích hiển thị
            style: textStyle.copyWith(
              // Sử dụng textStyle cho số thứ tự
              color: textStyle.color?.withValues(alpha: textStyle.color!.a),
            ),
          ),
        ],
      ),
      title: TextField(
        controller: TextEditingController(text: currentTodo.title),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Todo title',
        ),
        onChanged: (value) {
          // Cập nhật ngay khi giá trị TextField thay đổi
          notifier.updateTodoItem(todoId: currentTodo.id, newTitle: value);
        },
        // Đảm bảo TextField cập nhật khi dữ liệu từ provider thay đổi
        key: ValueKey('title_field_${currentTodo.id}'),
        style: textStyle,
      ),
      subtitle: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: currentTodo.includeTime,
                onChanged: (value) {
                  notifier.updateTodoItem(
                    todoId: currentTodo.id,
                    includeTime: value ?? false,
                  );
                },
              ),
              const Text('Include time'),
            ],
          ),
          if (currentTodo.includeTime) ...[
            DateTimeSelector(
              initialTime: currentTodo.time,
              initialDate: currentTodo.date,
              onTimeSelect: (newTime) {
                notifier.updateTodoItem(
                  todoId: currentTodo.id,
                  newTime: newTime,
                );
              },
              onDateSelect: (newDate) {
                notifier.updateTodoItem(
                  todoId: currentTodo.id,
                  newDate: newDate,
                );
              },
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.highlight_remove),
        onPressed: () {
          notifier.deleteTodo(currentTodo.id);
        },
      ),
    );
  }

  // Điều chỉnh _buildSubtitle để sử dụng currentTodo và có thể ẩn/hiện chi tiết
  // Đối với ConsumerWidget, `showDetail` sẽ cần được quản lý bằng StateProvider riêng nếu bạn muốn toggle nó.
  // Hiện tại, tôi sẽ làm cho nó hiển thị tất cả các thông tin một cách đơn giản ở chế độ non-editable.
  Widget? _buildSubtitle(
    BuildContext context,
    TodoItem currentTodo,
    String datetime,
    bool isEditableMode,
  ) {
    if (isEditableMode) {
      return null; // Subtitle đã được xây dựng trong buildTodoTileEditable
    }

    List<Widget> children = [];

    if (currentTodo.includeTime) {
      children.add(Text(datetime));
    }

    if (currentTodo.taskTime != null) {
      children.add(
        TodoTaskTimeWidget(
          taskTime: currentTodo.taskTime,
          isEditable: false, // Không thể chỉnh sửa task time ở chế độ view
        ),
      );
    }

    if (children.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
