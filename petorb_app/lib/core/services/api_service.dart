import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CHANGE THIS to your PC's local IP address (e.g. 192.168.1.15) if deploying to a physical mobile phone
  static const String localComputerIp = '192.168.1.2';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.macOS ||
               defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:5000/api';
    } else {
      // 10.0.2.2 maps to the host machine's localhost when running inside the Android Emulator
      return localComputerIp == '127.0.0.1' 
          ? 'http://10.0.2.2:5000/api' 
          : 'http://$localComputerIp:5000/api';
    }
  }
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static String? get token => _token;

  static bool get isAuthenticated => _token != null;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _getHeaders());
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _getHeaders());
  }
}
