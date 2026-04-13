import 'dart:async';

import 'package:amls/database/storage_json.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/services/api_service.dart';
import 'package:amls/services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foreground-only location trail: periodic GPS samples while the app is running.
/// Points upload to [ApiService.submitLocationTrailPoint] or queue offline.
class LocationTrailService {
  LocationTrailService._();
  static final LocationTrailService instance = LocationTrailService._();

  static const _prefKeyEnabled = 'technician_location_trail_enabled';
  static const _sampleInterval = Duration(minutes: 3);

  final ValueNotifier<DateTime?> lastSentAt = ValueNotifier<DateTime?>(null);

  Timer? _timer;
  bool _running = false;
  bool _sending = false;

  bool get isRunning => _running;

  Future<bool> get enabled async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_prefKeyEnabled) ?? false;
  }

  /// Turn trail on or off. Returns whether the preference is now enabled (false if GPS permission denied).
  Future<bool> setEnabled(bool value) async {
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
  }

  void _armTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_sampleInterval, (_) => unawaited(_captureAndSend()));
  }

  Future<void> _captureAndSend() async {
    if (!_running || _sending) return;
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

      final recordedAt = DateTime.now().toUtc();
      try {
        await ApiService.submitLocationTrailPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          recordedAt: recordedAt,
        );
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
          lastSentAt.value = DateTime.now();
        }
        // Other API errors (e.g. 404) are skipped; add `POST /location-trail` on the server.
      }
    } catch (_) {
      // GPS / timeout: retry on next interval.
    } finally {
      _sending = false;
    }
  }
}
