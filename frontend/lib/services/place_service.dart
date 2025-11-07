import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PlaceService {
  final _base =
      ApiConfig.baseUrl; // fallback; adjust to local/emulator when needed

  Future<Map<String, String>> _headers() async {
    try {
      final token = await AuthService()
          .getToken(); // assume AuthService exposes getToken()
      if (token != null && token.isNotEmpty) {
        return {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        };
      }
    } catch (_) {}
    return ApiConfig.defaultHeaders;
  }

  Future<List<dynamic>> listPlaces() async {
    final url = Uri.parse('$_base${ApiConfig.placesEndpoint}');
    final res = await http.get(url, headers: await _headers());
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load places (${res.statusCode})');
  }

  Future<Map<String, dynamic>> createPlace(Map<String, dynamic> data) async {
    final url = Uri.parse('$_base${ApiConfig.placesEndpoint}');
    final res = await http.post(url,
        headers: await _headers(), body: json.encode(data));
    if (res.statusCode == 201)
      return json.decode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create place (${res.statusCode}): ${res.body}');
  }

  Future<void> updatePlace(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_base${ApiConfig.placesEndpoint}/$id');
    final res =
        await http.put(url, headers: await _headers(), body: json.encode(data));
    if (res.statusCode != 200)
      throw Exception('Failed to update place (${res.statusCode})');
  }

  Future<void> deletePlace(int id) async {
    final url = Uri.parse('$_base${ApiConfig.placesEndpoint}/$id');
    final res = await http.delete(url, headers: await _headers());
    if (res.statusCode != 200)
      throw Exception('Failed to delete place (${res.statusCode})');
  }
}
