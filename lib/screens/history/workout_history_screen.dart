import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';
import '../../services/workout_session_service.dart';
import '../summary/workout_summary_screen.dart';
import 'package:flutter_bball_app/utils/device_id_util.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:provider/provider.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  Future<List<WorkoutSession>> _sessionsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final deviceId = await getDeviceId();
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final loadUnknown = settingsService.loadUnknownDeviceSessions;
    setState(() {
      _sessionsFuture = WorkoutSessionService.instance.getAllSessions(
        deviceId: deviceId,
        loadUnknownDeviceSessions: loadUnknown,
      );
    });
  }

  void _refreshSessions() {
    _loadSessions();
  }

  Future<void> _deleteSession(WorkoutSession session) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          title: const Text('Delete Workout', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete "${session.workoutBlueprint.name}" from ${DateFormat.yMMMMd().format(session.completedAt)}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await WorkoutSessionService.instance.deleteSession(session.id);
      _refreshSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
      }
    }
  }

  Future<void> _editSession(WorkoutSession session) async {
    final feelingController = TextEditingController(text: session.feeling ?? '');
    final notesController = TextEditingController(text: session.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          title: const Text('Edit Workout', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.workoutBlueprint.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat.yMMMMd().format(session.completedAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feelingController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'How did you feel?',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final updatedSession = WorkoutSession(
        id: session.id,
        workoutBlueprint: session.workoutBlueprint,
        results: session.results,
        completedAt: session.completedAt,
        feeling: feelingController.text.isEmpty ? null : feelingController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
        isPartial: session.isPartial, 
        deviceId: session.deviceId,
      );
      
      await WorkoutSessionService.instance.updateSession(updatedSession);
      _refreshSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout updated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF1f2937),
        elevation: 0,
      ),
      body: FutureBuilder<List<WorkoutSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final sessions = snapshot.data!;
            // Sort sessions by date, most recent first
            sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildHistoryCard(context, session);
              },
            );
          }
          return const Center(
              child: Text('No workouts found.',
                  style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutSession session) {
    final totalTime = session.results.fold<int>(0, (sum, result) {
      return sum + (result.elapsedSeconds ?? 0);
    });
    final duration = Duration(seconds: totalTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return Card(
      color: const Color(0xFF1f2937),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4b5563)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          session.workoutBlueprint.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          '${DateFormat.yMMMMd().format(session.completedAt)}\n${minutes}m ${seconds}s',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutSummaryScreen(session: session),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF374151),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editSession(session);
            } else if (value == 'delete') {
              _deleteSession(session);
            }
          },
        ),
      ),
    );
  }
}
