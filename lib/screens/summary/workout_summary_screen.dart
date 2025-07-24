import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';
import '../../models/drill_result.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';
import 'package:flutter_bball_app/services/workout_session_service.dart';
import 'package:flutter_bball_app/utils/device_id_util.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:provider/provider.dart';
import '../progress/workout_progress_screen.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({Key? key, required this.session}) : super(key: key);

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  WorkoutSession? previousSession;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousSession();
  }

  Future<void> _loadPreviousSession() async {
    try {
      final deviceId = await getDeviceId();
      final allSessions = await WorkoutSessionService.instance.getAllSessions(
        deviceId: deviceId,
      );
      
      // Filter sessions for the same workout blueprint
      final sameBlueprintSessions = allSessions.where((session) => 
        session.workoutBlueprint.id == widget.session.workoutBlueprint.id &&
        session.id != widget.session.id
      ).toList();
      
      // Sort by completion date (most recent first)
      sameBlueprintSessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      
      if (sameBlueprintSessions.isNotEmpty) {
        setState(() {
          previousSession = sameBlueprintSessions.first;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Workout\nComplete!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(widget.session.completedAt),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Results section
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildResultsSection(),
                        const SizedBox(height: 24),
                        _buildTotalTimeSection(),
                      ],
                    ),
            ),
            
            // Done button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  // Navigate to progress page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => WorkoutProgressScreen(
                        currentSession: widget.session,
                        workoutBlueprintId: widget.session.workoutBlueprint.id,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'DONE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESULTS ${previousSession != null ? '(vs. last session)' : ''}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.session.results.map((result) {
          final drill = widget.session.workoutBlueprint.drills
              .firstWhere((d) => d.drillId == result.drillId);
          
          // Find previous result for the same drill
          DrillResult? previousResult;
          if (previousSession != null) {
            try {
              previousResult = previousSession!.results
                  .firstWhere((r) => r.drillId == result.drillId);
            } catch (e) {
              // No previous result for this drill
            }
          }
          
          return _buildResultRow(drill.name, result, drill, previousResult);
        }).toList(),
      ],
    );
  }

  Widget _buildResultRow(String drillName, DrillResult result, dynamic drill, DrillResult? previousResult) {
    String resultText = _formatResult(result, drill);
    String? comparisonText;
    Color? comparisonColor;
    Widget? comparisonWidget;
    
    if (previousResult != null) {
      if (drill.type == 'TIMED') {
        // For timed drills, less time is better
        final diff = (result.elapsedSeconds ?? 0) - (previousResult.elapsedSeconds ?? 0);
        if (diff < 0) {
          comparisonText = '${-diff}s';
          comparisonColor = Colors.green;
        } else if (diff > 0) {
          comparisonText = '+${diff}s';
          comparisonColor = Colors.red;
        }
      } else if (drill.type == 'REP_BASED') {
        // For rep-based drills, more makes is better
        final diff = (result.makes ?? 0) - (previousResult.makes ?? 0);
        if (diff > 0) {
          comparisonText = '+$diff';
          comparisonColor = Colors.green;
        } else if (diff < 0) {
          comparisonText = '$diff';
          comparisonColor = Colors.red;
        }
      } else if (drill.type == 'MAKE_TARGET_TIMED') {
        // For make-target-timed drills, less time is better
        final diff = (result.elapsedSeconds ?? 0) - (previousResult.elapsedSeconds ?? 0);
        if (diff < 0) {
          comparisonText = '${formatDurationVerbose(diff.abs())}';
          comparisonColor = Colors.green;
        } else if (diff > 0) {
          comparisonText = '+${formatDurationVerbose(diff)}';
          comparisonColor = Colors.red;
        }
      }
      
      if (comparisonText != null && comparisonColor != null) {
        comparisonWidget = Text(
          comparisonText,
          style: TextStyle(
            color: comparisonColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            drillName + ':',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              if (comparisonWidget != null) ...[
                comparisonWidget,
                const SizedBox(width: 12),
              ],
              Text(
                resultText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeSection() {
    final totalSeconds = widget.session.results.fold<int>(0, (sum, result) {
      return sum + (result.elapsedSeconds ?? 0);
    });
    
    int? previousTotalSeconds;
    if (previousSession != null) {
      previousTotalSeconds = previousSession!.results.fold<int>(0, (sum, result) {
        return sum + (result.elapsedSeconds ?? 0);
      });
    }
    
    String? comparisonText;
    Color? comparisonColor;
    
    if (previousTotalSeconds != null) {
      final diff = totalSeconds - previousTotalSeconds;
      if (diff < 0) {
        comparisonText = '-${_formatTotalTime(Duration(seconds: -diff))}';
        comparisonColor = Colors.green;
      } else if (diff > 0) {
        comparisonText = '+${_formatTotalTime(Duration(seconds: diff))}';
        comparisonColor = Colors.red;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Time',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Row(
            children: [
              Text(
                _formatTotalTime(Duration(seconds: totalSeconds)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (comparisonText != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: comparisonColor!.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comparisonText,
                    style: TextStyle(
                      color: comparisonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTotalTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  String _formatResult(dynamic result, dynamic drill) {
    if (drill.type == 'TIMED') {
      return '${result.elapsedSeconds}s';
    } else if (drill.type == 'REP_BASED') {
      return '${result.makes} / ${drill.config['targetMakes']}';
    } else if (drill.type == 'MAKE_TARGET_TIMED') {
      return '${formatDurationVerbose(result.elapsedSeconds)}';
    }
    return '';
  }
}
