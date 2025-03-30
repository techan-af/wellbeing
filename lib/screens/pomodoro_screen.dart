
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:well_being/screens/store_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Timer variables
  int selectedDuration = 25;
  int remainingSeconds = 25 * 60;
  Timer? _timer;
  bool isRunning = false;
  int completedSessions = 0;
  int points = 0;
  int streak = 0;
  DateTime lastSessionDate = DateTime.now().subtract(const Duration(days: 1));
  double constructionProgress = 0.0;

  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Session history
  Map<DateTime, int> sessionHistory = {};

  // Available durations
  final List<int> availableDurations = [15, 25, 30, 45, 50, 60];

  // House parts
  final List<String> houseParts = [
    'assets/house/foundation.svg',
    'assets/house/walls.svg',
    'assets/house/roof.svg',
    'assets/house/windows.svg',
    'assets/house/doors.svg',
  ];

  // Color scheme
  final Color primaryColor = const Color(0xFF6C5CE7);
  final Color secondaryColor = const Color(0xFF00CEFF);
  final Color accentColor = const Color(0xFFFD79A8);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color textColor = const Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSessionData();
    _verifyAssets();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyAssets() async {
    for (var asset in houseParts) {
      try {
        await rootBundle.load(asset);
        print('Asset loaded: $asset');
      } catch (e) {
        print('Failed to load asset: $asset');
        print('Error: $e');
      }
    }
    try {
      await rootBundle.load('assets/house/empty_lot.svg');
      print('Asset loaded: assets/house/empty_lot.svg');
    } catch (e) {
      print('Failed to load asset: assets/house/empty_lot.svg');
      print('Error: $e');
    }
  }

  Future<void> _loadSessionData() async {
    setState(() {
      // Simulate some completed sessions for the current month
      final now = DateTime.now();
      for (int i = 1; i <= now.day; i++) {
        if (i % 2 == 0) {
          sessionHistory[DateTime(now.year, now.month, i)] = i % 3 + 1;
        }
      }
      _calculateStreak();
    });
  }

  Widget _buildHouseConstruction() {
    return Column(
      children: [
        Text(
          'Building Your House: ${(constructionProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: Stack(
            children: [
              // Background (empty lot)
              _buildSvgAsset('assets/house/empty_lot.svg'),
              
              // Foundation - appears at 20% and fully visible by 40%
              _buildHousePart(0, 0.2, 0.4),
              
              // Walls - appears at 40% and fully visible by 60%
              _buildHousePart(1, 0.4, 0.6),
              
              // Roof - appears at 60% and fully visible by 80%
              _buildHousePart(2, 0.6, 0.8),
              
              // Windows - appears at 80% and fully visible by 100%
              _buildHousePart(3, 0.8, 1.0),
              
              // Doors - appears at 90% and fully visible by 100%
              _buildHousePart(4, 0.9, 1.0),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: constructionProgress,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildHousePart(int partIndex, double appearAt, double fullyVisibleAt) {
    if (constructionProgress < appearAt) return SizedBox.shrink();
    
    double opacity = ((constructionProgress - appearAt) / (fullyVisibleAt - appearAt)).clamp(0.0, 1.0);
    
    return Opacity(
      opacity: opacity,
      child: _buildSvgAsset(houseParts[partIndex]),
    );
  }

  Widget _buildSvgAsset(String path) {
    try {
      return SvgPicture.asset(
        path,
        placeholderBuilder: (context) => Container(
          color: Colors.grey[200],
          child: Center(child: Text('Loading...')),
        ),
      );
    } catch (e) {
      print('Error loading SVG: $path - $e');
      return Container(
        color: Colors.red[100],
        child: Center(child: Text('Missing asset')),
      );
    }
  }

  void _calculateStreak() {
    DateTime currentDate = DateTime.now();
    int tempStreak = 0;
    
    DateTime checkDate = currentDate.subtract(const Duration(days: 1));
    while (sessionHistory.containsKey(DateTime(checkDate.year, checkDate.month, checkDate.day))) {
      tempStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    if (sessionHistory.containsKey(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
      tempStreak++;
    }
    
    setState(() {
      streak = tempStreak;
    });
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);
    
    final totalSeconds = selectedDuration * 60;
    final updateInterval = 1; // Update every second
    
    _timer = Timer.periodic(Duration(seconds: updateInterval), (timer) async {
      if (remainingSeconds <= 0) {
        timer.cancel();
        _completeSession();
      } else {
        setState(() {
          remainingSeconds--;
          constructionProgress = 1 - (remainingSeconds / totalSeconds);
        });
      }
    });
  }

  void _completeSession() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int sessionPoints = (selectedDuration ~/ 5) * 10;
    
    if (streak > 0) {
      sessionPoints += (streak * 5);
    }
    
    setState(() {
      isRunning = false;
      completedSessions++;
      points += sessionPoints;
      sessionHistory[today] = (sessionHistory[today] ?? 0) + 1;
      
      if (!isSameDay(lastSessionDate, now)) {
        if (lastSessionDate.isAfter(now.subtract(const Duration(days: 1)))) {
          streak++;
        } else {
          streak = 1;
        }
        lastSessionDate = now;
      }
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Session Complete!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You earned $sessionPoints points!"),
            const SizedBox(height: 10),
            Text("Current streak: $streak day${streak != 1 ? 's' : ''}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      selectedDuration = minutes;
      remainingSeconds = minutes * 60;
      isRunning = false;
      constructionProgress = 0.0;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    int count = sessionHistory[dateKey] ?? 0;
    if (count > 0) return [count];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Focus Timer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, size: 28),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoreScreen(points: points)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildHouseConstruction(),
              const SizedBox(height: 24),
              _buildTimerCircle(),
              const SizedBox(height: 24),
              _buildDurationSelector(),
              const SizedBox(height: 24),
              _buildControlButtons(),
              const SizedBox(height: 24),
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.8), secondaryColor.withOpacity(0.8)],
        ),
      ),
      child: Center(
        child: Text(
          formatTime(remainingSeconds),
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard("Sessions", completedSessions.toString(), Icons.timer_outlined),
          _buildStatCard("Streak", "$streak", Icons.local_fire_department_outlined),
          _buildStatCard("Points", "$points", Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Session Duration",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableDurations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final duration = availableDurations[index];
                  return ChoiceChip(
                    label: Text(
                      "$duration min",
                      style: TextStyle(
                        color: selectedDuration == duration 
                            ? Colors.white 
                            : primaryColor,
                      ),
                    ),
                    selected: selectedDuration == duration,
                    onSelected: (selected) {
                      if (selected) resetTimer(duration);
                    },
                    selectedColor: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryColor,
                inactiveTrackColor: primaryColor.withOpacity(0.2),
                thumbColor: primaryColor,
                overlayColor: primaryColor.withOpacity(0.1),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackHeight: 4,
              ),
              child: Slider(
                value: selectedDuration.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: "$selectedDuration minutes",
                onChanged: (value) {
                  setState(() {
                    selectedDuration = value.round();
                    remainingSeconds = selectedDuration * 60;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (!isRunning)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Changed from primary
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.play_arrow, size: 24),
              SizedBox(width: 8),
              Text("Start", style: TextStyle(fontSize: 16)),
            ],
          ),
          onPressed: startTimer,
        ),
      if (isRunning)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor, // Changed from primary
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.pause, size: 24),
              SizedBox(width: 8),
              Text("Pause", style: TextStyle(fontSize: 16)),
            ],
          ),
          onPressed: pauseTimer,
        ),
      const SizedBox(width: 16),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor, // Changed from primary
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.refresh, size: 24),
            SizedBox(width: 8),
            Text("Reset", style: TextStyle(fontSize: 16)),
          ],
        ),
        onPressed: () => resetTimer(selectedDuration),
      ),
    ],
  );
}

  Widget _buildCalendar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Your Focus History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
              lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
                defaultTextStyle: TextStyle(color: textColor),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    int count = events.first as int;
                    Color markerColor;
                    if (count == 1) {
                      markerColor = Colors.lightGreen.shade300;
                    } else if (count == 2) {
                      markerColor = Colors.green.shade400;
                    } else if (count >= 3) {
                      markerColor = Colors.green.shade700;
                    } else {
                      markerColor = Colors.green.shade100;
                    }
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: markerColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 10, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
