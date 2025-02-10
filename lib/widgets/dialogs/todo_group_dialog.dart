import 'package:flutter/material.dart';

class TodoGroupResponse {
  String title;
  TodoGroupResponse({required this.title});
}

class TodoGroupDialog extends StatelessWidget {
  final String? initialTitle;
  const TodoGroupDialog({super.key, this.initialTitle});
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    focusNode.requestFocus();
    final TextEditingController titleController = TextEditingController(
      text: initialTitle,
    );
    return AlertDialog(
      content: SizedBox(
        width: 200,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text('Title'),
            ),
            controller: titleController,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop<TodoGroupResponse>(
              TodoGroupResponse(title: titleController.text),
            );
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
