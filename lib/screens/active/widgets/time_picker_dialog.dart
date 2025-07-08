import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePickerDialog extends StatefulWidget {
  final int initialSeconds;
  const TimePickerDialog({Key? key, required this.initialSeconds}) : super(key: key);

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    minutes = widget.initialSeconds ~/ 60;
    seconds = (widget.initialSeconds % 60) ~/ 5 * 5;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1f2937),
      title: const Text('Set Timer', style: TextStyle(color: Colors.white)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumberPicker(
            value: minutes,
            minValue: 0,
            maxValue: 59,
            zeroPad: true,
            itemHeight: 60,
            onChanged: (value) => setState(() => minutes = value),
            textStyle: const TextStyle(color: Colors.white54, fontSize: 32),
            selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text(':', style: TextStyle(color: Colors.white, fontSize: 48)),
          NumberPicker(
            value: seconds,
            minValue: 0,
            maxValue: 55,
            step: 5,
            zeroPad: true,
            itemHeight: 60,
            onChanged: (value) => setState(() => seconds = value),
            textStyle: const TextStyle(color: Colors.white54, fontSize: 32),
            selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF9ca3af))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(minutes * 60 + seconds);
          },
          child: const Text('Set', style: TextStyle(color: Color(0xFF3b82f6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
} 