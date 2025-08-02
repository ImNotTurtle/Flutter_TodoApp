import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/services/supabase_service.dart';

// 1. Chuyển từ StateNotifier sang AsyncNotifier
class TodoGroupNotifier extends AsyncNotifier<List<TodoGroup>> {
  List<TodoGroup> _initialGroups = [];

  // 2. Không cần constructor, logic khởi tạo chuyển vào hàm build()
  @override
  Future<List<TodoGroup>> build() async {
    // Hàm build chịu trách nhiệm load dữ liệu ban đầu
    final supabaseService = ref.read(supabaseServiceProvider);
    final fetchedGroups = await supabaseService.getTodoGroups();
    _initialGroups = fetchedGroups.map((g) => g.copyWith()).toList();
    return fetchedGroups;
  }

  Future<int> createGroup({String? title}) async {
    final newGroup = TodoGroup.createEmpty();
    if (title != null && title.trim().isNotEmpty) {
      newGroup.title = title;
    }

    // Lấy state hiện tại và thêm group mới vào
    final previousState = state.valueOrNull ?? [];
    state = AsyncData([...previousState, newGroup]);
    return (state.valueOrNull ?? []).length - 1;
  }

  Future<void> deleteGroup(int index) async {
    final groups = state.valueOrNull ?? [];
    if (index < 0 || index >= groups.length) {
      throw Exception('Invalid index $index');
    }
    final groupIdToDelete = groups[index].id;

    // Vô hiệu hóa provider con trước khi xóa
    ref.invalidate(todoProvider(groupIdToDelete));

    // Cập nhật state
    state = AsyncData([...groups]..removeAt(index));
  }

  void updateGroupTitle(int index, String newTitle) {
    final groups = state.valueOrNull ?? [];
    if (index < 0 || index >= groups.length) {
      throw Exception('Invalid index $index');
    }

    final newState = List<TodoGroup>.from(groups);
    newState[index] = newState[index].copyWith(title: newTitle);
    state = AsyncData(newState);
  }

  void startEdit() {
    _initialGroups = state.valueOrNull?.map((g) => g.copyWith()).toList() ?? [];
  }

  void cancelChanges() {
    state = AsyncData(_initialGroups.map((g) => g.copyWith()).toList());
  }

  Future<void> saveChanges() async {
    final currentGroups = state.valueOrNull ?? [];
    final initialGroups = _initialGroups;
    final supabaseService = ref.read(supabaseServiceProvider);

    // --- BƯỚC KIỂM TRA THAY ĐỔI ---
    final List<Future> dbTasks = [];

    final deletedGroupIds =
        initialGroups
            .where(
              (initial) =>
                  !currentGroups.any((current) => current.id == initial.id),
            )
            .map((g) => g.id)
            .toList();

    for (final id in deletedGroupIds) {
      dbTasks.add(supabaseService.deleteTodoGroup(id));
    }

    for (final currentGroup in currentGroups) {
      final initialGroup = initialGroups.firstWhere(
        (g) => g.id == currentGroup.id,
        orElse: () => TodoGroup(id: '', title: ''),
      );

      if (initialGroup.id == '') {
        dbTasks.add(supabaseService.addTodoGroup(currentGroup));
      } else if (currentGroup.title != initialGroup.title) {
        dbTasks.add(
          supabaseService.updateTodoGroupTitle(
            currentGroup.id,
            currentGroup.title,
          ),
        );
      }
    }

    if (dbTasks.isEmpty) {
      return;
    }

    // Đặt state về loading để hiển thị trên UI
    state = const AsyncLoading();

    try {
      await Future.wait(dbTasks);

      // --- SỬA LỖI: TẢI LẠI DỮ LIỆU VÀ CẬP NHẬT STATE ---
      // Thay vì gọi build(), hãy chủ động fetch lại dữ liệu mới nhất
      final freshGroups = await supabaseService.getTodoGroups();
      // Cập nhật lại trạng thái ban đầu để cho lần edit tiếp theo
      _initialGroups = freshGroups.map((g) => g.copyWith()).toList();
      // Đặt state về AsyncData với dữ liệu mới để UI hết loading
      state = AsyncData(freshGroups);
      // --- KẾT THÚC SỬA LỖI ---
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

// 3. Thay đổi cách khai báo provider
final todoGroupProvider =
    AsyncNotifierProvider<TodoGroupNotifier, List<TodoGroup>>(
      TodoGroupNotifier.new,
    );
