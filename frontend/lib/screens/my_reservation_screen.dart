import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await _authService.getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/reservations');

      final response = await http.get(uri, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['reservations'] is List) {
          list = data['reservations'];
        } else {
          list = [];
        }

        setState(() {
          _reservations =
              list.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Session expirée → retour au login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.'),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des réservations';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de contacter le serveur.';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.accentGold.withOpacity(0.3)),
        ),
        title: const Text(
          'Annuler la réservation',
          style: TextStyle(color: AppTheme.accentGold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ?',
          style: TextStyle(color: AppTheme.creamWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warmRed,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final headers = await _authService.getAuthHeaders();
      final uri =
          Uri.parse('${ApiConfig.baseUrl}/api/reservations/${reservation.id}');

      final response = await http.delete(uri, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée avec succès')),
        );
        _loadReservations();
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Session expirée. Veuillez vous reconnecter.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'annulation')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Impossible de contacter le serveur.')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.deepGreen;
      case 'pending':
        return Colors.orangeAccent;
      case 'cancelled':
        return AppTheme.warmRed;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: AppTheme.backgroundDark,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _loadReservations,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentGold,
                  ),
                )
              : _errorMessage != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.creamWhite,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : _reservations.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'Vous n\'avez aucune réservation pour le moment.',
                                style: TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reservations.length,
                          itemBuilder: (context, index) {
                            final r = _reservations[index];
                            return _buildReservationCard(r);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation r) {
    final statusColor = _statusColor(r.status);
    final canCancel = r.status.toLowerCase() != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.leatherShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne du haut : date / heure / statut
            Row(
              children: [
                Icon(Icons.calendar_month,
                    color: AppTheme.accentGold.withOpacity(0.9)),
                const SizedBox(width: 8),
                Text(
                  '${r.formattedDate} • ${r.formattedTime}',
                  style: const TextStyle(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    _statusLabel(r.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nombre de personnes
            Row(
              children: [
                Icon(Icons.people,
                    color: AppTheme.accentGold.withOpacity(0.9), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${r.guests} personne${r.guests > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppTheme.creamWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),

            if (r.placeId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppTheme.accentGold.withOpacity(0.9), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Salle / lieu #${r.placeId}',
                    style: TextStyle(
                      color: AppTheme.creamWhite.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],

            if (r.notes != null && r.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note,
                      color: AppTheme.accentGold.withOpacity(0.9), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.notes!,
                      style: TextStyle(
                        color: AppTheme.creamWhite.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Bouton annuler
            if (canCancel)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancelReservation(r),
                  icon: const Icon(Icons.cancel, color: AppTheme.warmRed),
                  label: const Text(
                    'Annuler la réservation',
                    style: TextStyle(color: AppTheme.warmRed),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Reservation {
  final int id;
  final String reservationDate;
  final String reservationTime;
  final int guests;
  final String status;
  final String? notes;
  final int? placeId;

  Reservation({
    required this.id,
    required this.reservationDate,
    required this.reservationTime,
    required this.guests,
    required this.status,
    this.notes,
    this.placeId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      reservationDate: json['reservation_date'] ?? '',
      reservationTime: json['reservation_time'] ?? '',
      guests: json['guests'] is int
          ? json['guests']
          : int.tryParse(json['guests'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      placeId: json['place_id'] == null
          ? null
          : (json['place_id'] is int
              ? json['place_id']
              : int.tryParse(json['place_id'].toString())),
    );
  }

  String get formattedDate {
    final parts = reservationDate.split('-'); // yyyy-mm-dd
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return reservationDate;
  }

  String get formattedTime {
    if (reservationTime.length >= 5) {
      return reservationTime.substring(0, 5); // HH:mm
    }
    return reservationTime;
  }
}
