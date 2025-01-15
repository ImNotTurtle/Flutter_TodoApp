import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/todo_list.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  bool _isEditable = false;
  int _currentSelectTab = 0;

  void addTodo(BuildContext context, WidgetRef ref) async {
    ref.read(todoProvider.notifier).createTodo();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(todoProvider.notifier).loadFromFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    var todoItems = ref.watch(todoProvider);
    if (_currentSelectTab == 1) {
      todoItems = todoItems.where((item) => item.isCompleted == true).toList();
    } else if (_currentSelectTab == 2) {
      todoItems = todoItems.where((item) => item.isCompleted == false).toList();
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(icon: Icon(Icons.abc), onPressed: (){
          //   // ref.read(todoProvider.notifier).test();
          // },),
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () {
              ref.read(todoProvider.notifier).saveToFile();
            },
          ),
          if (_isEditable) ...[
            IconButton(
              icon: Icon(Icons.highlight_remove),
              onPressed: () {
                ref.read(todoProvider.notifier).cancelChanges();
                setState(() => _isEditable = false);
              },
            ),
          ],
          IconButton(
            icon:
                _isEditable
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.edit),
            onPressed: () async {
              
              if (!_isEditable) { //toggle state
                ref.read(todoProvider.notifier).startEdit();
              } else {
                ref.read(todoProvider.notifier).saveChanges();
              }
              setState(() => _isEditable = !_isEditable);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TodoList(
          editable: _isEditable,
          todoItems: todoItems,
          provider: todoProvider,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentSelectTab,
        selectedFontSize: 16,
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/all-todo-list.png')),
            label: 'All todo',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/done-list.png')),
            label: 'Done list',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/not-finished-list.png')),
            label: 'Not finished list',
          ),
        ],
        onTap: (value) {
          setState(() => _currentSelectTab = value);
        },
      ),
      floatingActionButton:
          _isEditable == true
              ? FloatingActionButton.small(
                onPressed: () {
                  addTodo(context, ref);
                },
                child: Icon(Icons.add),
              )
              : null,
    );
  }
}
