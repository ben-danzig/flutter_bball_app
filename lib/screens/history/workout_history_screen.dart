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
  bool _selectionMode = false;
  Set<String> _selectedSessionIds = {};

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
    setState(() {
      _selectionMode = false;
      _selectedSessionIds.clear();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) _selectedSessionIds.clear();
    });
  }

  void _onSessionLongPress(String sessionId) {
    if (!_selectionMode) {
      setState(() {
        _selectionMode = true;
        _selectedSessionIds.add(sessionId);
      });
    }
  }

  void _onSessionCheckboxChanged(String sessionId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedSessionIds.add(sessionId);
      } else {
        _selectedSessionIds.remove(sessionId);
      }
    });
  }

  Future<void> _claimSelectedSessions() async {
    final deviceId = await getDeviceId();
    final sessions = await _sessionsFuture;
    final toClaim = sessions.where((s) => _selectedSessionIds.contains(s.id)).toList();
    for (final session in toClaim) {
      final claimedSession = WorkoutSession(
        id: session.id,
        workoutBlueprint: session.workoutBlueprint,
        results: session.results,
        completedAt: session.completedAt,
        feeling: session.feeling,
        notes: session.notes,
        isPartial: session.isPartial,
        deviceId: deviceId,
      );
      await WorkoutSessionService.instance.updateSession(claimedSession);
    }
    _refreshSessions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claimed ${toClaim.length} session(s) for this device')),
      );
    }
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

    String? action;
    final result = await showDialog<String>(
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
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('save'),
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('claim'),
              child: const Text('Claim for current device', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (result == 'save') {
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
    } else if (result == 'claim') {
      final deviceId = await getDeviceId();
      final claimedSession = WorkoutSession(
        id: session.id,
        workoutBlueprint: session.workoutBlueprint,
        results: session.results,
        completedAt: session.completedAt,
        feeling: session.feeling,
        notes: session.notes,
        isPartial: session.isPartial,
        deviceId: deviceId,
      );
      await WorkoutSessionService.instance.updateSession(claimedSession);
      _refreshSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session claimed for this device')),
        );
      }
    }
  }

  Future<void> _deleteSelectedSessions() async {
    final count = _selectedSessionIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text('Delete Sessions', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete $count selected session(s)?', style: const TextStyle(color: Colors.white70)),
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
      ),
    );
    if (confirm == true) {
      for (final sessionId in _selectedSessionIds) {
        await WorkoutSessionService.instance.deleteSession(sessionId);
      }
      _refreshSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted $count session(s)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(_selectionMode ? 'Select Sessions' : 'History'),
        backgroundColor: const Color(0xFF1f2937),
        elevation: 0,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: 'Cancel',
            )
          else
            IconButton(
              icon: const Icon(Icons.check_box),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select',
            ),
        ],
      ),
      body: FutureBuilder<List<WorkoutSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error:  [${snapshot.error}',
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
                final isSelected = _selectedSessionIds.contains(session.id);
                return GestureDetector(
                  onLongPress: () => _onSessionLongPress(session.id),
                  child: _buildHistoryCard(context, session, isSelected),
                );
              },
            );
          }
          return const Center(
              child: Text('No workouts found.',
                  style: TextStyle(color: Colors.white)));
        },
      ),
      floatingActionButton: _selectionMode && _selectedSessionIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedSessions,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Selected'),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutSession session, bool isSelected) {
    final totalTime = session.results.fold<int>(0, (sum, result) {
      return sum + (result.elapsedSeconds ?? 0);
    });
    final duration = Duration(seconds: totalTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return Card(
      color: isSelected ? const Color(0xFF2563eb) : const Color(0xFF1f2937),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? const Color(0xFF60a5fa) : const Color(0xFF4b5563)),
      ),
      child: ListTile(
        leading: _selectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (selected) => _onSessionCheckboxChanged(session.id, selected),
                activeColor: Colors.green,
              )
            : null,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          session.workoutBlueprint.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d, y - h:mma').format(session.completedAt).replaceAll('AM', 'am').replaceAll('PM', 'pm'),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            if (session.notes != null && session.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  session.notes!,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            Text(
              '${minutes}m ${seconds}s',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        onTap: _selectionMode
            ? () => _onSessionCheckboxChanged(session.id, !isSelected)
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSummaryScreen(session: session),
                  ),
                );
              },
        trailing: !_selectionMode
            ? PopupMenuButton<String>(
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
                onSelected: (value) async {
                  if (value == 'edit') {
                    _editSession(session);
                  } else if (value == 'delete') {
                    _deleteSession(session);
                  }
                },
              )
            : null,
      ),
    );
  }
}
