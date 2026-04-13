import 'dart:async';

import 'package:amls/database/storage_json.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/api_service.dart';
import 'package:amls/services/auth_service.dart';
import 'package:amls/services/sync_service.dart';
import 'package:amls/utils/geo_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foreground-only GPS trail for **technicians** only. Posts to
/// `POST /api/location-trail` with Bearer token (no `user_id` in body).
///
/// Throttle: at least [minPostInterval] between uploads unless the device
/// moved at least [minDisplacementMeters] since the last posted point.
class LocationTrailService {
  LocationTrailService._();
  static final LocationTrailService instance = LocationTrailService._();

  static const _prefKeyEnabled = 'technician_location_trail_enabled';

  /// How often we obtain a GPS fix and evaluate throttle rules.
  static const Duration _tickInterval = Duration(seconds: 30);

  /// Minimum time between successful uploads unless displacement triggers sooner.
  static const Duration minPostInterval = Duration(seconds: 45);

  /// Post early if horizontal movement exceeds this since last upload.
  static const double minDisplacementMeters = 50;

  final ValueNotifier<DateTime?> lastSentAt = ValueNotifier<DateTime?>(null);

  Timer? _timer;
  bool _running = false;
  bool _sending = false;

  DateTime? _lastPostedAtUtc;
  double? _lastPostedLat;
  double? _lastPostedLng;

  bool get isRunning => _running;

  Future<bool> get enabled async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_prefKeyEnabled) ?? false;
  }

  /// Turn trail on or off. Returns whether the preference is now enabled (false if not technician / GPS denied).
  Future<bool> setEnabled(bool value) async {
    if (value) {
      final user = await AuthService.getUser();
      if (user?.role != UserRole.technician) {
        return false;
      }
    }
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefKeyEnabled, value);
    if (value) {
      final started = await _startInternal();
      if (!started) {
        await p.setBool(_prefKeyEnabled, false);
        return false;
      }
      return true;
    }
    _stopInternal();
    return false;
  }

  /// Resume sampling if the user left trail enabled (app start or after login).
  Future<void> restoreIfEnabled() async {
    if (!await enabled) return;
    final ok = await _startInternal();
    if (!ok) {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefKeyEnabled, false);
    }
  }

  /// Stop sampling; keep saved preference so it can resume next session.
  void stopForLogout() {
    _stopInternal();
  }

  void onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
      _timer = null;
    }
    if (state == AppLifecycleState.resumed && _running) {
      unawaited(_captureAndSend());
      _armTimer();
    }
  }

  Future<bool> _startInternal() async {
    if (_running) return true;

    final user = await AuthService.getUser();
    if (user?.role != UserRole.technician) {
      return false;
    }

    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    _running = true;
    await _captureAndSend();
    _armTimer();
    return true;
  }

  void _stopInternal() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _sending = false;
    _lastPostedAtUtc = null;
    _lastPostedLat = null;
    _lastPostedLng = null;
  }

  void _armTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, (_) => unawaited(_captureAndSend()));
  }

  bool _shouldUpload(Position position, DateTime nowUtc) {
    if (_lastPostedAtUtc == null ||
        _lastPostedLat == null ||
        _lastPostedLng == null) {
      return true;
    }
    final since = nowUtc.difference(_lastPostedAtUtc!);
    if (since >= minPostInterval) return true;
    final moved = distanceMetersLatLng(
      _lastPostedLat!,
      _lastPostedLng!,
      position.latitude,
      position.longitude,
    );
    return moved >= minDisplacementMeters;
  }

  void _recordSuccessfulPost(
    double lat,
    double lng,
    DateTime recordedAtUtc,
  ) {
    _lastPostedAtUtc = recordedAtUtc;
    _lastPostedLat = lat;
    _lastPostedLng = lng;
  }

  Future<void> _captureAndSend() async {
    if (!_running || _sending) return;

    final user = await AuthService.getUser();
    if (user?.role != UserRole.technician) {
      _stopInternal();
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefKeyEnabled, false);
      return;
    }

    _sending = true;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw TimeoutException('Location fix timed out'),
      );

      final nowUtc = DateTime.now().toUtc();
      if (!_shouldUpload(position, nowUtc)) {
        return;
      }

      final recordedAt = nowUtc;
      try {
        await ApiService.submitLocationTrailPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          recordedAt: recordedAt,
        );
        _recordSuccessfulPost(position.latitude, position.longitude, recordedAt);
        lastSentAt.value = DateTime.now();
        await SyncService.processPendingQueue();
      } catch (e) {
        if (SyncService.looksLikeNetworkError(e)) {
          await SyncQueue.enqueue(
            entity: kSyncEntityLocationTrail,
            operation: kSyncOpCreate,
            payloadJson: encodePayload({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'accuracy_meters': position.accuracy,
              'recorded_at': recordedAt.toIso8601String(),
            }),
          );
          _recordSuccessfulPost(position.latitude, position.longitude, recordedAt);
          lastSentAt.value = DateTime.now();
        }
        // Other API errors (e.g. 404): skipped; ensure `POST /api/location-trail` exists.
      }
    } catch (_) {
      // GPS / timeout: retry on next tick.
    } finally {
      _sending = false;
    }
  }
}
