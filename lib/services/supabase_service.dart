import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/models/todo_item.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Thao tác với Todo Groups ---

  Future<List<TodoGroup>> fetchTodoGroups() async {
    try {
      final response = await _supabase
          .from('todo_groups')
          .select('id, title, created_at')
          .order('created_at', ascending: true);

      final List<TodoGroup> groups =
          (response as List).map((groupJson) {
            return TodoGroup(id: groupJson['id'], title: groupJson['title']);
          }).toList();

      return groups;
    } catch (e) {
      print('Error fetching todo groups: $e');
      return [];
    }
  }

  /// Lấy tất cả các nhóm công việc từ bảng 'todo_groups'.
  Future<List<TodoGroup>> getTodoGroups() async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('todo_groups')
          .select('*')
          .order('created_at', ascending: true);

      // Nếu có lỗi xảy ra ở đây, nó sẽ được bắt bởi khối catch bên ngoài
      // Supabase client sẽ ném PostgrestException nếu có vấn đề từ phía API.

      return data.map((json) => TodoGroup.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException getting todo groups: ${e.message}',
      );
      rethrow; // Ném lại lỗi PostgrestException
    } catch (e) {
      print('SupabaseService: Unknown error getting todo groups: $e');
      rethrow; // Ném lại bất kỳ lỗi nào khác
    }
  }

  /// Tạo một nhóm công việc mới trong bảng 'todo_groups'.
  Future<TodoGroup> createTodoGroup(String title) async {
    try {
      final Map<String, dynamic> data =
          await _supabase
              .from('todo_groups')
              .insert({'title': title})
              .select()
              .single();

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException

      return TodoGroup.fromJson(data);
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException creating todo group: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error creating todo group: $e');
      rethrow;
    }
  }

  Future<void> addTodoGroup(TodoGroup group) async {
    try {
      await _supabase.from('todo_groups').insert({
        'id': group.id,
        'title': group.title,
      });
    } catch (e) {
      print('Error adding todo group: $e');
      rethrow;
    }
  }

  /// Cập nhật tiêu đề của một nhóm công việc trong bảng 'todo_groups'.
  Future<void> updateTodoGroupTitle(String groupId, String newTitle) async {
    try {
      await _supabase
          .from('todo_groups')
          .update({'title': newTitle})
          .eq('id', groupId);

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException updating todo group title: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error updating todo group title: $e');
      rethrow;
    }
  }

  /// Xóa một nhóm công việc khỏi bảng 'todo_groups'.
  Future<void> deleteTodoGroup(String groupId) async {
    try {
      await _supabase.from('todo_groups').delete().eq('id', groupId);

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException deleting todo group: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error deleting todo group: $e');
      rethrow;
    }
  }

  // --- Thao tác với Todo Items ---

  /// Lấy tất cả các mục công việc cho một nhóm cụ thể từ bảng 'todo_items'.
  Future<List<TodoItem>> getTodoItemsForGroup(String groupId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('todo_items')
          .select('*')
          .eq('group_id', groupId);

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException

      return data.map((json) => TodoItem.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException getting todo items for group $groupId: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print(
        'SupabaseService: Unknown error getting todo items for group $groupId: $e',
      );
      rethrow;
    }
  }

  /// Tạo một mục công việc mới trong bảng 'todo_items'.
  Future<TodoItem> createTodoItem(String groupId, String title) async {
    try {
      final Map<String, dynamic> data =
          await _supabase
              .from('todo_items')
              .insert({
                'group_id': groupId,
                'title': title,
                'is_completed': false,
                'date': DateTime.now().toIso8601String(),
                'include_time': false,
                'task_time_string': null,
              })
              .select()
              .single();

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException

      return TodoItem.fromJson(data);
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException creating todo item: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error creating todo item: $e');
      rethrow;
    }
  }

  Future<TodoItem> addTodoItem(TodoItem item) async {
    try {
      final Map<String, dynamic> data =
          await _supabase
              .from('todo_items')
              .insert(item.toJson())
              .select()
              .single();

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException

      return TodoItem.fromJson(data);
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException creating todo item: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error creating todo item: $e');
      rethrow;
    }
  }

  /// Cập nhật một mục công việc hiện có trong bảng 'todo_items'.
  Future<void> updateTodoItem(TodoItem item) async {
    try {
      await _supabase
          .from('todo_items')
          .update(item.toJson())
          .eq('id', item.id);

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException updating todo item ${item.id}: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error updating todo item ${item.id}: $e');
      rethrow;
    }
  }

  /// Xóa một mục công việc khỏi bảng 'todo_items'.
  Future<void> deleteTodoItem(String todoItemId) async {
    try {
      await _supabase.from('todo_items').delete().eq('id', todoItemId);

      // Nếu có lỗi, nó sẽ được ném dưới dạng PostgrestException
    } on PostgrestException catch (e) {
      print(
        'SupabaseService: PostgrestException deleting todo item: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('SupabaseService: Unknown error deleting todo item: $e');
      rethrow;
    }
  }
}

// Tạo một Riverpod Provider cho SupabaseService
final supabaseServiceProvider = Provider((ref) => SupabaseService());
