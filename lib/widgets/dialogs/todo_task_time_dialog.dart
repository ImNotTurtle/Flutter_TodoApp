import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_task_time.dart';

class TodoTaskTimeDialog extends StatelessWidget {
  const TodoTaskTimeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController daysController = TextEditingController();
    final TextEditingController hoursController = TextEditingController();
    final TextEditingController minutesController = TextEditingController();
    final TextEditingController secondsController = TextEditingController();

    return AlertDialog(
      title: const Text(
        "Enter todo task time",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _buildTimeField("Days", daysController)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeField("Hours", hoursController)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTimeField("Minutes", minutesController)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeField("Seconds", secondsController)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            int days = int.tryParse(daysController.text) ?? 0;
            int hours = int.tryParse(hoursController.text) ?? 0;
            int minutes = int.tryParse(minutesController.text) ?? 0;
            int seconds = int.tryParse(secondsController.text) ?? 0;

            Navigator.pop(
              context,
              TodoTaskTime(
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: seconds,
              ),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '0',
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
