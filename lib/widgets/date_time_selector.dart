import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  DateTimeSelector({
    super.key,
    TimeOfDay? initialTime,
    DateTime? initialDate,
    required this.onTimeSelect,
    required this.onDateSelect,
  })  : initialDate = initialDate ?? DateTime.now(),
        initialTime = initialTime ?? TimeOfDay.now();

  final TimeOfDay initialTime;
  final DateTime initialDate;
  final void Function(TimeOfDay) onTimeSelect;
  final void Function(DateTime) onDateSelect;

  @override
  State<DateTimeSelector> createState() {
    return _DateTimeSelectorState();
  }
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  late TimeOfDay selectedTime;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        IconButton(
          icon: const Icon(Icons.timer_outlined),
          onPressed: () async {
            var newTime = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (newTime != null) {
              setState(() => selectedTime = newTime);
              widget.onTimeSelect(selectedTime);
            }
          },
        ),
        Text(
          selectedTime.format(context),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              initialDate: selectedDate,
            );
            if (newDate != null) {
              setState(() => selectedDate = newDate);
              widget.onDateSelect(selectedDate);
            }
          },
        ),
        Text(DateFormat('dd/MM/yy').format(selectedDate)),
      ],
    );
  }
}