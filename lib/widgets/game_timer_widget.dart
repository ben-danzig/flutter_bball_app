import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_timer_service.dart';
import '../utils/format_duration.dart';

/// Example widget demonstrating how to use the GameTimerService.
/// 
/// This widget displays a countdown timer with controls for starting,
/// pausing, resuming, and resetting the timer.
class GameTimerWidget extends StatefulWidget {
  final int initialDuration;
  final Function()? onTimerComplete;

  const GameTimerWidget({
    Key? key,
    this.initialDuration = 300, // Default 5 minutes
    this.onTimerComplete,
  }) : super(key: key);

  @override
  State<GameTimerWidget> createState() => _GameTimerWidgetState();
}

class _GameTimerWidgetState extends State<GameTimerWidget> {
  late final GameTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = GameTimerService();
    
    // Register completion callback if provided
    if (widget.onTimerComplete != null) {
      _timerService.onTimerComplete(widget.onTimerComplete!);
    }
    
    // Also show a default completion message
    _timerService.onTimerComplete(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time is up!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameTimerService>.value(
      value: _timerService,
      child: Consumer<GameTimerService>(
        builder: (context, timer, child) {
          return Card(
            elevation: 4,
            color: const Color(0xFF1f2937),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME TIMER',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Timer Display
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: timer.isRunning() 
                            ? Colors.greenAccent 
                            : Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                    ),
                    child: Text(
                      formatDuration(timer.getTimeRemaining()),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: timer.getTimeRemaining() <= 10 
                            ? Colors.redAccent 
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Control Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      if (!timer.isRunning() && timer.getTimeRemaining() == widget.initialDuration)
                        _buildControlButton(
                          onPressed: () => timer.startTimer(widget.initialDuration),
                          icon: Icons.play_arrow,
                          label: 'START',
                          color: Colors.green,
                        ),
                      if (timer.isRunning())
                        _buildControlButton(
                          onPressed: () => timer.pauseTimer(),
                          icon: Icons.pause,
                          label: 'PAUSE',
                          color: Colors.orange,
                        ),
                      if (!timer.isRunning() && timer.getTimeRemaining() < widget.initialDuration && timer.getTimeRemaining() > 0)
                        _buildControlButton(
                          onPressed: () => timer.resumeTimer(),
                          icon: Icons.play_arrow,
                          label: 'RESUME',
                          color: Colors.green,
                        ),
                      _buildControlButton(
                        onPressed: () => timer.resetTimer(widget.initialDuration),
                        icon: Icons.refresh,
                        label: 'RESET',
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                  if (timer.getElapsedSeconds() > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Elapsed: ${formatDuration(timer.getElapsedSeconds())}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Alternative compact timer widget for use in app bars or smaller spaces
class CompactGameTimerWidget extends StatelessWidget {
  final GameTimerService timerService;

  const CompactGameTimerWidget({
    Key? key,
    required this.timerService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timerService.timerStream,
      initialData: timerService.getTimeRemaining(),
      builder: (context, snapshot) {
        final remainingSeconds = snapshot.data ?? 0;
        final isWarning = remainingSeconds <= 10 && remainingSeconds > 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isWarning ? Colors.red.withOpacity(0.2) : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWarning ? Colors.redAccent : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                timerService.isRunning() ? Icons.timer : Icons.timer_off,
                color: isWarning ? Colors.redAccent : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                formatDuration(remainingSeconds),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}