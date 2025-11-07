/// Configuration de l'API Backend
class ApiConfig {
  // URL de base de l'API
  static const String baseUrl = 'https://restau-api.67gigs.codes/api';

  // Pour développement local
  static const String baseUrlLocal = 'http://localhost:3000/api';

  // Pour émulateur Android si backend en local
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:3000/api';

  // Endpoints
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String userEndpoint = '/user';
  static const String reservationsEndpoint = '/reservations';
  static const String menuEndpoint = '/menu';
  static const String placesEndpoint = '/places';
  static const String timeSlotsEndpoint = '/time-slots';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec authentification
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}