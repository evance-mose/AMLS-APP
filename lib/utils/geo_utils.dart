import 'dart:math' as math;

/// Great-circle distance between two WGS84 points, in meters.
double distanceMetersLatLng(
  double lat1Deg,
  double lon1Deg,
  double lat2Deg,
  double lon2Deg,
) {
  const earthRadiusM = 6371000.0;
  final lat1 = lat1Deg * math.pi / 180;
  final lat2 = lat2Deg * math.pi / 180;
  final dLat = (lat2Deg - lat1Deg) * math.pi / 180;
  final dLon = (lon2Deg - lon1Deg) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusM * c;
}
