import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimerSetHistoryEntry {
  final String name;
  final DateTime completedAt;
  final int totalSeconds;

  TimerSetHistoryEntry({
    required this.name,
    required this.completedAt,
    required this.totalSeconds,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'completedAt': completedAt.toIso8601String(),
    'totalSeconds': totalSeconds,
  };

  factory TimerSetHistoryEntry.fromJson(Map<String, dynamic> json) =>
      TimerSetHistoryEntry(
        name: json['name'],
        completedAt: DateTime.parse(json['completedAt']),
        totalSeconds: json['totalSeconds'],
      );
}

/// Save a new history entry, keeping only the last 5.
Future<void> saveHistoryEntry(TimerSetHistoryEntry entry) async {
  final prefs = await SharedPreferences.getInstance();
  final historyList = prefs.getStringList('timerHistory') ?? [];
  historyList.insert(0, jsonEncode(entry.toJson()));
  // Keep only the last 5
  while (historyList.length > 5) {
    historyList.removeLast();
  }
  await prefs.setStringList('timerHistory', historyList);
}

/// Load the last 5 history entries.
Future<List<TimerSetHistoryEntry>> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyList = prefs.getStringList('timerHistory') ?? [];
  final List<TimerSetHistoryEntry> result = [];
  for (final s in historyList) {
    try {
      final map = jsonDecode(s);
      result.add(TimerSetHistoryEntry.fromJson(map));
    } catch (_) {}
  }
  return result;
}
