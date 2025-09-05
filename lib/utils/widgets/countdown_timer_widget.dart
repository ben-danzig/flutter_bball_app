import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onComplete;
  final Function(int)? onTick;
  final bool isPaused;
  final VoidCallback? onTogglePause;
  final bool showTapToEdit;
  final Function(int)? onTimeEdit;
  final String? title;
  final String? subtitle;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;

  const CountdownTimerWidget({
    super.key,
    required this.durationSeconds,
    this.onComplete,
    this.onTick,
    this.isPaused = false,
    this.onTogglePause,
    this.showTapToEdit = false,
    this.onTimeEdit,
    this.title,
    this.subtitle,
    this.fontSize = 300,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.transparent,
  });

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationSeconds != widget.durationSeconds) {
      _timer.cancel();
      setState(() {
        _remainingSeconds = widget.durationSeconds;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.isPaused) {
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        widget.onTick?.call(_remainingSeconds);
      } else {
        _timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf9fafb),
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: widget.showTapToEdit && widget.onTimeEdit != null
                    ? () async {
                        // Show time picker dialog
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => _TimePickerDialog(
                            initialSeconds: _remainingSeconds,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _remainingSeconds = result;
                          });
                          widget.onTimeEdit?.call(result);
                        }
                      }
                    : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatDuration(_remainingSeconds),
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w900,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 30),
            Text(
              widget.subtitle!,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF9ca3af),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePickerDialog extends StatefulWidget {
  final int initialSeconds;

  const _TimePickerDialog({required this.initialSeconds});

  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialSeconds ~/ 60;
    _seconds = widget.initialSeconds % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1f2937),
      title: const Text(
        'Edit Time',
        style: TextStyle(color: Colors.white),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Minutes',
                style: TextStyle(color: Color(0xFF9ca3af)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_minutes > 0) _minutes--;
                      });
                    },
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Text(
                    '$_minutes',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _minutes++;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seconds',
                style: TextStyle(color: Color(0xFF9ca3af)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_seconds > 0) {
                          _seconds--;
                        } else {
                          _seconds = 59;
                          if (_minutes > 0) _minutes--;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Text(
                    _seconds.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_seconds < 59) {
                          _seconds++;
                        } else {
                          _seconds = 0;
                          _minutes++;
                        }
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF9ca3af)),
          ),
        ),
        TextButton(
          onPressed: () {
            final totalSeconds = _minutes * 60 + _seconds;
            Navigator.of(context).pop(totalSeconds);
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Color(0xFF3b82f6)),
          ),
        ),
      ],
    );
  }
} 