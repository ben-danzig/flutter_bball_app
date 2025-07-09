import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ReadAndReactCueOverlay extends StatefulWidget {
  final String direction;

  const ReadAndReactCueOverlay({Key? key, required this.direction}) : super(key: key);

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
    Color backgroundColor;
    Widget content;

    switch (widget.direction) {
      case 'SHOOT':
        backgroundColor = const Color(0xFF10B981); // Green
        content = const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SHOOT',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        );
        break;
      case 'DRIVE_LEFT':
        backgroundColor = const Color(0xFFEAB308); // Yellow/Orange
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'DRIVE',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.arrow_back,
              size: 100,
              color: Colors.black,
            ),
          ],
        );
        break;
      case 'DRIVE_RIGHT':
        backgroundColor = const Color(0xFFEAB308); // Yellow/Orange
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'DRIVE',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.arrow_forward,
              size: 100,
              color: Colors.black,
            ),
          ],
        );
        break;
      default:
        backgroundColor = Colors.black;
        content = const SizedBox.shrink();
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