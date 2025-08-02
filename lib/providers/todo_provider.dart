import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/services/supabase_service.dart';

// 1. Chuyển từ StateNotifier sang FamilyAsyncNotifier, với String là kiểu tham số family
class TodoNotifier extends FamilyAsyncNotifier<List<TodoItem>, String> {
  List<TodoItem> _initialItems = [];

  // 2. Hàm build giờ đây nhận tham số family (groupId)
  @override
  Future<List<TodoItem>> build(String groupId) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final fetchedItems = await supabaseService.getTodoItemsForGroup(groupId);
    _initialItems = fetchedItems.map((item) => item.copyWith()).toList();
    return fetchedItems;
  }

  void startEdit() {
    _initialItems =
        state.valueOrNull?.map((item) => item.copyWith()).toList() ?? [];
  }

  void createTodo() {
    final groupId = arg; // Lấy groupId từ tham số family
    final item = TodoItem.createDummy(groupId: groupId);
    final previousState = state.valueOrNull ?? [];
    state = AsyncData([...previousState, item]);
  }

  void deleteTodo(String todoId) {
    final items = state.valueOrNull ?? [];
    state = AsyncData(items.where((item) => item.id != todoId).toList());
  }

  void moveTodo(int oldIndex, int newIndex) {
    final items = state.valueOrNull ?? [];
    if (oldIndex < 0 ||
        oldIndex >= items.length ||
        newIndex < 0 ||
        newIndex > items.length) {
      return;
    }

    final newItems = List<TodoItem>.from(items);
    final item = newItems.removeAt(oldIndex);
    newItems.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = AsyncData(newItems);
  }

  void updateTodoTitle(String id, String newTitle) {
    final items = state.valueOrNull;
    if (items == null) return;

    final index = items.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      items[index].title = newTitle;
      // Không cần gán lại state vì đây là thay đổi trực tiếp, không phải là thay đổi cấu trúc list
    }
  }

  /// Cập nhật trạng thái hoàn thành của một TodoItem.
  /// UI được cập nhật ngay lập tức, và sẽ hoàn tác nếu có lỗi từ server.
  Future<void> updateTodoCompleteState(String todoId, bool isCompleted) async {
    final supabaseService = ref.read(supabaseServiceProvider);

    // Lấy state hiện tại một cách an toàn
    final items = state.valueOrNull;
    if (items == null) return;

    // 1. Tìm item và lưu lại trạng thái cũ
    final index = items.indexWhere((item) => item.id == todoId);
    if (index == -1) return;

    final originalItem = items[index];
    final originalState = List<TodoItem>.from(
      items,
    ); // Tạo bản sao của state cũ

    // 2. Cập nhật UI ngay lập tức (Optimistic Update)
    final updatedItem = originalItem.copyWith(isCompleted: isCompleted);
    final optimisticState = List<TodoItem>.from(items);
    optimisticState[index] = updatedItem;
    state = AsyncData(optimisticState);

    // 3. Gửi yêu cầu lên Supabase
    try {
      await supabaseService.upsertTodoItem(updatedItem);
      // Nếu thành công, không cần làm gì thêm vì UI đã đúng
    } catch (e, stackTrace) {
      log('Failed to update todo complete state: $e, $stackTrace');

      // 4. Nếu có lỗi, hoàn tác lại thay đổi trên UI
      state = AsyncData(originalState);

      // (Tùy chọn) Ném lại lỗi để UI có thể hiển thị thông báo
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> saveChanges() async {
    final groupId = arg;
    final currentItems = state.valueOrNull ?? [];
    final initialItems = _initialItems;
    final supabaseService = ref.read(supabaseServiceProvider);

    // --- BƯỚC KIỂM TRA THAY ĐỔI ---
    final List<Future> dbTasks = [];

    final deletedIds =
        initialItems
            .where(
              (initial) =>
                  !currentItems.any((current) => current.id == initial.id),
            )
            .map((item) => item.id)
            .toList();
    for (final id in deletedIds) {
      dbTasks.add(supabaseService.deleteTodoItem(id));
    }

    for (final currentItem in currentItems) {
      final initialItem = initialItems.firstWhere(
        (item) => item.id == currentItem.id,
        orElse: () => TodoItem.error,
      );

      if (initialItem.isError ||
          currentItem.hasChangesComparedTo(initialItem)) {
        dbTasks.add(supabaseService.upsertTodoItem(currentItem));
      }
    }

    if (dbTasks.isEmpty) {
      return;
    }

    // Đặt state về loading
    state = const AsyncLoading();

    try {
      await Future.wait(dbTasks);

      // --- SỬA LỖI: TẢI LẠI DỮ LIỆU VÀ CẬP NHẬT STATE ---
      // Thay vì gọi build(), hãy chủ động fetch lại dữ liệu mới nhất cho group này
      final freshItems = await supabaseService.getTodoItemsForGroup(groupId);
      // Cập nhật lại trạng thái ban đầu
      _initialItems = freshItems.map((item) => item.copyWith()).toList();
      // Đặt state về AsyncData với dữ liệu mới
      state = AsyncData(freshItems);
      // --- KẾT THÚC SỬA LỖI ---
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void cancelChanges() {
    state = AsyncData(_initialItems.map((item) => item.copyWith()).toList());
  }
}

// 3. Thay đổi cách khai báo provider
final todoProvider =
    AsyncNotifierProvider.family<TodoNotifier, List<TodoItem>, String>(
      TodoNotifier.new,
    );
