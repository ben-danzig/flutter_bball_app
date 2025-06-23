import 'package:flutter/material.dart';

class ActiveDrillLayout extends StatelessWidget {
  final String drillName;
  final String? nextDrillName;
  final Widget child;
  final double progress;

  const ActiveDrillLayout({
    Key? key,
    required this.drillName,
    required this.nextDrillName,
    required this.child,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Top Bar
              Text(
                'UP NEXT: ${nextDrillName ?? "Workout Complete"}',
                style: const TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 2. Main Content (the specific drill widget)
              Expanded(
                child: child,
              ),

              // 3. Bottom Bar
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1f2937),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Pause functionality
                    },
                    child: const Text(
                      '|| PAUSE',
                      style: TextStyle(color: Color(0xFF9ca3af), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Skip functionality
                    },
                    child: const Text(
                      'SKIP >',
                      style: TextStyle(color: Color(0xFF9ca3af), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
