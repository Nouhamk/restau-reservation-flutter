import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';

/// Écran de gestion des réservations pour les HÔTES
class HostReservationsScreen extends StatefulWidget {
  final int? placeId;

  const HostReservationsScreen({Key? key, this.placeId}) : super(key: key);

  @override
  State<HostReservationsScreen> createState() => _HostReservationsScreenState();
}

class _HostReservationsScreenState extends State<HostReservationsScreen> with SingleTickerProviderStateMixin {
  final _reservationService = ReservationService();
  final _adminService = AdminService();
  
  late TabController _tabController;
  List<Reservation> _allReservations = [];
  List<Map<String, dynamic>> _places = [];
  int? _selectedPlaceId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedPlaceId = widget.placeId;
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reservations = await _reservationService.listReservations(
        placeId: _selectedPlaceId,
      );
      final places = await _adminService.getPlaces();
      
      if (mounted) {
        setState(() {
          _allReservations = reservations;
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  List<Reservation> get _pendingReservations =>
      _allReservations.where((r) => r.status == 'pending').toList();

  List<Reservation> get _confirmedReservations =>
      _allReservations.where((r) => r.status == 'confirmed').toList();

  List<Reservation> get _rejectedCancelledReservations =>
      _allReservations.where((r) => r.status == 'rejected' || r.status == 'cancelled').toList();

  Future<void> _updateStatus(Reservation reservation, String newStatus) async {
    try {
      await _reservationService.updateStatus(reservation.id!, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'confirmed' 
                ? 'Réservation confirmée' 
                : 'Réservation refusée',
            ),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmReservation(Reservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la réservation ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${reservation.userName ?? 'N/A'}'),
            Text('Date: ${reservation.formattedDate}'),
            Text('Heure: ${reservation.formattedTime}'),
            Text('Personnes: ${reservation.guests}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sageGreen,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _updateStatus(reservation, 'confirmed');
    }
  }

  Future<void> _rejectReservation(Reservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refuser la réservation ?'),
        content: const Text('Le client sera notifié par email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elegantBurgundy,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _updateStatus(reservation, 'rejected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Gestion des Réservations'),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.roseGold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('En attente'),
                  if (_pendingReservations.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.champagne,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingReservations.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Confirmées'),
            const Tab(text: 'Refusées'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtre par restaurant
          if (_places.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: AppTheme.deepNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedPlaceId,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                        labelText: 'Restaurant',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Tous les restaurants'),
                        ),
                        ..._places.map((place) {
                          return DropdownMenuItem<int?>(
                            value: place['id'] as int,
                            child: Text(place['name'] as String),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPlaceId = value);
                        _loadData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReservationsList(_pendingReservations, showActions: true),
                        _buildReservationsList(_confirmedReservations),
                        _buildReservationsList(_rejectedCancelledReservations),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations, {bool showActions = false}) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppTheme.mediumGrey),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(fontSize: 16, color: AppTheme.mediumGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _buildReservationCard(reservation, showActions: showActions);
      },
    );
  }

  Widget _buildReservationCard(Reservation reservation, {bool showActions = false}) {
    final placeName = _places.firstWhere(
      (p) => p['id'] == reservation.placeId,
      orElse: () => {'name': 'Restaurant'},
    )['name'];

    Color statusColor;
    IconData statusIcon;
    switch (reservation.status) {
      case 'confirmed':
        statusColor = AppTheme.sageGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.champagne;
        statusIcon = Icons.schedule;
        break;
      case 'rejected':
        statusColor = AppTheme.elegantBurgundy;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = AppTheme.mediumGrey;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = AppTheme.mediumGrey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec restaurant et statut
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: AppTheme.deepNavy, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            reservation.statusLabel,
                            style: TextStyle(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Informations client
            _buildInfoRow(
              Icons.person,
              'Client',
              reservation.userName ?? 'N/A',
            ),
            const SizedBox(height: 8),
            if (reservation.userEmail != null)
              _buildInfoRow(
                Icons.email,
                'Email',
                reservation.userEmail!,
              ),
            const SizedBox(height: 8),
            if (reservation.userPhone != null)
              _buildInfoRow(
                Icons.phone,
                'Téléphone',
                reservation.userPhone!,
              ),
            const Divider(height: 24),

            // Détails de la réservation
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    reservation.formattedDate,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.access_time,
                    'Heure',
                    reservation.formattedTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.people,
              'Personnes',
              '${reservation.guests} personne${reservation.guests > 1 ? 's' : ''}',
            ),
            
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.champagne.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.champagne.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 18, color: AppTheme.mediumGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.notes!,
                        style: TextStyle(fontSize: 14, color: AppTheme.darkText),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectReservation(reservation),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.elegantBurgundy,
                        side: BorderSide(color: AppTheme.elegantBurgundy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmReservation(reservation),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sageGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mediumGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}