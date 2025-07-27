import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/models/todo_task_time.dart';
// import 'package:todo_app/providers/todo_group_provider.dart'; // Không cần thiết ở đây nữa
// import 'package:todo_app/models/todo_group.dart'; // Không cần thiết ở đây nữa
import 'package:todo_app/services/supabase_service.dart';
import 'dart:developer'; // Import for log

class TodoStateNotifier extends StateNotifier<List<TodoItem>> {
  final String groupId;
  final SupabaseService _supabaseService;
  List<TodoItem> _initialItems = []; // Lưu trữ trạng thái ban đầu của các mục todo

  TodoStateNotifier({
    required this.groupId,
    required SupabaseService supabaseService,
  })  : _supabaseService = supabaseService,
        super([]) {
    _loadTodoItemsForGroup();
  }

  Future<void> _loadTodoItemsForGroup() async {
    try {
      final fetchedItems = await _supabaseService.getTodoItemsForGroup(groupId);
      state = fetchedItems;
      _initialItems = state.map((item) => item.copyWith()).toList();
    } catch (e) {
      log('Error loading todo items for group $groupId: $e'); // Sử dụng log thay vì print
      state = [];
    }
  }

  // Khi vào chế độ chỉnh sửa, lưu trữ trạng thái hiện tại làm bản sao ban đầu
  void startEdit() {
    _initialItems = state.map((item) => item.copyWith()).toList();
  }

  // Thêm một mục todo mới vào bản sao trạng thái (không lưu vào DB ngay)
  void addTodo(WidgetRef ref, TodoItem item) {
    item.groupId = groupId;
    state = [...state, item];
    // Không cần _notifyUpdate(ref) nếu TodoGroup không quan tâm đến TodoItem nữa
    // và state thay đổi đã kích hoạt rebuild.
  }

  void createTodo(WidgetRef ref) {
    TodoItem item = TodoItem.createDummy(groupId: groupId);
    state = [...state, item];
    // Không cần _notifyUpdate(ref)
  }

  // Xóa một mục todo khỏi bản sao trạng thái (không xóa khỏi DB ngay)
  void deleteTodo(String todoId) {
    final index = state.indexWhere((item) => item.id == todoId);
    if (index == -1) return;

    state = [...state]..removeAt(index);
    // Không cần _notifyUpdate(ref)
  }

  // Di chuyển mục todo trong bản sao trạng thái (không lưu vào DB ngay)
  void moveTodo(WidgetRef ref, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final item = state.removeAt(oldIndex);
    state = [...state]..insert(newIndex, item);

    // Không cần _notifyUpdate(ref)
  }

  // Cập nhật một mục todo trong bản sao trạng thái (không lưu vào DB ngay)
  void updateTodoItem({
    required String todoId,
    String? newTitle,
    bool? isCompleted,
    DateTime? newDate,
    TimeOfDay? newTime,
    TodoTaskTime? newTaskTime,
    bool? includeTime,
  }) {
    final index = state.indexWhere((item) => item.id == todoId);
    if (index == -1) return;

    final currentTodo = state[index];
    final updatedTodo = currentTodo.copyWith(
      title: newTitle,
      isCompleted: isCompleted,
      date: newDate,
      taskTime: newTaskTime,
      includeTime: includeTime,
    );

    if (newTime != null) {
      updatedTodo.time = newTime;
    }

    state = [...state]..[index] = updatedTodo; // Cập nhật bản sao trạng thái
  }

  // Lưu thay đổi: Đồng bộ hóa với Supabase
  Future<void> saveChanges(WidgetRef ref) async {
    final List<TodoItem> currentItems = state;
    final List<TodoItem> initialItems = _initialItems;

    // 1. Xóa các mục đã bị xóa (trong initialItems nhưng không có trong currentItems)
    final deletedItemIds = initialItems
        .where((initialItem) => !currentItems.any((currentItem) => currentItem.id == initialItem.id))
        .map((item) => item.id)
        .toList();
    for (final id in deletedItemIds) {
      await _supabaseService.deleteTodoItem(id);
    }

    // 2. Thêm mới hoặc cập nhật các mục
    for (int i = 0; i < currentItems.length; i++) {
      final currentItem = currentItems[i];

      // Tìm mục tương ứng trong initialItems bằng id
      final initialItem = initialItems.firstWhere(
        (item) => item.id == currentItem.id,
        orElse: () => TodoItem.createDummy(groupId: currentItem.groupId), // Tạo dummy cho mục mới
      );

      if (initialItem.title == '') { // Mục mới
        await _supabaseService.addTodoItem(currentItem);
      } else if (
                 currentItem.title != initialItem.title ||
                 currentItem.isCompleted != initialItem.isCompleted ||
                 currentItem.date != initialItem.date ||
                 currentItem.includeTime != initialItem.includeTime ||
                 currentItem.taskTime?.toString() != initialItem.taskTime?.toString()
                ) { // Mục đã thay đổi (không so sánh orderIndex nữa)
        await _supabaseService.updateTodoItem(currentItem);
      }
    }

    // Cập nhật _initialItems sau khi lưu thành công để phản ánh trạng thái mới
    _initialItems = state.map((item) => item.copyWith()).toList();
    // Không cần _notifyUpdate(ref) nếu TodoGroup không quan tâm đến TodoItem nữa.
  }

  // Hủy bỏ thay đổi: khôi phục lại trạng thái ban đầu
  void cancelChanges(WidgetRef ref) {
    state = _initialItems.map((item) => item.copyWith()).toList(); // Khôi phục bản sao sâu
    // Không cần _notifyUpdate(ref)
  }
}

final todoProvider =
    StateNotifierProvider.family<TodoStateNotifier, List<TodoItem>, String>((
      ref,
      groupId,
    ) {
      final supabaseService = ref.read(supabaseServiceProvider);
      // Không còn cần todoGroups hoặc todoGroup ở đây để lấy items
      return TodoStateNotifier(
        groupId: groupId,
        supabaseService: supabaseService,
      );
    });