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

// Implement these using your backend (e.g., Firestore, Supabase, etc.)
Future<void> saveHistoryEntry(String userId, TimerSetHistoryEntry entry) async {
  // Save entry for userId in your backend
}

Future<List<TimerSetHistoryEntry>> loadHistory(String userId) async {
  // Load and return history entries for userId from your backend
  return [];
}
