import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final List<SubjectData> subjects = [];
  final TextEditingController newSubjectController = TextEditingController();
  Map<String, double> marksData = {};
  
  // Mood prediction
  bool isLoadingMood = false;
  String currentMood = "";
  String moodMessage = "";
  Map<String, dynamic> moodDetails = {};
  Timer? moodTimer;

  @override
  void initState() {
    super.initState();
    fetchRandomMoodPrediction();
    moodTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchRandomMoodPrediction();
    });
    
    // Add some initial subjects for demo
    subjects.addAll([
      SubjectData("Mathematics", [85, 78, 92]),
      SubjectData("Science", [92, 88, 95]),
      SubjectData("English", [78, 82, 80]),
    ]);
    updateChartData();
  }
  
  @override
  void dispose() {
    moodTimer?.cancel();
    newSubjectController.dispose();
    super.dispose();
  }

  void updateChartData() {
    marksData.clear();
    for (var subject in subjects) {
      if (subject.currentScore != null) {
        marksData[subject.name] = subject.currentScore!;
      }
    }
    setState(() {});
  }
  
  void addNewSubject() {
    if (newSubjectController.text.isNotEmpty) {
      setState(() {
        subjects.add(SubjectData(newSubjectController.text, []));
        newSubjectController.clear();
      });
    }
  }
  
  Future<void> fetchRandomMoodPrediction() async {
    setState(() => isLoadingMood = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://mood-detector-0s40.onrender.com/random_entry_prediction'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentMood = data['dominant_mood'] ?? 'NEUTRAL';
          moodDetails = data;
          
          switch (currentMood) {
            case 'HAPPY': moodMessage = "You're feeling happy today! Your activity levels look great."; break;
            case 'ALERT': moodMessage = "You're feeling alert and focused. Great time for studying!"; break;
            case 'NEUTRAL': moodMessage = "You're feeling balanced today."; break;
            case 'RESTED/RELAXED': moodMessage = "You're well-rested and relaxed. Your sleep quality looks good!"; break;
            case 'SAD': moodMessage = "You might be feeling a bit down today. Consider some physical activity."; break;
            case 'TENSE/ANXIOUS': moodMessage = "You seem a bit tense. Maybe try some mindfulness exercises?"; break;
            case 'TIRED': moodMessage = "You're feeling tired. Consider getting more rest tonight."; break;
            default: moodMessage = "Your mood seems balanced today.";
          }
        });
      } else {
        setState(() {
          currentMood = "NEUTRAL";
          moodMessage = "Unable to predict mood right now.";
        });
      }
    } catch (e) {
      setState(() {
        currentMood = "NEUTRAL";
        moodMessage = "Couldn't connect to mood service.";
      });
    } finally {
      setState(() => isLoadingMood = false);
    }
  }
  
  Color getMoodColor(String mood) {
    switch (mood) {
      case 'HAPPY': return Colors.yellow;
      case 'ALERT': return Colors.orange;
      case 'NEUTRAL': return Colors.blue;
      case 'RESTED/RELAXED': return Colors.green;
      case 'SAD': return Colors.indigo;
      case 'TENSE/ANXIOUS': return Colors.red;
      case 'TIRED': return Colors.purple;
      default: return Colors.grey;
    }
  }
  
  IconData getMoodIcon(String mood) {
    switch (mood) {
      case 'HAPPY': return Icons.sentiment_very_satisfied;
      case 'ALERT': return Icons.visibility;
      case 'NEUTRAL': return Icons.sentiment_neutral;
      case 'RESTED/RELAXED': return Icons.bedtime;
      case 'SAD': return Icons.sentiment_very_dissatisfied;
      case 'TENSE/ANXIOUS': return Icons.warning_amber;
      case 'TIRED': return Icons.nights_stay;
      default: return Icons.face;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Performance Dashboard'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Prediction Card
              _buildMoodCard(),
              const SizedBox(height: 20),
              
              // Performance Overview
              const Text(
                "Performance Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              _buildPerformanceOverview(),
              const SizedBox(height: 20),
              
              // Subject Analysis
              const Text(
                "Subject Analysis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              _buildSubjectCharts(),
              _buildAddSubjectField(),
              const SizedBox(height: 20),
              ...subjects.map((subject) => _buildSubjectCard(subject)).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMoodCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Mood Prediction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: isLoadingMood ? null : fetchRandomMoodPrediction,
                ),
              ],
            ),
            const SizedBox(height: 16),
            isLoadingMood
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: getMoodColor(currentMood).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getMoodIcon(currentMood),
                        size: 36,
                        color: getMoodColor(currentMood),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentMood.replaceAll("_", " "),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            moodMessage,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < subjects.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                subjects[value.toInt()].name,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: subjects.map((subject) {
                    final index = subjects.indexOf(subject);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: subject.currentScore ?? 0,
                          color: Colors.primaries[index % Colors.primaries.length],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat("Average", "87%", Icons.assessment),
                _buildMiniStat("Highest", "95%", Icons.leaderboard),
                _buildMiniStat("Improvement", "+8%", Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMiniStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildSubjectCharts() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Subject Performance Distribution",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: subjects.map((subject) {
                    return PieChartSectionData(
                      value: subject.currentScore ?? 0,
                      title: subject.name,
                      color: Colors.primaries[subjects.indexOf(subject) % Colors.primaries.length],
                      radius: 16,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddSubjectField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: newSubjectController,
                decoration: InputDecoration(
                  labelText: "Add New Subject",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: addNewSubject,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectCard(SubjectData subject) {
    final index = subjects.indexOf(subject);
    final color = Colors.primaries[index % Colors.primaries.length];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditSubjectDialog(subject),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar with current score
            Row(
              children: [
                const Text("Current:", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (subject.currentScore ?? 0) / 100,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${subject.currentScore?.toStringAsFixed(1) ?? '--'}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Previous test scores
            const Text("Previous Test Scores:", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++)
                  Column(
                    children: [
                      Text(
                        "Test ${i + 1}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          subject.previousScores.length > i 
                            ? subject.previousScores[i].toString() 
                            : "--",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Trend indicator
            Row(
              children: [
                const Text("Trend:", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Icon(
                  subject.trendIcon,
                  color: subject.trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  subject.trendText,
                  style: TextStyle(
                    color: subject.trendColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditSubjectDialog(SubjectData subject) {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    final controller3 = TextEditingController();
    
    if (subject.previousScores.isNotEmpty) {
      if (subject.previousScores.length > 0) controller1.text = subject.previousScores[0].toString();
      if (subject.previousScores.length > 1) controller2.text = subject.previousScores[1].toString();
      if (subject.previousScores.length > 2) controller3.text = subject.previousScores[2].toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${subject.name} Scores"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Test 1 Score"),
            ),
            TextField(
              controller: controller2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Test 2 Score"),
            ),
            TextField(
              controller: controller3,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Test 3 Score"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final scores = [
                double.tryParse(controller1.text) ?? 0,
                double.tryParse(controller2.text) ?? 0,
                double.tryParse(controller3.text) ?? 0,
              ].where((score) => score > 0).toList();
              
              setState(() {
                subject.previousScores = scores;
                if (scores.isNotEmpty) {
                  subject.currentScore = scores.last;
                }
              });
              updateChartData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class SubjectData {
  final String name;
  List<double> previousScores;
  double? currentScore;
  
  SubjectData(this.name, this.previousScores) {
    if (previousScores.isNotEmpty) {
      currentScore = previousScores.last;
    }
  }
  
  IconData get trendIcon {
    if (previousScores.length < 2) return Icons.trending_flat;
    final last = previousScores.last;
    final secondLast = previousScores[previousScores.length - 2];
    return last > secondLast 
      ? Icons.trending_up 
      : last < secondLast 
        ? Icons.trending_down 
        : Icons.trending_flat;
  }
  
  Color get trendColor {
    if (previousScores.length < 2) return Colors.grey;
    final last = previousScores.last;
    final secondLast = previousScores[previousScores.length - 2];
    return last > secondLast 
      ? Colors.green 
      : last < secondLast 
        ? Colors.red 
        : Colors.grey;
  }
  
  String get trendText {
    if (previousScores.length < 2) return "No trend data";
    final last = previousScores.last;
    final secondLast = previousScores[previousScores.length - 2];
    final difference = last - secondLast;
    
    if (difference > 0) {
      return "+${difference.toStringAsFixed(1)}% improvement";
    } else if (difference < 0) {
      return "${difference.toStringAsFixed(1)}% decline";
    } else {
      return "No change";
    }
  }
}