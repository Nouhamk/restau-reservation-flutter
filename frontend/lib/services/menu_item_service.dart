import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

/// Service gérant les opérations CRUD et les requêtes liées aux plats du menu.
class MenuItemService {
  static final AuthService _authService = AuthService();

  /// Construit les en-têtes HTTP avec le token JWT pour les requêtes authentifiées.
  /// @return Map contenant les headers nécessaires à l'authentification.
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant - utilisateur non connecté');
    }

    final cleanedToken =
    token.startsWith('Bearer ') ? token.substring(7) : token;

    return ApiConfig.authHeaders(cleanedToken);
  }

  /// Récupère les plats disponibles (route publique).
  /// @return les plats disponibles.
  /// @throws Exception si la requête échoue.
  static Future<List<dynamic>> getAvailableMenu() async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception(
        'Erreur getAvailableMenu: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Récupère tous les plats, disponibles ou non (auth requis).
  /// @return Liste complète des plats
  /// @throws Exception si la requête échoue.
  static Future<List<dynamic>> getAllMenuItems() async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}/all';
    final headers = await _authHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception(
        'Erreur getAllMenuItems: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Récupère un plat spécifique via son identifiant.
  /// @param id Identifiant du plat à récupérer.
  /// @return le plat.
  /// @throws Exception si la requête échoue.
  static Future<Map<String, dynamic>> getMenuItem(int id) async {
    final headers = await _authHeaders();
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}/$id';

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception(
        'Erreur getMenuItem: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Crée un nouveau plat (réservé aux rôles admin/host).
  /// @param body Données JSON du plat à créer.
  /// @return le plat créé.
  /// @throws Exception si la requête échoue.
  static Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception(
        'Erreur createMenuItem: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Met à jour un plat existant (réservé aux rôles admin/host).
  /// @param id Identifiant du plat à modifier.
  /// @param body Données JSON contenant les champs à mettre à jour.
  /// @return le  plat mis à jour.
  /// @throws Exception si la requête échoue.
  static Future<Map<String, dynamic>> updateMenuItem(
      int id, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}/$id';

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception(
        'Erreur updateMenuItem: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Supprime un plat existant (réservé aux rôles admin).
  /// @param id Identifiant du plat à supprimer.
  /// @return La confirmation de suppression.
  /// @throws Exception si la requête échoue.
  static Future<Map<String, dynamic>> deleteMenuItem(int id) async {
    final headers = await _authHeaders();
    final url = '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}/$id';

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception(
        'Erreur deleteMenuItem: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Modifie la disponibilité d’un plat (réservé aux rôles admin/host).
  /// @param id Identifiant du plat.
  /// @param available Valeur booléenne indiquant la nouvelle disponibilité.
  /// @return Le plat mis à jour.
  /// @throws Exception si la requête échoue.
  static Future<Map<String, dynamic>> toggleAvailability(
      int id, bool available) async {
    final headers = await _authHeaders();
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.menuEndpoint}/$id/availability';

    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'available': available}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception(
        'Erreur toggleAvailability: ${response.statusCode} ${response.body}',
      );
    }
  }
}
