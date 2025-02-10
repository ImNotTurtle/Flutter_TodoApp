import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/widgets/dialogs/todo_group_dialog.dart';

class TodoGroupSidebarInfo {
  final List<String> titleList;
  const TodoGroupSidebarInfo({required this.titleList});
}

class TodoGroupSidebar extends ConsumerStatefulWidget {
  final void Function(int tabIndex) onTabSelect;
  final void Function(TodoGroupSidebarInfo updatedInfo) onTabUpdate;
  final void Function(int todoGroupIndex) onDelete;
  final int selectedIndex;
  final List<TodoGroup> todoGroup;
  const TodoGroupSidebar({
    super.key,
    required this.todoGroup,
    required this.onTabSelect,
    required this.selectedIndex,
    required this.onTabUpdate,
    required this.onDelete,
  });

  @override
  ConsumerState<TodoGroupSidebar> createState() {
    return _TodoGroupSidebarState();
  }
}

class _TodoGroupSidebarState extends ConsumerState<TodoGroupSidebar> {
  int selectedIndex = 0;
  TodoGroupSidebarInfo groupInfo = TodoGroupSidebarInfo(titleList: []);

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    groupInfo = TodoGroupSidebarInfo(
      titleList: widget.todoGroup.map((item) => item.title).toList(),
    );
  }

  @override
  void didUpdateWidget(covariant TodoGroupSidebar oldWidget) {
    selectedIndex = widget.selectedIndex;
    groupInfo = TodoGroupSidebarInfo(
      titleList: widget.todoGroup.map((item) => item.title).toList(),
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(children: [_buildTodoListView()]),
      ),
    );
  }

  Widget _buildTodoListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: groupInfo.titleList.length + 1,
      itemBuilder: (ctx, index) {
        if (index != groupInfo.titleList.length) {
          return GestureDetector(
            onSecondaryTapDown: (details) {
              _showMenu(context, details, index);
            },
            child: ListTile(
              title: Text(groupInfo.titleList[index]),
              selected: selectedIndex == index,
              selectedTileColor: Theme.of(context).colorScheme.onSecondary,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onTabSelect(index);
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
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: _createTodoGroup,
                child: Icon(Icons.add),
              ),
            ),
          );
        }
      },
    );
  }

  void _editTodoGroup(int index) async {
    final response = await showDialog<TodoGroupResponse>(
      context: context,
      builder:
          (ctx) => TodoGroupDialog(initialTitle: groupInfo.titleList[index]),
    );
    if (response != null) {
      setState(() => groupInfo.titleList[index] = response.title);
      widget.onTabUpdate(groupInfo);
    }
  }

  void _createTodoGroup() async {
    final response = await showDialog<TodoGroupResponse>(
      context: context,
      builder: (ctx) => TodoGroupDialog(),
    );
    if (response != null) {
      _addTodoGroup(response);
    }
  }

  void _addTodoGroup(TodoGroupResponse response) {
    setState(() => groupInfo.titleList.add(response.title));
    // widget.onTabUpdate(TodoGroupSidebarInfo(titleList: titleList));
    widget.onTabUpdate(groupInfo);
  }

  void _deleteTodoGroup(int todoGroupIndex) async {
    bool? result = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Confirm"),
            content: Text("This action can not be undo"),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      ctx,
                    ).pop(false), // Trả về false nếu chọn No
                child: Text("No"),
              ),
              ElevatedButton(
                onPressed:
                    () =>
                        Navigator.of(ctx).pop(true), // Trả về true nếu chọn Yes
                child: Text("Yes"),
              ),
            ],
          ),
    );

    if (result != null && result) {
      setState(() => groupInfo.titleList.removeAt(todoGroupIndex));
      widget.onDelete(todoGroupIndex);
    }
  }

  void _showMenu(BuildContext context, TapDownDetails details, int todoIndex) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Edit'),
          onTap: () {
            _editTodoGroup(todoIndex);
          },
        ),
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () {
            _deleteTodoGroup(todoIndex);
          },
        ),
      ],
    );
  }
}
