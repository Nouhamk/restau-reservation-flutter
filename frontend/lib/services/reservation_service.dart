import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/reservation_model.dart';
import 'auth_service.dart';

class ReservationService {
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

  /// Créer une nouvelle réservation
  Future<Map<String, dynamic>> createReservation({
    required String reservationDate,
    required String reservationTime,
    required int guests,
    String? notes,
    int? placeId,
  }) async {
    final url = Uri.parse('$_base/reservations');
    final body = {
      'reservation_date': reservationDate,
      'reservation_time': reservationTime,
      'guests': guests,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (placeId != null) 'place_id': placeId,
    };

    final res = await http.post(
      url,
      headers: await _headers(),
      body: json.encode(body),
    );

    if (res.statusCode == 201) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 400) {
      final error = json.decode(res.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Erreur lors de la création');
    }
    throw Exception('Erreur serveur (${res.statusCode})');
  }

  /// Liste des réservations
  Future<List<Reservation>> listReservations({int? placeId}) async {
    var url = '$_base/reservations';
    if (placeId != null) {
      url += '?place_id=$placeId';
    }

    final res = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((item) => Reservation.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur lors du chargement des réservations');
  }

  /// Modifier une réservation
  Future<void> updateReservation({
    required int id,
    required String reservationDate,
    required String reservationTime,
    required int guests,
    String? notes,
  }) async {
    final url = Uri.parse('$_base/reservations/$id');
    final body = {
      'reservation_date': reservationDate,
      'reservation_time': reservationTime,
      'guests': guests,
      if (notes != null) 'notes': notes,
    };

    final res = await http.put(
      url,
      headers: await _headers(),
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Erreur lors de la modification');
    }
  }

  /// Annuler une réservation (client)
  Future<void> cancelReservation(int id) async {
    final url = Uri.parse('$_base/reservations/$id');
    final res = await http.delete(url, headers: await _headers());

    if (res.statusCode != 200) {
      final error = json.decode(res.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Erreur lors de l\'annulation');
    }
  }

  /// Changer le statut d'une réservation (host/admin: confirmed, rejected)
  Future<void> updateStatus(int id, String status) async {
    final url = Uri.parse('$_base/reservations/$id/status');
    final body = {'status': status};

    final res = await http.patch(
      url,
      headers: await _headers(),
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Erreur lors de la mise à jour du statut');
    }
  }

  /// Obtenir les créneaux horaires disponibles
  Future<List<TimeSlot>> getTimeSlots() async {
    final url = Uri.parse('$_base/time-slots');
    final res = await http.get(url, headers: await _headers());

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((item) => TimeSlot.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur lors du chargement des créneaux');
  }

  /// Vérifier la disponibilité pour une date et heure données
  Future<Availability> checkAvailability({
    required String date,
    required String time,
    int? placeId,
  }) async {
    var url = '$_base/time-slots/availability?date=$date&time=$time';
    if (placeId != null) {
      url += '&place_id=$placeId';
    }

    final res = await http.get(Uri.parse(url), headers: await _headers());

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return Availability.fromJson(data);
    }
    throw Exception('Erreur lors de la vérification de disponibilité');
  }
}