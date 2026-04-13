import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? '';
  }

  /// `POST` / `GET` location trail — `/api/location-trail` relative to host.
  /// Works whether [baseUrl] is `https://host` or `https://host/api`.
  static String get locationTrailUrl {
    final raw = baseUrl.trim();
    if (raw.isEmpty) return '';
    final trimmed = raw.replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/api')) {
      return '$trimmed/location-trail';
    }
    return '$trimmed/api/location-trail';
  }
}