/// One GPS sample as returned for admins (e.g. `GET /location-trail`).
///
/// Expected JSON keys (flexible aliases supported in [fromJson]):
/// `user_id`, optional nested `user` with `name`, `latitude`, `longitude`,
/// `accuracy_meters`, `recorded_at`.
class UserLocationSnapshot {
  UserLocationSnapshot({
    required this.userId,
    this.userName,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
  });

  final int userId;
  final String? userName;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime recordedAt;

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _readDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory UserLocationSnapshot.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final uid = _readInt(json['user_id'] ?? json['userId'] ?? userMap?['id']) ?? 0;
    final name = json['user_name'] as String? ??
        json['name'] as String? ??
        userMap?['name'] as String?;

    return UserLocationSnapshot(
      userId: uid,
      userName: name,
      latitude: _readDouble(json['latitude']) ?? 0,
      longitude: _readDouble(json['longitude']) ?? 0,
      accuracyMeters: _readDouble(json['accuracy_meters'] ?? json['accuracyMeters']),
      recordedAt: _parseTime(json['recorded_at'] ?? json['recordedAt']),
    );
  }

  static DateTime _parseTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    return DateTime.now();
  }

  String get displayName =>
      (userName != null && userName!.trim().isNotEmpty) ? userName! : 'User #$userId';
}
