import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Timer variables (in seconds).
  int selectedDuration = 25 * 60;
  int remainingSeconds = 25 * 60;
  Timer? _timer;
  bool isRunning = false;

  // Simulated pomodoro completions for each day (keyed by day number) for current month.
  Map<int, int> dailyPomodoros = {};

  // TableCalendar state.
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    generatePomodoroData();
  }

  /// Generate simulated pomodoro data for the current month.
  void generatePomodoroData() {
    final now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    setState(() {
      dailyPomodoros = {
        for (int day = 1; day <= daysInMonth; day++) day: day % 4,
      };
    });
  }

  // Timer functions.
  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        setState(() => isRunning = false);
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      selectedDuration = minutes * 60;
      remainingSeconds = minutes * 60;
      isRunning = false;
    });
  }

  /// Format seconds as mm:ss.
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Returns the events for a given day.
  List<dynamic> _getEventsForDay(DateTime day) {
    // Only show events for the current month/year.
    if (day.month != DateTime.now().month || day.year != DateTime.now().year) {
      return [];
    }
    int count = dailyPomodoros[day.day] ?? 0;
    if (count > 0) return [count];
    return [];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer & Shop'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Timer display.
              Text(
                formatTime(remainingSeconds),
                style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Duration selection.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("25 Minutes"),
                    selected: selectedDuration == 25 * 60,
                    onSelected: (selected) {
                      if (selected) resetTimer(25);
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("50 Minutes"),
                    selected: selectedDuration == 50 * 60,
                    onSelected: (selected) {
                      if (selected) resetTimer(50);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Play/Pause button.
              IconButton(
                iconSize: 70,
                icon: Icon(
                  isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.blue,
                ),
                onPressed: () => isRunning ? pauseTimer() : startTimer(),
              ),
              const SizedBox(height: 30),
              // Calendar using TableCalendar.
              TableCalendar(
                firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
                lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day + 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                // Custom markers based on pomodoro count.
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      int count = events.first as int;
                      Color markerColor;
                      if (count == 1) {
                        markerColor = Colors.lightBlue.shade200;
                      } else if (count == 2) {
                        markerColor = Colors.lightBlue.shade400;
                      } else if (count >= 3) {
                        markerColor = Colors.lightBlue.shade700;
                      } else {
                        markerColor = Colors.lightBlue.shade50;
                      }
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.white),
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
      ),
    );
  }
}
