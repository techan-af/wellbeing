// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// class PomodoroScreen extends StatefulWidget {
//   const PomodoroScreen({Key? key}) : super(key: key);

//   @override
//   _PomodoroScreenState createState() => _PomodoroScreenState();
// }

// class _PomodoroScreenState extends State<PomodoroScreen> {
//   // Timer variables (in seconds).
//   int selectedDuration = 25 * 60;
//   int remainingSeconds = 25 * 60;
//   Timer? _timer;
//   bool isRunning = false;

//   // Simulated pomodoro completions for each day (keyed by day number) for current month.
//   Map<int, int> dailyPomodoros = {};

//   // TableCalendar state.
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = _focusedDay;
//     generatePomodoroData();
//   }

//   /// Generate simulated pomodoro data for the current month.
//   void generatePomodoroData() {
//     final now = DateTime.now();
//     int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
//     setState(() {
//       dailyPomodoros = {
//         for (int day = 1; day <= daysInMonth; day++) day: day % 4,
//       };
//     });
//   }

//   Future<bool> checkIfStudying() async {
//   try {
//     final response = await http.get(Uri.parse("http://192.168.1.10:5000/status"));
//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       return data["is_studying"];
//     }
//   } catch (e) {
//     print("Error: $e");
//   }
//   return false;
// }

//   // Timer functions.
//   void startTimer() {
//   if (isRunning) return;
//   setState(() => isRunning = true);

//   _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//     if (remainingSeconds <= 0) {
//       timer.cancel();
//       setState(() => isRunning = false);
//     } else {
//       setState(() => remainingSeconds--);
      
//       // Check if student is studying
//       bool studying = await checkIfStudying();
//       if (!studying) {
//         print("⚠️ Student is distracted!");
//         // You can show a notification here
//       }
//     }
//   });
// }

//   void pauseTimer() {
//     _timer?.cancel();
//     setState(() => isRunning = false);
//   }

//   void resetTimer(int minutes) {
//     _timer?.cancel();
//     setState(() {
//       selectedDuration = minutes * 60;
//       remainingSeconds = minutes * 60;
//       isRunning = false;
//     });
//   }

//   /// Format seconds as mm:ss.
//   String formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final secs = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }

//   /// Returns the events for a given day.
//   List<dynamic> _getEventsForDay(DateTime day) {
//     // Only show events for the current month/year.
//     if (day.month != DateTime.now().month || day.year != DateTime.now().year) {
//       return [];
//     }
//     int count = dailyPomodoros[day.day] ?? 0;
//     if (count > 0) return [count];
//     return [];
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
    
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pomodoro Timer & Shop'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Timer display.
//               Text(
//                 formatTime(remainingSeconds),
//                 style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               // Duration selection.
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ChoiceChip(
//                     label: const Text("25 Minutes"),
//                     selected: selectedDuration == 25 * 60,
//                     onSelected: (selected) {
//                       if (selected) resetTimer(25);
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   ChoiceChip(
//                     label: const Text("50 Minutes"),
//                     selected: selectedDuration == 50 * 60,
//                     onSelected: (selected) {
//                       if (selected) resetTimer(50);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               // Play/Pause button.
//               IconButton(
//                 iconSize: 70,
//                 icon: Icon(
//                   isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
//                   color: Colors.blue,
//                 ),
//                 onPressed: () => isRunning ? pauseTimer() : startTimer(),
//               ),
//               const SizedBox(height: 30),
//               // Calendar using TableCalendar.
//               TableCalendar(
//                 firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
//                 lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day + 31),
//                 focusedDay: _focusedDay,
//                 selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                 eventLoader: _getEventsForDay,
//                 calendarFormat: CalendarFormat.month,
//                 headerStyle: const HeaderStyle(
//                   formatButtonVisible: false,
//                   titleCentered: true,
//                 ),
//                 calendarStyle: const CalendarStyle(
//                   todayDecoration: BoxDecoration(
//                     color: Colors.orange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 onDaySelected: (selectedDay, focusedDay) {
//                   setState(() {
//                     _selectedDay = selectedDay;
//                     _focusedDay = focusedDay;
//                   });
//                 },
//                 // Custom markers based on pomodoro count.
//                 calendarBuilders: CalendarBuilders(
//                   markerBuilder: (context, day, events) {
//                     if (events.isNotEmpty) {
//                       int count = events.first as int;
//                       Color markerColor;
//                       if (count == 1) {
//                         markerColor = Colors.lightBlue.shade200;
//                       } else if (count == 2) {
//                         markerColor = Colors.lightBlue.shade400;
//                       } else if (count >= 3) {
//                         markerColor = Colors.lightBlue.shade700;
//                       } else {
//                         markerColor = Colors.lightBlue.shade50;
//                       }
//                       return Positioned(
//                         bottom: 1,
//                         child: Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: markerColor,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               count.toString(),
//                               style: const TextStyle(fontSize: 10, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                     return const SizedBox();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Session history
  Map<DateTime, int> sessionHistory = {};

  // Available durations
  final List<int> availableDurations = [15, 25, 30, 45, 50, 60];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSessionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<bool> checkIfStudying() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.10:5000/status"));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data["is_studying"];
      }
    } catch (e) {
      print("Error: $e");
    }
    return false;
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds <= 0) {
        timer.cancel();
        _completeSession();
      } else {
        setState(() => remainingSeconds--);
        
        bool studying = await checkIfStudying();
        if (!studying) {
          print("⚠️ Student is distracted!");
        }
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
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$points', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStatsRow(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildDurationSelector(),
              const SizedBox(height: 30),
              _buildControlButtons(),
              const SizedBox(height: 30),
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Sessions", completedSessions.toString(), Icons.timer),
        _buildStatCard("Streak", "$streak day${streak != 1 ? 's' : ''}", Icons.local_fire_department),
        _buildStatCard("Points", points.toString(), Icons.star),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Session Duration (minutes):", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableDurations.map((duration) {
            return FilterChip(
              label: Text("$duration"),
              selected: selectedDuration == duration,
              onSelected: (selected) {
                if (selected) resetTimer(duration);
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedDuration == duration 
                    ? Colors.white 
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Slider(
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
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isRunning)
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: startTimer,
          ),
        if (isRunning)
          ElevatedButton.icon(
            icon: const Icon(Icons.pause),
            label: const Text("Pause"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.orange,
            ),
            onPressed: pauseTimer,
          ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Reset"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () => resetTimer(selectedDuration),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("Your Focus History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
              lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
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
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
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