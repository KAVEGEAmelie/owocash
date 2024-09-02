import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static String _authToken = ''; // Token JWT

  static void setToken(String token) {
    _authToken = token;
  }

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  static Future<http.Response> get(String url) {
    return http.get(Uri.parse(url), headers: getHeaders());
  }

  static Future<http.Response> post(String url, {Map<String, dynamic>? body}) {
    return http.post(Uri.parse(url),
        headers: getHeaders(),
        body: body != null ? jsonEncode(body) : null);
  }

  static Future<http.Response> put(String url, {Map<String, dynamic>? body}) {
    return http.put(Uri.parse(url),
        headers: getHeaders(),
        body: body != null ? jsonEncode(body) : null);
  }
}
