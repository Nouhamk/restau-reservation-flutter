import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AdminService {
  final _base = ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    try {
      final token = await AuthService().getToken();
      if (token != null && token.isNotEmpty) {
        return {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        };
      }
    } catch (_) {}
    return ApiConfig.defaultHeaders;
  }

  Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse('$_base/admin/stats');
    final res = await http.get(url, headers: await _headers());
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      // Normalize to integers (backend returns numbers)
      return {
        'restaurants': data['restaurants'] ?? 0,
        'clients': data['clients'] ?? 0,
        'hosts': data['hosts'] ?? 0,
        'reservations': data['reservations'] ?? 0,
      };
    }
    throw Exception('Failed to fetch stats (${res.statusCode})');
  }

  /// Obtenir la liste de tous les restaurants/places
  Future<List<Map<String, dynamic>>> getPlaces() async {
    final url = Uri.parse('$_base/places');
    final res = await http.get(url, headers: await _headers());
    
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to fetch places (${res.statusCode})');
  }
}