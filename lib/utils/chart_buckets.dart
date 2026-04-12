import 'package:amls/models/issue_model.dart';
import 'package:amls/models/log_model.dart';

/// Short weekday labels for the rolling 7-day window (index 0 = oldest).
List<String> weekdayLabelsLast7Days() {
  const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final today = DateTime.now();
  final end = DateTime(today.year, today.month, today.day);
  return List.generate(7, (i) {
    final d = end.subtract(Duration(days: 6 - i));
    return short[d.weekday - 1];
  });
}

/// Counts items whose [dateOf] falls on each calendar day from 6 days ago through today.
List<double> bucketIssuesByDayLast7(List<Issue> issues) {
  return _bucketByDayLast7(issues, (i) => i.createdAt);
}

List<double> bucketLogsByDayLast7(List<Log> logs) {
  return _bucketByDayLast7(logs, (l) => l.createdAt);
}

List<double> _bucketByDayLast7<T>(List<T> items, DateTime Function(T) dateOf) {
  final today = DateTime.now();
  final end = DateTime(today.year, today.month, today.day);
  final start = end.subtract(const Duration(days: 6));
  final buckets = List<double>.filled(7, 0);
  for (final item in items) {
    final raw = dateOf(item);
    final d = DateTime(raw.year, raw.month, raw.day);
    if (d.isBefore(start) || d.isAfter(end)) continue;
    final idx = d.difference(start).inDays;
    if (idx >= 0 && idx < 7) buckets[idx] += 1;
  }
  return buckets;
}
