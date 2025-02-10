import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/todo_group.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/providers/todo_group_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/services/file_service.dart';
import 'package:todo_app/widgets/todo_group_sidebar.dart';
import 'package:todo_app/widgets/todo_list.dart';
import 'package:path/path.dart' as path;

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  bool _isEditable = false;
  bool _showSidebar = true;
  int _seletedTabIndex = 0;

  void addTodo(BuildContext context, WidgetRef ref) async {
    String newId = ref.read(todoGroupProvider.notifier).getId(_seletedTabIndex);
    ref.read(todoProvider(newId).notifier).createTodo(ref);
  }

  @override
  void initState() {
    super.initState();

    _importFromFile();
  }

  @override
  Widget build(BuildContext context) {
    final todoGroups = ref.watch(todoGroupProvider);
    List<TodoItem> todoItems = [];

    if (_seletedTabIndex >= 0 && _seletedTabIndex < todoGroups.length) {
      todoItems = ref.watch(todoProvider(todoGroups[_seletedTabIndex].id));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: _showSidebar == false ? 'Show sidebar' : 'Hide sidebar',
          icon: Icon(_showSidebar == false ? Icons.menu : Icons.close),
          onPressed: () {
            setState(() {
              _showSidebar = !_showSidebar;
            });
          },
        ),
        actions: [..._buildActionButton()],
      ),
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showSidebar) ...[
            SizedBox(
              width: 200,
              child: TodoGroupSidebar(
                todoGroup: todoGroups,
                selectedIndex: _seletedTabIndex,
                onTabSelect: (tabIndex) {
                  setState(() => _seletedTabIndex = tabIndex);
                },
                onTabUpdate: (updatedInfo) {
                  for (int i = 0; i < updatedInfo.titleList.length; i++) {
                    String newTitle = updatedInfo.titleList[i];
                    if (i >= todoGroups.length) {
                      _addTodoGroup(newTitle);
                    } else {
                      todoGroups[i].title = newTitle;
                    }
                  }
                  setState(() {
                    todoGroups;
                  });
                },
                onDelete: (todoGroupIndex) {
                  _deleteTodoGroup(todoGroupIndex);
                },
              ),
            ),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
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
                child:
                    (_seletedTabIndex >= 0 &&
                            _seletedTabIndex < todoGroups.length)
                        ? (todoItems.isNotEmpty
                            ? TodoList(
                              editable: _isEditable,
                              todoItems: todoItems,
                              provider: todoProvider(
                                todoGroups[_seletedTabIndex].id,
                              ),
                              onReorder: (oldIndex, newIndex) {
                                ref
                                    .read(
                                      todoProvider(
                                        todoGroups[_seletedTabIndex].id,
                                      ).notifier,
                                    )
                                    .moveTodo(ref, oldIndex, newIndex);
                              },
                            )
                            : Center(
                              child: Text('No todo here. Try to add some!'),
                            ))
                        : Center(child: Text('No todo group. Add one!')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          _isEditable == true
              ? FloatingActionButton.small(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                onPressed: () {
                  addTodo(context, ref);
                },
                child: Icon(Icons.add),
              )
              : null,
    );
  }

  void _importFromFile() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
    String content = await FileService.readFile(file.path);
    Future.delayed(Duration.zero, () {
      try {
        ref.read(todoGroupProvider.notifier).fromJson(jsonDecode(content));
      } catch (e) {
        return;
      }
    });
  }

  void _exportToFile() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = File(path.join(dir.path, 'TodoApp', 'todo_items.json'));
    String content = jsonEncode(ref.read(todoGroupProvider.notifier).toJson());
    FileService.writeFile(file.path, content);
  }

  void _addTodoGroup(String title) async {
    int newIndex = ref
        .read(todoGroupProvider.notifier)
        .createGroup(title: title);

    setState(() {
      _seletedTabIndex = newIndex;
    });
  }

  void _deleteTodoGroup(int groupIndex) {
    ref.read(todoGroupProvider.notifier).deleteGroup(ref, groupIndex);
    if (_seletedTabIndex == groupIndex) {
      setState(() {
        _seletedTabIndex--;
      });
    }
  }

  Widget _buildSaveButton() {
    return Tooltip(
      message: 'Save',
      child: IconButton(icon: Icon(Icons.save_alt), onPressed: _exportToFile),
    );
  }

  Widget _buildDiscardChangesButton() {
    return Tooltip(
      message: 'Discard changes',
      child: IconButton(
        icon: Icon(Icons.highlight_remove),
        onPressed: () {
          String id = ref
              .read(todoGroupProvider.notifier)
              .getId(_seletedTabIndex);
          ref.read(todoProvider(id).notifier).cancelChanges(ref);
          setState(() => _isEditable = false);
        },
      ),
    );
  }

  Widget _buildEditButton() {
    return Tooltip(
      message: _isEditable ? 'Save' : 'Edit',
      child: IconButton(
        icon:
            _isEditable
                ? Icon(Icons.check, color: Colors.green)
                : Icon(Icons.edit),
        onPressed: () async {
          //toggle state
          if (!_isEditable) {
            String id = ref
                .read(todoGroupProvider.notifier)
                .getId(_seletedTabIndex);
            ref.read(todoProvider(id).notifier).startEdit();
          } else {
            String id = ref
                .read(todoGroupProvider.notifier)
                .getId(_seletedTabIndex);
            ref.read(todoProvider(id).notifier).saveChanges(ref);
          }
          setState(() => _isEditable = !_isEditable);
        },
      ),
    );
  }

  List<Widget> _buildActionButton() {
    return [
      if (_isEditable == false) ...[_buildSaveButton()],
      if (_isEditable) ...[_buildDiscardChangesButton()],
      _buildEditButton(),
      const SizedBox(width: 16),
    ];
  }
}
