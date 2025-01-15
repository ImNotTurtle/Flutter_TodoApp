import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  DateTimeSelector({
    super.key,
    TimeOfDay? initialTime,
    DateTime? initialDate,
    required this.onTimeSelect,
    required this.onDateSelect,
  }) : initialDate = initialDate ?? DateTime.now(),
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
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.timer_outlined),
          onPressed: () async {
            var newTime = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if(newTime != null){
              setState(() => selectedTime = newTime);
              widget.onTimeSelect(selectedTime);
            }
          },
        ),
        Text(
          '${selectedTime.hour.toString().padLeft(2, '0')}: ${selectedTime.minute.toString().padLeft(2, '0')}',
        ), //pad time with 0 as prefix
        const SizedBox(width: 24),
        IconButton(
          icon: Icon(Icons.calendar_month),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              firstDate: DateTime.parse('1900-01-01'),
              lastDate: DateTime.parse('9999-12-30'),
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
