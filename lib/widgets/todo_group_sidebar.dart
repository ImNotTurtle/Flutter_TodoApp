import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/widgets/dialogs/todo_group_dialog.dart';

class TodoGroupSidebar extends ConsumerWidget {
  final void Function(int tabIndex, {bool isMobile}) onTabSelect;
  final void Function(int index, String newTitle) onTabUpdate;
  final void Function(String title) onCreateGroup;
  final void Function(int todoGroupIndex) onDelete;
  final int selectedIndex;
  final List<TodoGroup> todoGroup;

  const TodoGroupSidebar({
    super.key,
    required this.todoGroup,
    required this.onTabSelect,
    required this.selectedIndex,
    required this.onTabUpdate,
    required this.onCreateGroup,
    required this.onDelete,
  });

  void _editTodoGroup(BuildContext context, int index) async {
    final response = await showDialog<TodoGroupResponse>(
      context: context,
      builder: (ctx) => TodoGroupDialog(initialTitle: todoGroup[index].title),
    );
    if (response != null && response.title.isNotEmpty) {
      onTabUpdate(index, response.title);
    }
  }

  void _createTodoGroup(BuildContext context) async {
    final response = await showDialog<TodoGroupResponse>(
      context: context,
      builder: (ctx) => const TodoGroupDialog(),
    );
    if (response != null && response.title.isNotEmpty) {
      onCreateGroup(response.title);
    }
  }

  void _deleteTodoGroup(BuildContext context, int todoGroupIndex) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      onDelete(todoGroupIndex);
    }
  }

  void _showMenu(BuildContext context, Offset globalPosition, int todoIndex) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          onTap: () => _editTodoGroup(context, todoIndex),
          child: const Text('Edit'),
        ),
        PopupMenuItem(
          onTap: () => _deleteTodoGroup(context, todoIndex),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Scaffold.of(context).hasDrawer;

    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: todoGroup.length + 1,
                itemBuilder: (ctx, index) {
                  if (index < todoGroup.length) {
                    return GestureDetector(
                      onLongPressStart: (details) {
                        _showMenu(context, details.globalPosition, index);
                      },
                      child: ListTile(
                        title: Text(todoGroup[index].title),
                        selected: selectedIndex == index,
                        selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                        onTap: () {
                          onTabSelect(index, isMobile: isMobile);
                        },
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          onPressed: () => _createTodoGroup(context),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
