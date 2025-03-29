import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
