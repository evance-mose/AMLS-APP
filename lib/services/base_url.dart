import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://10.111.157.212:8000/api';
  }
}