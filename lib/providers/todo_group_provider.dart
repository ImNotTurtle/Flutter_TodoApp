// lib/providers/todo_group_provider.dart
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
// import 'package:todo_app/models/todo_item.dart'; // Không cần TodoItem ở đây nữa
// import 'package:todo_app/providers/todo_provider.dart'; // Không cần import trực tiếp để updateTodoGroup nữa
import 'package:todo_app/services/supabase_service.dart';

class TodoGroupStateNotifier extends StateNotifier<List<TodoGroup>> {
  final SupabaseService _supabaseService;
  List<TodoGroup> _initialGroups = []; // Lưu trữ trạng thái ban đầu của các nhóm

  TodoGroupStateNotifier(this._supabaseService) : super([]);

  List<TodoGroup> get groups => state;

  Future<void> loadGroups() async {
    try {
      // Chỉ fetch groups, không cần join todo_items ở đây nữa
      final fetchedGroups = await _supabaseService.fetchTodoGroups(); // Sẽ cần tạo phương thức này trong SupabaseService
      state = fetchedGroups;
      _initialGroups = state.map((g) => g.copyWith()).toList(); // Lưu trạng thái ban đầu
    } catch (e) {
      log('Error loading groups: $e');
    }
  }

  // Phương thức này chỉ thêm group vào state cục bộ, không lưu DB ngay
  Future<int> createGroup({String? title}) async {
    final newGroup = TodoGroup.createEmpty();
    if (title != null && title.trim().isNotEmpty) {
      newGroup.title = title;
    }
    state = [...state, newGroup];
    return state.length - 1; // Trả về index của nhóm mới trong state
  }

  // Xóa một nhóm khỏi state cục bộ (không xóa khỏi DB ngay)
  Future<void> deleteGroup(WidgetRef ref, int index) async {
    _validate(index);
    final groupIdToDelete = state[index].id;

    // TODO: Có thể cần invalidate todoProvider của group này nếu nó đang được watch ở đâu đó.
    // Nếu bạn muốn các todo của group đó cũng bị xóa cục bộ ngay lập tức, bạn sẽ cần logic ở đây.
    // Tuy nhiên, việc xóa khỏi DB sẽ xảy ra trong saveChanges.
    // ref.invalidate(todoProvider(groupIdToDelete)); // Nếu bạn muốn invalidate ngay

    state = [...state]..removeAt(index);
    // Việc xóa khỏi DB sẽ được xử lý trong saveChanges.
  }

  String getId(int index) {
    _validate(index);
    return state[index].id;
  }

  void updateGroupTitle(int index, String newTitle) {
    _validate(index);
    state[index] = state[index].copyWith(title: newTitle); // Cập nhật bản sao
    state = [...state]; // Kích hoạt rebuild
    // Không lưu vào DB ngay lập tức.
  }

  // Phương thức này không còn cần thiết vì TodoGroup không chứa TodoItem nữa.
  // Các thay đổi của TodoItem sẽ không ảnh hưởng trực tiếp đến state của TodoGroupNotifier.
  // void updateTodoGroup(String id, List<TodoItem> newTodos) {
  //   final index = state.indexWhere((item) => item.id == id);
  //   if (index == -1) return;
  //   state[index] = state[index].copyWith(todoItems: newTodos);
  //   state = [...state];
  // }

  // Khi vào chế độ chỉnh sửa, lưu trữ trạng thái hiện tại làm bản sao ban đầu
  void startEdit() {
    _initialGroups = state.map((g) => g.copyWith()).toList();
  }

  // Hủy bỏ thay đổi: khôi phục lại trạng thái ban đầu
  void cancelChanges() {
    state = _initialGroups.map((g) => g.copyWith()).toList(); // Khôi phục bản sao sâu
  }

  // Lưu thay đổi: Đồng bộ hóa với Supabase
  Future<void> saveChanges(WidgetRef ref) async {
    final List<TodoGroup> currentGroups = state;
    final List<TodoGroup> initialGroups = _initialGroups;

    // 1. Xóa các nhóm đã bị xóa (so sánh với trạng thái ban đầu)
    final deletedGroupIds = initialGroups
        .where((initialGroup) => !currentGroups.any((currentGroup) => currentGroup.id == initialGroup.id))
        .map((g) => g.id)
        .toList();
    for (final id in deletedGroupIds) {
      await _supabaseService.deleteTodoGroup(id);
    }

    // 2. Thêm mới hoặc cập nhật các nhóm
    for (final currentGroup in currentGroups) {
      final initialGroup = initialGroups.firstWhere(
        (g) => g.id == currentGroup.id,
        orElse: () => TodoGroup.createEmpty(), // Dummy group for new items, id will be null
      );

      if (initialGroup.id == '') { // Nhóm mới (kiểm tra id rỗng vì createEmpty tạo id rỗng nếu không truyền vào)
        await _supabaseService.addTodoGroup(currentGroup);
      } else if (currentGroup.title != initialGroup.title) { // Tiêu đề nhóm đã thay đổi
        await _supabaseService.updateTodoGroupTitle(currentGroup.id, currentGroup.title);
      }
    }

    // Cập nhật _initialGroups sau khi lưu thành công
    _initialGroups = state.map((g) => g.copyWith()).toList();
  }

  void _validate(int index) {
    if (index < 0 || index >= state.length) {
      throw Exception('Invalid index $index');
    }
  }
}

final todoGroupProvider =
    StateNotifierProvider<TodoGroupStateNotifier, List<TodoGroup>>((ref) {
      final supabaseService = ref.read(supabaseServiceProvider);
      return TodoGroupStateNotifier(supabaseService);
    });