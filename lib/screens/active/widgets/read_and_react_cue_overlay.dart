import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../models/cue_action.dart';

class ReadAndReactCueOverlay extends StatefulWidget {
  final CueAction cue;

  const ReadAndReactCueOverlay({super.key, required this.cue});

  @override
  State<ReadAndReactCueOverlay> createState() => _ReadAndReactCueOverlayState();
}

class _ReadAndReactCueOverlayState extends State<ReadAndReactCueOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cue = widget.cue;
    final backgroundColor = cue.color ?? Colors.black;
    Widget content;

    if (cue.icon != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              cue.label,
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.w900,
                color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            cue.icon,
            size: 100,
            color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ],
      );
    } else {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          cue.label,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            letterSpacing: 2,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => true, // Allow back navigation
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: content),
      ),
    );
  }
} 