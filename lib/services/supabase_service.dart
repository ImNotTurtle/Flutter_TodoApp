import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:url_strategy/url_strategy.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient? _supabase;
  bool _initialized = false;

  /// Hàm init an toàn: chỉ khởi tạo một lần
  Future<void> init({required String url, required String anonKey}) async {
    if (_initialized && _supabase != null) {
      log("SupabaseService: đã init, bỏ qua.");
      return;
    }

    // Cấu hình URL cho web để loại bỏ dấu '#'
    setPathUrlStrategy();

    await Supabase.initialize(url: url, anonKey: anonKey);
    _supabase = Supabase.instance.client;
    _initialized = true;
    log('Supabase instance configured!');
  }

  SupabaseClient get client {
    if (!_initialized || _supabase == null) {
      throw Exception(
        "SupabaseService: client chưa được khởi tạo. Gọi init() trước.",
      );
    }
    return _supabase!;
  }

  bool get isReady => _initialized && _supabase != null;

  // --- Thao tác với Todo Groups ---
  Future<List<Map<String, dynamic>>> fetchTodoGroups() async {
    if (!isReady) {
      log("⚠️ fetchTodoGroups() gọi khi Supabase chưa sẵn sàng");
      return [];
    }
    try {
      final response = await client.from('todo_groups').select();
      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (error) {
      log('--- POSTGREST ERROR (fetchTodoGroups) ---');
      log('Message: ${error.message}');
      log('Code: ${error.code}');
      log('Details: ${error.details}');
      rethrow;
    } catch (e) {
      log('--- GENERIC ERROR (fetchTodoGroups) ---: $e');
      rethrow;
    }
  }

  Future<List<TodoGroup>> getTodoGroups() async {
    if (!isReady) return [];
    try {
      final List<Map<String, dynamic>> data = await client
          .from('todo_groups')
          .select('*')
          .order('created_at', ascending: true);

      return data.map((json) => TodoGroup.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      log(
        'SupabaseService: PostgrestException getting todo groups: ${e.message}',
      );
      rethrow;
    } catch (e) {
      log('SupabaseService: Unknown error getting todo groups: $e');
      rethrow;
    }
  }

  Future<TodoGroup> createTodoGroup(String title) async {
    if (!isReady) throw Exception("Supabase chưa sẵn sàng để tạo group");
    try {
      final Map<String, dynamic> data =
          await client
              .from('todo_groups')
              .insert({'title': title})
              .select()
              .single();
      return TodoGroup.fromJson(data);
    } on PostgrestException catch (e) {
      log(
        'SupabaseService: PostgrestException creating todo group: ${e.message}',
      );
      rethrow;
    } catch (e) {
      log('SupabaseService: Unknown error creating todo group: $e');
      rethrow;
    }
  }

  Future<void> addTodoGroup(TodoGroup group) async {
    if (!isReady) return;
    try {
      await client.from('todo_groups').insert({
        'id': group.id,
        'title': group.title,
      });
    } on PostgrestException catch (error) {
      log('--- POSTGREST ERROR (addTodoGroup) ---');
      log('Message: ${error.message}');
      log('Code: ${error.code}');
      log('Details: ${error.details}');
      rethrow;
    } catch (e) {
      log('--- GENERIC ERROR (addTodoGroup) ---: $e');
      rethrow;
    }
  }

  Future<void> updateTodoGroupTitle(String groupId, String newTitle) async {
    if (!isReady) return;
    try {
      await client
          .from('todo_groups')
          .update({'title': newTitle})
          .eq('id', groupId);
    } on PostgrestException catch (error) {
      log('--- POSTGREST ERROR (updateTodoGroupTitle) ---');
      log('Message: ${error.message}');
      log('Code: ${error.code}');
      log('Details: ${error.details}');
      rethrow;
    } catch (e) {
      log('--- GENERIC ERROR (updateTodoGroupTitle) ---: $e');
      rethrow;
    }
  }

  Future<void> deleteTodoGroup(String groupId) async {
    if (!isReady) return;
    try {
      await client.from('todo_items').delete().eq('group_id', groupId);
      await client.from('todo_groups').delete().eq('id', groupId);
    } on PostgrestException catch (error) {
      log('--- POSTGREST ERROR (deleteTodoGroup) ---');
      log('Message: ${error.message}');
      log('Code: ${error.code}');
      log('Details: ${error.details}');
      rethrow;
    } catch (e) {
      log('--- GENERIC ERROR (deleteTodoGroup) ---: $e');
      rethrow;
    }
  }

  // --- Thao tác với Todo Items ---
  Future<List<TodoItem>> getTodoItemsForGroup(String groupId) async {
    if (!isReady) return [];
    try {
      final List<Map<String, dynamic>> data = await client
          .from('todo_items')
          .select('*')
          .eq('group_id', groupId);
      return data.map((json) => TodoItem.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      log(
        'SupabaseService: PostgrestException getting todo items for group $groupId: ${e.message}',
      );
      rethrow;
    } catch (e) {
      log(
        'SupabaseService: Unknown error getting todo items for group $groupId: $e',
      );
      rethrow;
    }
  }

  Future<TodoItem> upsertTodoItem(TodoItem item) async {
    if (!isReady) throw Exception("Supabase chưa sẵn sàng để upsert item");
    try {
      final Map<String, dynamic> data =
          await client
              .from('todo_items')
              .upsert(item.toJson())
              .select()
              .single();
      return TodoItem.fromJson(data);
    } on PostgrestException catch (e) {
      log(
        'SupabaseService: PostgrestException upserting todo item ${item.id}: ${e.message}',
      );
      rethrow;
    } catch (e) {
      log('SupabaseService: Unknown error upserting todo item ${item.id}: $e');
      rethrow;
    }
  }

  Future<void> deleteTodoItem(String todoItemId) async {
    if (!isReady) return;
    try {
      await client.from('todo_items').delete().eq('id', todoItemId);
    } on PostgrestException catch (e) {
      log(
        'SupabaseService: PostgrestException deleting todo item: ${e.message}',
      );
      rethrow;
    } catch (e) {
      log('SupabaseService: Unknown error deleting todo item: $e');
      rethrow;
    }
  }
}

final supabaseServiceProvider = Provider((ref) => SupabaseService.instance);
