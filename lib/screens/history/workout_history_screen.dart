import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';
import '../../services/storage_service.dart';
import '../summary/workout_summary_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = StorageService.instance.getAllSessions();
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
      ),
    );
  }
}
