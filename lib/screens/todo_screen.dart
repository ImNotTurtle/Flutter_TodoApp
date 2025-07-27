import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_item.dart'; // Đảm bảo import đúng model TodoItem
import 'package:todo_app/providers/todo_group_provider.dart'; // Đảm bảo import đúng provider
import 'package:todo_app/providers/todo_provider.dart'; // Đảm bảo import đúng provider
import 'package:todo_app/widgets/todo_group_sidebar.dart';
import 'package:todo_app/widgets/todo_list.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  bool _isEditable = false;
  int _seletedTabIndex = 0; // Index của nhóm todo đang được chọn
  static const double mobileBreakpoint = 768; // Ngưỡng để xác định màn hình mobile

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu từ Supabase khi khởi tạo màn hình
    Future.microtask(() async {
      await ref.read(todoGroupProvider.notifier).loadGroups();

      // Sau khi nhóm được tải, chọn nhóm đầu tiên (nếu có)
      final todoGroups = ref.read(todoGroupProvider);
      if (todoGroups.isNotEmpty) {
        if (_seletedTabIndex >= todoGroups.length) {
          _seletedTabIndex = 0;
        }
      }
      if (mounted) {
        setState(() {}); // Cập nhật UI sau khi tải dữ liệu ban đầu
      }
    });
  }

  void addTodo(BuildContext context, WidgetRef ref) async {
    final todoGroups = ref.read(todoGroupProvider);
    if (todoGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a todo group first!')),
      );
      return;
    }
    String groupId = todoGroups[_seletedTabIndex].id;
    ref.read(todoProvider(groupId).notifier).createTodo(ref); // Gọi createTodo
  }

  Future<void> _addTodoGroup(String title) async {
    int newIndex = await ref.read(todoGroupProvider.notifier).createGroup(title: title);

    if (newIndex != -1) {
      setState(() {
        _seletedTabIndex = newIndex;
      });
    }
  }

  void _deleteTodoGroup(int groupIndex) async {
    if (groupIndex < 0 || groupIndex >= ref.read(todoGroupProvider).length) {
      return;
    }

    final deletedGroupId = ref.read(todoGroupProvider)[groupIndex].id;

    if (_isEditable && _seletedTabIndex == groupIndex) {
      ref.read(todoProvider(deletedGroupId).notifier).cancelChanges(ref);
      ref.read(todoGroupProvider.notifier).cancelChanges();
    }

    await ref.read(todoGroupProvider.notifier).deleteGroup(ref, groupIndex);

    final todoGroups = ref.read(todoGroupProvider);
    if (todoGroups.isNotEmpty) {
      setState(() {
        _seletedTabIndex = (groupIndex - 1).clamp(0, todoGroups.length - 1);
      });
    } else {
      setState(() {
        _seletedTabIndex = -1;
      });
    }
  }

  Widget _buildDiscardChangesButton() {
    final todoGroups = ref.read(todoGroupProvider);
    String? currentGroupId;
    if (_seletedTabIndex >= 0 && _seletedTabIndex < todoGroups.length) {
      currentGroupId = todoGroups[_seletedTabIndex].id;
    }

    if (!_isEditable || currentGroupId == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Discard changes',
      child: IconButton(
        icon: const Icon(Icons.highlight_remove),
        onPressed: () {
          ref.read(todoProvider(currentGroupId!).notifier).cancelChanges(ref);
          ref.read(todoGroupProvider.notifier).cancelChanges();
          setState(() => _isEditable = false);
        },
      ),
    );
  }

  Widget _buildEditButton() {
    final todoGroups = ref.watch(todoGroupProvider);
    String? currentGroupId;
    if (_seletedTabIndex >= 0 && _seletedTabIndex < todoGroups.length) {
      currentGroupId = todoGroups[_seletedTabIndex].id;
    }

    if (currentGroupId == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: _isEditable ? 'Save' : 'Edit',
      child: IconButton(
        icon: _isEditable
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.edit),
        onPressed: () async {
          if (currentGroupId != null) {
            if (!_isEditable) {
              ref.read(todoProvider(currentGroupId).notifier).startEdit();
              ref.read(todoGroupProvider.notifier).startEdit();
            } else {
              await ref.read(todoProvider(currentGroupId).notifier).saveChanges(ref);
              await ref.read(todoGroupProvider.notifier).saveChanges(ref);
            }
          }
          setState(() => _isEditable = !_isEditable);
        },
      ),
    );
  }

  List<Widget> _buildActionButton() {
    return [
      if (_isEditable) ...[_buildDiscardChangesButton()],
      _buildEditButton(),
      const SizedBox(width: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final todoGroups = ref.watch(todoGroupProvider);
    String? currentSelectedGroupId;
    if (_seletedTabIndex >= 0 && _seletedTabIndex < todoGroups.length) {
      currentSelectedGroupId = todoGroups[_seletedTabIndex].id;
    } else if (todoGroups.isNotEmpty) {
      _seletedTabIndex = 0;
      currentSelectedGroupId = todoGroups.first.id;
    }

    final todoItems = (currentSelectedGroupId != null)
        ? ref.watch(todoProvider(currentSelectedGroupId))
        : <TodoItem>[];

    final sidebar = TodoGroupSidebar(
      todoGroup: todoGroups,
      selectedIndex: _seletedTabIndex,
      onTabSelect: (tabIndex, {bool isMobile = false}) async {
        if (_isEditable && currentSelectedGroupId != null) {
          ref.read(todoProvider(currentSelectedGroupId).notifier).cancelChanges(ref);
          ref.read(todoGroupProvider.notifier).cancelChanges();
        }

        setState(() {
          _seletedTabIndex = tabIndex;
          _isEditable = false;
        });

        if (isMobile) {
          Navigator.of(context).pop();
        }
      },
      onTabUpdate: (updatedInfo) async {
        for (int i = 0; i < todoGroups.length && i < updatedInfo.titleList.length; i++) {
          String newTitle = updatedInfo.titleList[i];
          if (todoGroups[i].title != newTitle.trim()) {
            ref.read(todoGroupProvider.notifier).updateGroupTitle(i, newTitle.trim());
          }
        }
        for (int i = todoGroups.length; i < updatedInfo.titleList.length; i++) {
          String newTitle = updatedInfo.titleList[i];
          if (newTitle.trim().isNotEmpty) {
            await _addTodoGroup(newTitle.trim());
          }
        }
      },
      onDelete: (todoGroupIndex) {
        _deleteTodoGroup(todoGroupIndex);
      },
    );

    final mainContent = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 8.0,
        ),
        child: (currentSelectedGroupId != null)
            ? (todoItems.isNotEmpty
                ? TodoList(
                    editable: _isEditable,
                    todoItems: todoItems,
                  )
                : const Center(
                    child: Text('No todo here. Try to add some!'),
                  ))
            : const Center(child: Text('No todo group. Add one!')),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        return Scaffold(
          appBar: AppBar(
            title: _isEditable && currentSelectedGroupId != null
                ? TextField(
                    controller: TextEditingController(
                      text: todoGroups[_seletedTabIndex].title,
                    ),
                    onSubmitted: (newTitle) {
                      if (newTitle.trim().isNotEmpty) {
                        ref
                            .read(todoGroupProvider.notifier)
                            .updateGroupTitle(_seletedTabIndex, newTitle.trim());
                      }
                      setState(() => _isEditable = false);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Group Title',
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                : Text(
                    currentSelectedGroupId != null && todoGroups.isNotEmpty
                        ? todoGroups[_seletedTabIndex].title
                        : 'Todo App',
                  ),
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Open sidebar',
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  )
                : null,
            actions: [..._buildActionButton()],
          ),
          drawer: isMobile ? Drawer(child: sidebar) : null,
          body: isMobile
              ? mainContent
              : Row(
                  children: [
                    SizedBox(width: 200, child: sidebar),
                    Expanded(child: mainContent),
                  ],
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _isEditable == true
              ? FloatingActionButton.small(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  onPressed: () {
                    addTodo(context, ref);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}