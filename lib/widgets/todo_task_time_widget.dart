// widgets/todo_task_time_widget.dart
import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_task_time.dart';

class TodoTaskTimeWidget extends StatelessWidget {
  const TodoTaskTimeWidget({
    super.key,
    required this.taskTime, // Thay đổi từ TodoTaskTime thành TodoTaskTime?
    this.isEditable = false,
    this.onTimeUpdated,
    this.onTimeRemoved, // Thêm tham số này để sửa lỗi thứ hai
  });

  final TodoTaskTime? taskTime; // Bây giờ nó có thể là null
  final bool isEditable;
  final ValueChanged<TodoTaskTime>? onTimeUpdated;
  final VoidCallback? onTimeRemoved; // Định nghĩa tham số onTimeRemoved

  @override
  Widget build(BuildContext context) {
    if (taskTime == null) {
      if (isEditable) {
        return InkWell(
          onTap: () async {
            final newTime = await _showTaskTimeEditDialog(context, null);
            if (newTime != null && onTimeUpdated != null) {
              onTimeUpdated!(newTime);
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Add Task Time',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return InkWell(
      onTap: isEditable
          ? () async {
              final updatedTime = await _showTaskTimeEditDialog(context, taskTime);
              if (updatedTime != null) {
                if (onTimeUpdated != null) {
                  onTimeUpdated!(updatedTime);
                }
              } else { // Nếu dialog trả về null, có thể hiểu là muốn xóa
                if (onTimeRemoved != null) {
                  onTimeRemoved!();
                }
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          taskTime!.toString(), // taskTime vẫn có thể được truy cập an toàn ở đây
          style: TextStyle(
            color: isEditable ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  // Dialog để chỉnh sửa hoặc thêm Task Time
  Future<TodoTaskTime?> _showTaskTimeEditDialog(BuildContext context, TodoTaskTime? currentTaskTime) async {
    TextEditingController daysController = TextEditingController(text: currentTaskTime?.taskTime.inDays.toString() ?? '0');
    TextEditingController hoursController = TextEditingController(text: (currentTaskTime?.taskTime.inHours.remainder(24) ?? 0).toString());
    TextEditingController minutesController = TextEditingController(text: (currentTaskTime?.taskTime.inMinutes.remainder(60) ?? 0).toString());
    TextEditingController secondsController = TextEditingController(text: (currentTaskTime?.taskTime.inSeconds.remainder(60) ?? 0).toString());

    return showDialog<TodoTaskTime?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: daysController, decoration: const InputDecoration(labelText: 'Days'), keyboardType: TextInputType.number),
            TextField(controller: hoursController, decoration: const InputDecoration(labelText: 'Hours'), keyboardType: TextInputType.number),
            TextField(controller: minutesController, decoration: const InputDecoration(labelText: 'Minutes'), keyboardType: TextInputType.number),
            TextField(controller: secondsController, decoration: const InputDecoration(labelText: 'Seconds'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng dialog mà không trả về giá trị (Cancel)
            },
            child: const Text('Cancel'),
          ),
          if (currentTaskTime != null) // Chỉ hiển thị nút xóa nếu có thời gian hiện tại
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(null); // Trả về null để biểu thị xóa
              },
              child: const Text('Remove'),
            ),
          TextButton(
            onPressed: () {
              try {
                final days = int.tryParse(daysController.text) ?? 0;
                final hours = int.tryParse(hoursController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;

                final newTime = TodoTaskTime(days: days, hours: hours, minutes: minutes, seconds: seconds);
                Navigator.of(ctx).pop(newTime);
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Invalid input: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}