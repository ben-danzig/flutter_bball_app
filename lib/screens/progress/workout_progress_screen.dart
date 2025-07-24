import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';
import '../../models/drill_result.dart';
import '../../models/drill.dart';
import 'package:flutter_bball_app/services/workout_session_service.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';
import 'package:flutter_bball_app/utils/device_id_util.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/auth_service.dart'; // Added import for AuthService
import 'package:provider/provider.dart';

class WorkoutProgressScreen extends StatefulWidget {
  final WorkoutSession currentSession;
  final String workoutBlueprintId;

  const WorkoutProgressScreen({
    Key? key,
    required this.currentSession,
    required this.workoutBlueprintId,
  }) : super(key: key);

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  List<WorkoutSession> historicalSessions = [];
  bool isLoading = true;
  int selectedDrillIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final allSessions = await WorkoutSessionService.instance.getAllSessions(
        userId: userId,
      );
      
      // Filter sessions for the same workout blueprint
      final sameBlueprintSessions = allSessions.where((session) => 
        session.workoutBlueprint.id == widget.workoutBlueprintId
      ).toList();
      
      // Sort by completion date (oldest first for chart display)
      sameBlueprintSessions.sort((a, b) => a.completedAt.compareTo(b.completedAt));
      
      // Limit to last 10 sessions for better visualization
      if (sameBlueprintSessions.length > 10) {
        historicalSessions = sameBlueprintSessions.sublist(sameBlueprintSessions.length - 10);
      } else {
        historicalSessions = sameBlueprintSessions;
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentSession.workoutBlueprint.drills.isEmpty) {
      return _buildEmptyState();
    }

    final selectedDrill = widget.currentSession.workoutBlueprint.drills[selectedDrillIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                  const Expanded(
                    child: Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Drill selector
                        _buildDrillSelector(),
                        const SizedBox(height: 20),
                        
                        // Chart section
                        Expanded(
                          child: _buildChart(selectedDrill),
                        ),
                        
                        // Improvement summary
                        _buildImprovementSummary(selectedDrill),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.show_chart,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No data to display',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.currentSession.workoutBlueprint.drills.length,
        itemBuilder: (context, index) {
          final drill = widget.currentSession.workoutBlueprint.drills[index];
          final isSelected = index == selectedDrillIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDrillIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1f2937),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  drill.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(Drill drill) {
    final chartData = _getChartData(drill);
    
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          'Not enough data to show trends',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            drill.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _getChartSubtitle(drill),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _getLeftAxisLabel(value, drill),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                          final session = historicalSessions[value.toInt()];
                          return Text(
                            DateFormat('M/d').format(session.completedAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF3B82F6),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1f2937),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final session = historicalSessions[spot.x.toInt()];
                        return LineTooltipItem(
                          '${_getTooltipValue(spot.y, drill)}\n${DateFormat.MMMd().format(session.completedAt)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSummary(Drill drill) {
    if (historicalSessions.length < 2) {
      return const SizedBox.shrink();
    }

    final improvement = _calculateImprovement(drill);
    final improvementText = _getImprovementText(improvement, drill);
    final isPositive = _isPositiveImprovement(improvement, drill);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                improvementText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'over the last month',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartData(Drill drill) {
    final List<FlSpot> spots = [];
    
    for (int i = 0; i < historicalSessions.length; i++) {
      final session = historicalSessions[i];
      final result = session.results.firstWhere(
        (r) => r.drillId == drill.drillId,
        orElse: () => DrillResult(drillId: drill.drillId),
      );
      
      double value = 0;
      if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
        value = (result.elapsedSeconds ?? 0).toDouble();
      } else if (drill.type == 'REP_BASED') {
        value = (result.makes ?? 0).toDouble();
      }
      
      if (value > 0) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }
    
    return spots;
  }

  String _getChartSubtitle(Drill drill) {
    if (drill.type == 'TIMED') {
      return 'Time to Complete';
    } else if (drill.type == 'REP_BASED') {
      return 'Shots Made';
    } else if (drill.type == 'MAKE_TARGET_TIMED') {
      return 'Time to ${drill.config['targetMakes']} Makes';
    }
    return '';
  }

  String _getLeftAxisLabel(double value, Drill drill) {
    if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
      final minutes = value ~/ 60;
      final seconds = (value % 60).toInt();
      return '${minutes}m ${seconds}s';
    } else if (drill.type == 'REP_BASED') {
      return value.toInt().toString();
    }
    return '';
  }

  String _getTooltipValue(double value, Drill drill) {
    if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
      return formatDurationVerbose(value.toInt());
    } else if (drill.type == 'REP_BASED') {
      return '${value.toInt()} makes';
    }
    return '';
  }

  double _calculateImprovement(Drill drill) {
    if (historicalSessions.length < 2) return 0;
    
    final oldSession = historicalSessions.first;
    final newSession = historicalSessions.last;
    
    final oldResult = oldSession.results.firstWhere(
      (r) => r.drillId == drill.drillId,
      orElse: () => DrillResult(drillId: drill.drillId),
    );
    
    final newResult = newSession.results.firstWhere(
      (r) => r.drillId == drill.drillId,
      orElse: () => DrillResult(drillId: drill.drillId),
    );
    
    if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
      final oldTime = oldResult.elapsedSeconds ?? 0;
      final newTime = newResult.elapsedSeconds ?? 0;
      if (oldTime == 0 || newTime == 0) return 0.0;
      return (oldTime - newTime).toDouble();
    } else if (drill.type == 'REP_BASED') {
      final oldMakes = oldResult.makes ?? 0;
      final newMakes = newResult.makes ?? 0;
      return (newMakes - oldMakes).toDouble();
    }
    
    return 0;
  }

  String _getImprovementText(double improvement, Drill drill) {
    if (improvement == 0) {
      return 'No change';
    }
    
    if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
      final absImprovement = improvement.abs();
      return 'Your time has ${improvement > 0 ? 'improved' : 'increased'} by ${absImprovement.toInt()} seconds';
    } else if (drill.type == 'REP_BASED') {
      final absImprovement = improvement.abs().toInt();
      return 'Your makes have ${improvement > 0 ? 'increased' : 'decreased'} by $absImprovement';
    }
    
    return '';
  }

  bool _isPositiveImprovement(double improvement, Drill drill) {
    if (drill.type == 'TIMED' || drill.type == 'MAKE_TARGET_TIMED') {
      // For timed drills, positive improvement means less time (improvement > 0)
      return improvement > 0;
    } else if (drill.type == 'REP_BASED') {
      // For rep-based drills, positive improvement means more makes
      return improvement > 0;
    }
    return false;
  }
}