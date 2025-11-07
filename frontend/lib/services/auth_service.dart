import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Pour émulateur Android (localhost)

  // Stockage sécurisé pour le token
  final _storage = const FlutterSecureStorage();

  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? nom,
    String? telephone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nom': nom,
          'telephone': telephone,
        }),
      );

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
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

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
          'message': data['message'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
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
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}