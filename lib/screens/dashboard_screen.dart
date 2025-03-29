// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/usage_data.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  int phoneUnlocks = 0;
  double totalScreenTime = 0.0;
  List<Map<String, dynamic>> appUsage = [];
  bool isLoading = true;
  bool hasPermission = false;
  String errorMessage = '';
  Timer? _refreshTimer;
  DateTime? _lastResumeTime;
  int _previousUnlockCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastResumeTime = DateTime.now();
      if (hasPermission) {
        _fetchUsageStats();
      }
    } else if (state == AppLifecycleState.paused) {
      _lastResumeTime = null;
    }
  }

  Future<void> _checkAndRequestPermission() async {
    bool granted = await UsageStats.checkUsagePermission() ?? false;
    
    if (!granted) {
      await UsageStats.grantUsagePermission();
      await Future.delayed(Duration(seconds: 3));
      granted = await UsageStats.checkUsagePermission() ?? false;
    }
    
    setState(() {
      hasPermission = granted;
      isLoading = false;
    });
    
    if (granted) {
      _fetchUsageStats();
      _startPeriodicRefresh();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (hasPermission && mounted) {
        _fetchUsageStats();
      }
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    await UsageStats.grantUsagePermission();
    await Future.delayed(Duration(seconds: 3));
    bool granted = await UsageStats.checkUsagePermission() ?? false;
    
    setState(() {
      hasPermission = granted;
      isLoading = false;
    });
    
    if (granted) {
      _fetchUsageStats();
      _startPeriodicRefresh();
    } else {
      setState(() {
        errorMessage = 'Permission not granted. Please enable usage access in system settings.';
      });
    }
  }

  Future<void> _fetchUsageStats() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      DateTime end = DateTime.now();
      DateTime start = end.subtract(Duration(hours: 24));
      List<UsageInfo> stats = await UsageStats.queryUsageStats(start, end);
      
      if (stats.isEmpty) {
        start = end.subtract(Duration(days: 7));
        stats = await UsageStats.queryUsageStats(start, end);
        if (stats.isEmpty) {
          setState(() {
            isLoading = false;
            errorMessage = 'No usage data available. This may take time after granting permission.';
          });
          return;
        }
      }
      
      var eventStats = await UsageStats.queryEvents(start, end);
      int unlockCount = 0;
      
      if (eventStats != null && eventStats.isNotEmpty) {
        for (var event in eventStats) {
          if (event.eventType == 'DEVICE_UNLOCKED' || 
              event.eventType == 'SCREEN_INTERACTIVE' || 
              event.eventType == 'USER_INTERACTION') {
            unlockCount++;
          }
        }
      }
      
      if (unlockCount == 0) {
        List<DateTime> usageTimes = [];
        for (var stat in stats) {
          if (stat.lastTimeUsed != null) {
            var timeValue = stat.lastTimeUsed;
            if (timeValue is int) {
              usageTimes.add(DateTime.fromMillisecondsSinceEpoch(timeValue as int));
            } else if (timeValue is String) {
              int? timeMs = int.tryParse(timeValue);
              if (timeMs != null) {
                usageTimes.add(DateTime.fromMillisecondsSinceEpoch(timeMs));
              }
            }
          }
        }
        usageTimes.sort();
        if (usageTimes.isNotEmpty) {
          unlockCount = 1;
          for (int i = 1; i < usageTimes.length; i++) {
            var diff = usageTimes[i].difference(usageTimes[i-1]).inMinutes;
            if (diff > 5) {
              unlockCount++;
            }
          }
        } else {
          unlockCount = stats.length ~/ 5;
        }
      }
      
      unlockCount = unlockCount.clamp(1, 100);
      if (unlockCount > _previousUnlockCount) {
        _previousUnlockCount = unlockCount;
      } else {
        if (_lastResumeTime != null && 
            DateTime.now().difference(_lastResumeTime!).inMinutes < 2) {
          _previousUnlockCount++;
          _lastResumeTime = null;
        }
        unlockCount = _previousUnlockCount;
      }
      
      Map<String, dynamic> appTimes = {};
      double screenTime = 0.0;
      
      for (var stat in stats) {
        if (stat.packageName != null && stat.totalTimeInForeground != null) {
          String appName = _getReadableAppName(stat.packageName!);
          int timeMs = 0;
          var timeValue = stat.totalTimeInForeground;
          
          try {
            if (timeValue is int) {
              timeMs = timeValue as int;
            } else if (timeValue is String) {
              timeMs = int.tryParse(timeValue) ?? 0;
            } else if (timeValue is double) {
              timeMs = timeValue as int;
            } else {
              continue;
            }
            if (timeMs > 1000) {
              appTimes[appName] = (appTimes[appName] ?? 0) + timeMs;
              screenTime += timeMs / 3600000;
            }
          } catch (e) {
            continue;
          }
        }
      }
      
      List<Map<String, dynamic>> usageList = [];
      appTimes.forEach((appName, timeMs) {
        usageList.add({
          'app': appName,
          'timeMs': timeMs,
          'time': _formatDuration(timeMs),
        });
      });
      
      usageList.sort((a, b) => (b['timeMs'] as int).compareTo(a['timeMs'] as int));
      
      setState(() {
        phoneUnlocks = unlockCount;
        totalScreenTime = screenTime;
        appUsage = usageList.take(5).toList();
        isLoading = false;
      });
      
      // Update the global usage data model
      globalUsageData = UsageData(
        phoneUnlocks: phoneUnlocks,
        totalScreenTime: totalScreenTime,
        appUsage: appUsage,
      );
      
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching usage stats: ${e.toString().substring(0, math.min(e.toString().length, 100))}';
      });
    }
  }
  
  String _formatDuration(int milliseconds) {
    double minutes = milliseconds / 60000;
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(1)} min';
    } else {
      double hours = minutes / 60;
      return '${hours.toStringAsFixed(1)} hrs';
    }
  }
  
  String _getReadableAppName(String packageName) {
    Map<String, String> knownApps = {
      'com.whatsapp': 'WhatsApp',
      'com.facebook.katana': 'Facebook',
      'com.instagram.android': 'Instagram',
      'com.google.android.youtube': 'YouTube',
      'com.android.chrome': 'Chrome',
      'com.google.android.gm': 'Gmail',
      'com.android.vending': 'Play Store',
      'com.google.android.apps.maps': 'Maps',
    };
    
    if (knownApps.containsKey(packageName)) {
      return knownApps[packageName]!;
    }
    
    try {
      List<String> parts = packageName.split('.');
      List<String> commonWords = ['app', 'android', 'com', 'google', 'mobile', 'service', 'main'];
      for (int i = parts.length - 1; i >= 0; i--) {
        if (parts[i].length > 2 && !commonWords.contains(parts[i].toLowerCase())) {
          String name = parts[i][0].toUpperCase() + parts[i].substring(1);
          name = name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]} ${m[2]}');
          return name;
        }
      }
      String lastPart = parts.last;
      return lastPart[0].toUpperCase() + lastPart.substring(1);
    } catch (e) {
      return packageName.split('.').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Wellbeing'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: hasPermission ? _fetchUsageStats : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading usage statistics...'),
                ],
              ))
            : !hasPermission
                ? _buildPermissionRequest()
                : _buildStatsContent(),
      ),
    );
  }
  
  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Usage Access Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'This app needs access to your usage statistics to show screen time and app usage data.',
              textAlign: TextAlign.center,
            ),
          ),
          if (errorMessage.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade900),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.security),
            label: Text('Grant Permission'),
            onPressed: _requestPermission,
          ),
          SizedBox(height: 8),
          TextButton.icon(
            icon: Icon(Icons.settings),
            label: Text('Open App Settings'),
            onPressed: () async {
              await openAppSettings();
              await Future.delayed(Duration(seconds: 3));
              await _checkAndRequestPermission();
            },
          ),
          SizedBox(height: 16),
          Text(
            'Note: On some devices, you need to manually enable "Usage Access" for this app in system settings.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsContent() {
    return errorMessage.isNotEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error Loading Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  onPressed: _fetchUsageStats,
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Usage Statistics', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(Icons.screen_lock_portrait, 'Unlocks', '$phoneUnlocks times'),
                      _buildVerticalDivider(),
                      _buildStatColumn(Icons.access_time, 'Screen Time', '${totalScreenTime.toStringAsFixed(1)} hrs'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Most Used Apps', style: Theme.of(context).textTheme.titleLarge),
                  Text('Last 24 Hours', style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: appUsage.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.apps, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No app usage data available'),
                            SizedBox(height: 8),
                            Text(
                              'It may take some time for data to become available after granting permissions.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.refresh),
                              label: Text('Refresh'),
                              onPressed: _fetchUsageStats,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: appUsage.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                                child: Text(appUsage[index]['app'].substring(0, 1), style: TextStyle(color: Colors.white)),
                              ),
                              title: Text(appUsage[index]['app']),
                              trailing: Text(appUsage[index]['time']),
                              subtitle: LinearProgressIndicator(
                                value: (appUsage[index]['timeMs'] as int) / (appUsage.isNotEmpty ? (appUsage[0]['timeMs'] as int) : 1),
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
  }
  
  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
  
  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
