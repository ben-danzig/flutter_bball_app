import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('Workout Summary'),
        backgroundColor: const Color(0xFF1f2937),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildResultsCard(),
          const SizedBox(height: 16),
          if (session.feeling != null || (session.notes != null && session.notes!.isNotEmpty))
            _buildFeelingCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Workout Complete!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat.yMMMMd().add_jm().format(session.completedAt),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Workout', session.workoutBlueprint.name),
          const Divider(color: Colors.grey),
          _buildInfoRow('Total Time', _formatTotalTime()),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESULTS',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...session.results.map((result) {
            final drill = session.workoutBlueprint.drills
                .firstWhere((d) => d.drillId == result.drillId);
            return _buildInfoRow(drill.name, _formatResult(result, drill));
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeelingCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.feeling != null)
            _buildInfoRow('Feeling', session.feeling!),
          if (session.feeling != null && (session.notes != null && session.notes!.isNotEmpty))
            const Divider(color: Colors.grey),
          if (session.notes != null && session.notes!.isNotEmpty)
            _buildInfoRow('Notes', session.notes!),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTotalTime() {
    final totalSeconds = session.results.fold<int>(0, (sum, result) {
      return sum + (result.elapsedSeconds ?? 0);
    });
    final duration = Duration(seconds: totalSeconds);
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
      return '${result.makes} makes in ${_formatDuration(result.elapsedSeconds)}';
    }
    return '';
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }
}
