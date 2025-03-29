// lib/models/usage_data.dart
class UsageData {
  int phoneUnlocks;
  double totalScreenTime;
  List<Map<String, dynamic>> appUsage;
  
  UsageData({
    this.phoneUnlocks = 0,
    this.totalScreenTime = 0.0,
    this.appUsage = const [],
  });
}

// Global instance to store the latest usage data
UsageData globalUsageData = UsageData();
