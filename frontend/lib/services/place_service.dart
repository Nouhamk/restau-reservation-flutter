import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../config/api_config.dart';

class PlaceService {
  /// Récupérer toutes les places (restaurants)
  Future<Map<String, dynamic>> getAllPlaces() async {
    try {
      final response = await http
          .get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.placesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      )
          .timeout(ApiConfig.timeout);

      print('Get places response status: ${response.statusCode}');
      print('Get places response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Place> places = data.map((json) => Place.fromJson(json)).toList();

        return {
          'success': true,
          'places': places,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la récupération des restaurants',
        };
      }
    } catch (e) {
      print('Get places error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Récupérer une place par son ID
  Future<Map<String, dynamic>> getPlaceById(int id) async {
    try {
      final response = await http
          .get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.placesEndpoint}/$id'),
        headers: ApiConfig.defaultHeaders,
      )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'place': Place.fromJson(data),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Restaurant non trouvé',
        };
      }
    } catch (e) {
      print('Get place by id error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Créer une nouvelle place (Admin uniquement)
  Future<Map<String, dynamic>> createPlace({
    required String token,
    required String name,
    required String address,
    String? phone,
    int? capacity,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.placesEndpoint}'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'name': name,
          'address': address,
          if (phone != null) 'phone': phone,
          if (capacity != null) 'capacity': capacity,
        }),
      )
          .timeout(ApiConfig.timeout);

      print('Create place response status: ${response.statusCode}');
      print('Create place response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Restaurant créé avec succès',
          'placeId': data['placeId'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la création du restaurant',
        };
      }
    } catch (e) {
      print('Create place error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Mettre à jour une place (Admin uniquement)
  Future<Map<String, dynamic>> updatePlace({
    required String token,
    required int id,
    required String name,
    required String address,
    String? phone,
    int? capacity,
  }) async {
    try {
      final response = await http
          .put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.placesEndpoint}/$id'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'name': name,
          'address': address,
          if (phone != null) 'phone': phone,
          if (capacity != null) 'capacity': capacity,
        }),
      )
          .timeout(ApiConfig.timeout);

      print('Update place response status: ${response.statusCode}');
      print('Update place response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Restaurant mis à jour avec succès',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la mise à jour du restaurant',
        };
      }
    } catch (e) {
      print('Update place error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Supprimer une place (Admin uniquement)
  Future<Map<String, dynamic>> deletePlace({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http
          .delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.placesEndpoint}/$id'),
        headers: ApiConfig.authHeaders(token),
      )
          .timeout(ApiConfig.timeout);

      print('Delete place response status: ${response.statusCode}');
      print('Delete place response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Restaurant supprimé avec succès',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la suppression du restaurant',
        };
      }
    } catch (e) {
      print('Delete place error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }
}
