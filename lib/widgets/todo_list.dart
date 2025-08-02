import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_tile.dart';

class TodoList extends ConsumerWidget {
  const TodoList({
    super.key,
    required this.isEditable,
    required this.todoGroups,
    required this.selectedTabIndex,
    required this.onToggleEditSave,
    required this.onDiscard,
    required this.onAddTodo,
    this.mobileDrawer,
  });

  final bool isEditable;
  final List<TodoGroup> todoGroups;
  final int selectedTabIndex;
  final VoidCallback onToggleEditSave;
  final VoidCallback onDiscard;
  final VoidCallback onAddTodo;
  final Widget? mobileDrawer;

  Widget _buildEditSaveButton() {
    return Tooltip(
      message: isEditable ? 'Save' : 'Edit',
      child: IconButton(
        icon: isEditable
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.edit),
        onPressed: onToggleEditSave,
      ),
    );
  }

  Widget _buildDiscardButton() {
    if (!isEditable) {
      return const SizedBox.shrink();
    }
    return Tooltip(
      message: 'Discard changes',
      child: IconButton(
        icon: const Icon(Icons.highlight_remove),
        onPressed: onDiscard,
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (!isEditable) {
      return null;
    }
    return FloatingActionButton.small(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onPressed: onAddTodo,
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? groupId = todoGroups.isNotEmpty && selectedTabIndex < todoGroups.length
        ? todoGroups[selectedTabIndex].id
        : null;

    final String title = todoGroups.isNotEmpty && selectedTabIndex < todoGroups.length
        ? todoGroups[selectedTabIndex].title
        : 'Todo App';

    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open sidebar',
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          _buildDiscardButton(),
          _buildEditSaveButton(),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isMobile ? mobileDrawer : null,
      body: _buildBody(context, ref, groupId),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, String? groupId) {
    if (groupId == null) {
      return const Center(child: Text('Please select or create a group.'));
    }

    final asyncTodoItems = ref.watch(todoProvider(groupId));

    return asyncTodoItems.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (todoItems) {
        final Widget listContent = isEditable
            ? ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.only(top: 8),
                itemCount: todoItems.length,
                itemBuilder: (ctx, index) {
                  final todo = todoItems[index];
                  return TodoTile(
                    key: ValueKey(todo.id),
                    displayIndex: index,
                    todoId: todo.id,
                    groupId: groupId,
                    editable: isEditable,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  ref.read(todoProvider(groupId).notifier).moveTodo(oldIndex, newIndex);
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: todoItems.length,
                itemBuilder: (ctx, index) {
                  final todo = todoItems[index];
                  return TodoTile(
                    key: ValueKey(todo.id),
                    displayIndex: index,
                    todoId: todo.id,
                    groupId: groupId,
                    editable: isEditable,
                  );
                },
              );

        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: listContent,
        );
      },
    );
  }
}
