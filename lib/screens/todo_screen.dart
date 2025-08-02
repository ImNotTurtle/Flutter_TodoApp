import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/todo_group_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_group_sidebar.dart';
import 'package:todo_app/widgets/todo_list.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  bool _isEditable = false;
  int _seletedTabIndex = 0;

  void _onTabSelect(int tabIndex) {
    final todoGroups = ref.read(todoGroupProvider).valueOrNull ?? [];
    if (_isEditable && _seletedTabIndex < todoGroups.length) {
      final previousGroupId = todoGroups[_seletedTabIndex].id;
      ref.read(todoProvider(previousGroupId).notifier).cancelChanges();
      ref.read(todoGroupProvider.notifier).cancelChanges();
    }
    setState(() {
      _seletedTabIndex = tabIndex;
      _isEditable = false;
    });
  }

  void _onDeleteGroup(int groupIndex) {
    final todoGroups = ref.read(todoGroupProvider).valueOrNull ?? [];
    if (groupIndex < 0 || groupIndex >= todoGroups.length) return;

    ref.read(todoGroupProvider.notifier).deleteGroup(groupIndex);

    final newCount = (ref.read(todoGroupProvider).valueOrNull ?? []).length;
    setState(() {
      _seletedTabIndex = (groupIndex - 1).clamp(0, newCount > 0 ? newCount - 1 : 0);
    });
  }

  void _toggleEditSave() {
    final todoGroups = ref.read(todoGroupProvider).valueOrNull ?? [];
    if (todoGroups.isEmpty || _seletedTabIndex >= todoGroups.length) return;
    
    final currentGroupId = todoGroups[_seletedTabIndex].id;

    if (!_isEditable) {
      ref.read(todoProvider(currentGroupId).notifier).startEdit();
      ref.read(todoGroupProvider.notifier).startEdit();
      setState(() {
        _isEditable = true;
      });
    } else {
      // Đặt isEditable về false ngay lập tức để UI phản hồi
      setState(() {
        _isEditable = false;
      });
      // Thực hiện lưu và chờ kết quả
      Future.wait([
        ref.read(todoProvider(currentGroupId).notifier).saveChanges(),
        ref.read(todoGroupProvider.notifier).saveChanges(),
      ]);
    }
  }

  void _discardChanges() {
    final todoGroups = ref.read(todoGroupProvider).valueOrNull ?? [];
    if (todoGroups.isEmpty || _seletedTabIndex >= todoGroups.length) return;

    final currentGroupId = todoGroups[_seletedTabIndex].id;
    ref.read(todoProvider(currentGroupId).notifier).cancelChanges();
    ref.read(todoGroupProvider.notifier).cancelChanges();
    setState(() {
      _isEditable = false;
    });
  }

  void _addTodo() {
    final todoGroups = ref.read(todoGroupProvider).valueOrNull ?? [];
    if (todoGroups.isEmpty || _seletedTabIndex >= todoGroups.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a todo group first!')),
        );
      }
      return;
    }
    final String groupId = todoGroups[_seletedTabIndex].id;
    ref.read(todoProvider(groupId).notifier).createTodo();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTodoGroups = ref.watch(todoGroupProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.95),
      body: asyncTodoGroups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (todoGroups) {
          final sidebar = TodoGroupSidebar(
            todoGroup: todoGroups,
            selectedIndex: _seletedTabIndex,
            onTabSelect: (tabIndex, {bool isMobile = false}) {
              _onTabSelect(tabIndex);
              if (isMobile) {
                Navigator.of(context).pop();
              }
            },
            onCreateGroup: (title){

            },
            onTabUpdate: (index, newTitle){

            },
            onDelete: _onDeleteGroup,
          );

          final mainContent = TodoList(
            key: ValueKey(todoGroups.isNotEmpty && _seletedTabIndex < todoGroups.length ? todoGroups[_seletedTabIndex].id : 'empty'),
            isEditable: _isEditable,
            todoGroups: todoGroups,
            selectedTabIndex: _seletedTabIndex,
            onAddTodo: _addTodo,
            onDiscard: _discardChanges,
            onToggleEditSave: _toggleEditSave,
            mobileDrawer: Drawer(child: sidebar),
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 768;
              if (isMobile) {
                return mainContent;
              } else {
                return Row(
                  children: [
                    SizedBox(width: 250, child: sidebar),
                    const VerticalDivider(width: 1),
                    Expanded(child: mainContent),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
