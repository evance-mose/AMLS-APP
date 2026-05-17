import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? '';
  }

  /// Assistant service root from `.env` (e.g. `http://127.0.0.1:8080`).
  static String get assistantBaseUrl {
    return dotenv.env['ASSISTANT_URL']?.trim() ?? '';
  }

  /// Chat: `POST {ASSISTANT_URL}/assistant`.
  static String get assistantChatUrl {
    final raw = assistantBaseUrl.trim();
    if (raw.isEmpty) return '';
    final trimmed = raw.replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/assistant')) return trimmed;
    return '$trimmed/assistant';
  }

  /// Suggestions: `GET {BASE_URL}/assistant/suggestions` (main API).
  static String get assistantSuggestionsUrl {
    final raw = baseUrl.trim();
    if (raw.isEmpty) return '';
    final trimmed = raw.replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/api')) {
      return '$trimmed/assistant/suggestions';
    }
    return '$trimmed/api/assistant/suggestions';
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