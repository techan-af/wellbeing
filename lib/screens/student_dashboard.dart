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
  final List<TextEditingController> subjectControllers =
      List.generate(5, (index) => TextEditingController());
  final List<TextEditingController> marksControllers =
      List.generate(5, (index) => TextEditingController());
  Map<String, double> marksData = {};

  String selectedYear = "All";
  String selectedGrade = "All";
  
  // Mood prediction related variables
  bool isLoadingMood = false;
  String currentMood = "";
  String moodMessage = "";
  Map<String, dynamic> moodDetails = {};
  
  // Timer for periodic mood updates
  Timer? moodTimer;

  @override
  void initState() {
    super.initState();
    // Initial mood prediction when the dashboard loads
    fetchRandomMoodPrediction();
    
    // Set up a timer to refresh mood every 30 seconds
    moodTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchRandomMoodPrediction();
    });
  }
  
  @override
  void dispose() {
    moodTimer?.cancel();
    super.dispose();
  }

  void updateChartData() {
    marksData.clear();
    for (int i = 0; i < 5; i++) {
      String subject = subjectControllers[i].text;
      String marks = marksControllers[i].text;
      if (subject.isNotEmpty && marks.isNotEmpty) {
        marksData[subject] = double.tryParse(marks) ?? 0;
      }
    }
    setState(() {});
  }
  
  // Function to get mood prediction from API
  Future<void> fetchRandomMoodPrediction() async {
    setState(() {
      isLoadingMood = true;
    });
    
    try {
      // Change this URL to your actual API endpoint
      final response = await http.get(
        Uri.parse('https://mood-detector-0s40.onrender.com/random_entry_prediction'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentMood = data['dominant_mood'] ?? 'NEUTRAL';
          moodDetails = data;
          
          // Create a more friendly message based on the mood
          switch (currentMood) {
            case 'HAPPY':
              moodMessage = "You're feeling happy today! Your activity levels look great.";
              break;
            case 'ALERT':
              moodMessage = "You're feeling alert and focused. Great time for studying!";
              break;
            case 'NEUTRAL':
              moodMessage = "You're feeling balanced today.";
              break;
            case 'RESTED/RELAXED':
              moodMessage = "You're well-rested and relaxed. Your sleep quality looks good!";
              break;
            case 'SAD':
              moodMessage = "You might be feeling a bit down today. Consider some physical activity.";
              break;
            case 'TENSE/ANXIOUS':
              moodMessage = "You seem a bit tense. Maybe try some mindfulness exercises?";
              break;
            case 'TIRED':
              moodMessage = "You're feeling tired. Consider getting more rest tonight.";
              break;
            default:
              moodMessage = "Your mood seems balanced today.";
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
      setState(() {
        isLoadingMood = false;
      });
    }
  }
  
  // Helper function to get color for mood
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
  
  // Helper function to get icon for mood
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
      appBar: AppBar(title: const Text('Student Performance Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  items: ["All", "2023", "2024"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedYear = value!);
                  },
                ),
                DropdownButton<String>(
                  value: selectedGrade,
                  items: ["All", "Grade 1", "Grade 2", "Grade 3"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedGrade = value!);
                  },
                ),
                Column(
                  children: [
                    const Icon(Icons.school, size: 40, color: Colors.blue),
                    const Text(
                      "Students",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "300",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Mood Prediction Card
            Card(
              elevation: 4,
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: isLoadingMood 
                            ? null 
                            : fetchRandomMoodPrediction,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    isLoadingMood
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Icon(
                              getMoodIcon(currentMood),
                              size: 48,
                              color: getMoodColor(currentMood),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentMood.replaceAll("_", " "),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    moodMessage,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: marksData.entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value,
                            title: entry.key,
                            color: Colors.primaries[marksData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                            radius: 80,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Divider(),
                  const Text(
                    "Subject Scores",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: marksData.entries.map((entry) {
                      return Column(
                        children: [
                          Text(entry.key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          Text("${entry.value.toStringAsFixed(2)}%"),
                        ],
                      );
                    }).toList(),
                  ),
                  const Divider(),
                  const Text(
                    "Enter Marks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  for (int i = 0; i < 5; i++)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subjectControllers[i],
                            decoration: InputDecoration(labelText: "Subject ${i + 1}"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: marksControllers[i],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: "Marks"),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateChartData,
                    child: const Text("Update Dashboard"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}