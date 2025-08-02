import 'package:flutter/material.dart';

class TodoGroupResponse {
  String title;
  TodoGroupResponse({required this.title});
}

// 1. Chuyển thành StatefulWidget để quản lý vòng đời của Controller và FocusNode
class TodoGroupDialog extends StatefulWidget {
  final String? initialTitle;
  const TodoGroupDialog({super.key, this.initialTitle});

  @override
  State<TodoGroupDialog> createState() => _TodoGroupDialogState();
}

class _TodoGroupDialogState extends State<TodoGroupDialog> {
  // 2. Khai báo Controller và FocusNode
  late final TextEditingController _titleController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // 3. Khởi tạo chúng MỘT LẦN trong initState
    _titleController = TextEditingController(text: widget.initialTitle);
    _focusNode = FocusNode();

    // Yêu cầu focus sau khi frame đầu tiên được vẽ xong để đảm bảo an toàn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // 4. Huỷ chúng để tránh rò rỉ bộ nhớ
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isNotEmpty) {
      Navigator.of(context).pop<TodoGroupResponse>(
        TodoGroupResponse(title: _titleController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle == null ? 'Create Group' : 'Edit Group'),
      content: SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            // 5. Sử dụng các đối tượng đã được duy trì
            focusNode: _focusNode,
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
            onSubmitted: (_) => _save(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
