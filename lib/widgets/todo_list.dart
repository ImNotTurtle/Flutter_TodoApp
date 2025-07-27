import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_tile.dart';

class TodoList extends ConsumerWidget {
  const TodoList({
    super.key,
    required this.todoItems,
    bool? editable,
  }) : editable = editable ?? false;

  final List<TodoItem> todoItems;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy groupId từ item đầu tiên nếu danh sách không rỗng.
    // Nếu danh sách rỗng, không thể xác định groupId, điều này cần được xử lý cẩn thận.
    // Trong trường hợp này, todoItems sẽ rỗng khi currentGroupId là null,
    // và không có cuộc gọi nào đến todoProvider(null) sẽ xảy ra.
    final String? currentGroupId = todoItems.isNotEmpty ? todoItems.first.groupId : null;

    if (editable) {
      // Chế độ Edit: ReorderableListView
      return ReorderableListView.builder(
        buildDefaultDragHandles: false, // Để TodoTile tự xây dựng drag handle
        itemCount: todoItems.length + 1, // +1 cho SizedBox ở cuối
        itemBuilder: (ctx, index) {
          if (index < todoItems.length) {
            final todo = todoItems[index];
            return TodoTile(
              key: ValueKey(todo.id), // Key duy nhất và ổn định
              displayIndex: index, // TRUYỀN DISPLAY INDEX Ở ĐÂY!
              todo: todo,
              editable: editable,
            );
          } else {
            return SizedBox(key: UniqueKey(), height: 300); // Khoảng trống ở cuối
          }
        },
        onReorder: (oldIndex, newIndex) {
          // Xử lý trường hợp kéo thả ra ngoài cuối danh sách
          if (newIndex > todoItems.length) {
            newIndex = todoItems.length;
          }
          if (oldIndex < todoItems.length) { // Chỉ reorder nếu không phải SizedBox cuối cùng
            // Gọi notifier để di chuyển todo
            if (currentGroupId != null) {
              ref.read(todoProvider(currentGroupId).notifier).moveTodo(ref, oldIndex, newIndex);
            }
          }
        },
      );
    } else {
      // Chế độ View: ListView thông thường
      return ListView.builder(
        itemCount: todoItems.length + 1, // +1 cho SizedBox ở cuối
        itemBuilder: (ctx, index) {
          if (index < todoItems.length) {
            final todo = todoItems[index];
            return TodoTile(
              key: ValueKey(todo.id), // Vẫn cần key duy nhất
              displayIndex: index, // TRUYỀN DISPLAY INDEX Ở ĐÂY CHO CHẾ ĐỘ VIEW!
              todo: todo,
              editable: editable,
            );
          } else {
            return const SizedBox(height: 300); // Khoảng trống ở cuối
          }
        },
      );
    }
  }
}