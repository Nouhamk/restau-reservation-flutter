import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  // Stockage sécurisé pour le token
  final _storage = const FlutterSecureStorage();

  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Inscription d'un nouvel utilisateur
  /// Adapté au format de votre backend existant
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? nom,
    String? telephone,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': nom, // Votre backend utilise "name" pas "nom"
          'phone': telephone, // Votre backend utilise "phone" pas "telephone"
        }),
      )
          .timeout(ApiConfig.timeout);

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Succès - sauvegarder le token et les données utilisateur
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUser(User.fromJson(data['user']));
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie',
          'user': data['user'] != null ? User.fromJson(data['user']) : null,
        };
      } else {
        // Erreur
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur. Vérifiez votre connexion internet.',
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Erreur de format de réponse du serveur.',
      };
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Connexion d'un utilisateur existant
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(ApiConfig.timeout);

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Succès - sauvegarder le token et les données utilisateur
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUser(User.fromJson(data['user']));
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Connexion réussie',
          'user': data['user'] != null ? User.fromJson(data['user']) : null,
        };
      } else {
        // Erreur
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur. Vérifiez que le backend est accessible.',
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Erreur de format de réponse du serveur.',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Sauvegarder le token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Récupérer le token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Sauvegarder les données utilisateur
  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Récupérer les données utilisateur
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Récupérer les headers avec authentification
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token manquant - utilisateur non connecté');
    }
    return ApiConfig.authHeaders(token);
  }
}