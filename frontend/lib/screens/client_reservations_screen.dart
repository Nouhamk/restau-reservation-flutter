import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';

/// Écran de gestion des réservations pour les CLIENTS
class ClientReservationsScreen extends StatefulWidget {
  const ClientReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ClientReservationsScreen> createState() => _ClientReservationsScreenState();
}

class _ClientReservationsScreenState extends State<ClientReservationsScreen> {
  final _reservationService = ReservationService();
  final _authService = AuthService();
  final _adminService = AdminService();
  
  List<Reservation> _reservations = [];
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getUser();
      final reservations = await _reservationService.listReservations();
      final places = await _adminService.getPlaces();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _reservations = reservations;
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

  Future<void> _createReservation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReservationScreen(places: _places),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editReservation(Reservation reservation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditReservationScreen(
          reservation: reservation,
          places: _places,
        ),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler la réservation ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elegantBurgundy,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reservationService.cancelReservation(reservation.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réservation annulée')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 80, color: AppTheme.mediumGrey),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune réservation',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _createReservation,
                            icon: const Icon(Icons.add),
                            label: const Text('Nouvelle réservation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.roseGold,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = _reservations[index];
                        return _buildReservationCard(reservation);
                      },
                    ),
            ),
      floatingActionButton: _reservations.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createReservation,
              backgroundColor: AppTheme.roseGold,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle réservation'),
            )
          : null,
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
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

    final canEdit = reservation.status == 'pending';
    final canCancel = reservation.status == 'pending' || reservation.status == 'confirmed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: AppTheme.deepNavy),
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
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppTheme.mediumGrey),
                const SizedBox(width: 8),
                Text(reservation.formattedDate, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 24),
                Icon(Icons.access_time, size: 18, color: AppTheme.mediumGrey),
                const SizedBox(width: 8),
                Text(reservation.formattedTime, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 18, color: AppTheme.mediumGrey),
                const SizedBox(width: 8),
                Text('${reservation.guests} personne${reservation.guests > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 18, color: AppTheme.mediumGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.notes!,
                      style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
                    ),
                  ),
                ],
              ),
            ],
            if (canEdit || canCancel) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canEdit)
                    TextButton.icon(
                      onPressed: () => _editReservation(reservation),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.deepNavy,
                      ),
                    ),
                  if (canCancel) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _cancelReservation(reservation),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Annuler'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.elegantBurgundy,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Écran pour créer une nouvelle réservation
class CreateReservationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> places;

  const CreateReservationScreen({Key? key, required this.places}) : super(key: key);

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _reservationService = ReservationService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  int? _selectedPlaceId;
  int _guests = 2;
  String _notes = '';
  
  List<TimeSlot> _timeSlots = [];
  Availability? _availability;
  bool _isLoadingSlots = true;
  bool _isCheckingAvailability = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    try {
      final slots = await _reservationService.getTimeSlots();
      if (mounted) {
        setState(() {
          _timeSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement créneaux: $e')),
        );
      }
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    setState(() => _isCheckingAvailability = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final availability = await _reservationService.checkAvailability(
        date: dateStr,
        time: _selectedTimeSlot!.slotTime,
        placeId: _selectedPlaceId,
      );

      if (mounted) {
        setState(() {
          _availability = availability;
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingAvailability = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date et un créneau')),
      );
      return;
    }

    if (_availability == null || !_availability!.isAvailable || _availability!.available < _guests) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Places insuffisantes pour ce créneau')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      await _reservationService.createReservation(
        reservationDate: dateStr,
        reservationTime: _selectedTimeSlot!.slotTime,
        guests: _guests,
        notes: _notes.isNotEmpty ? _notes : null,
        placeId: _selectedPlaceId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation créée avec succès')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Nouvelle Réservation'),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingSlots
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Sélection du restaurant
                  if (widget.places.isNotEmpty) ...[
                    const Text(
                      'Restaurant',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.lightGrey),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedPlaceId,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          hintText: 'Sélectionner un restaurant',
                        ),
                        items: widget.places.map((place) {
                          return DropdownMenuItem<int>(
                            value: place['id'] as int,
                            child: Text(place['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPlaceId = value;
                            _availability = null;
                          });
                          _checkAvailability();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sélection de la date
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppTheme.deepNavy,
                                onPrimary: Colors.white,
                                onSurface: AppTheme.darkText,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                          _availability = null;
                        });
                        _checkAvailability();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.lightGrey),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppTheme.deepNavy),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'Sélectionner une date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate != null ? AppTheme.darkText : AppTheme.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sélection du créneau horaire
                  const Text(
                    'Créneau horaire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot?.id == slot.id;
                      return ChoiceChip(
                        label: Text(slot.formattedTime),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeSlot = selected ? slot : null;
                            _availability = null;
                          });
                          _checkAvailability();
                        },
                        selectedColor: AppTheme.roseGold,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Nombre de couverts
                  const Text(
                    'Nombre de personnes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _guests > 1
                              ? () {
                                  setState(() => _guests--);
                                  _checkAvailability();
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.deepNavy,
                        ),
                        Text(
                          '$_guests personne${_guests > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _guests++);
                            _checkAvailability();
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.deepNavy,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Disponibilité
                  if (_isCheckingAvailability)
                    const Center(child: CircularProgressIndicator())
                  else if (_availability != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _availability!.isAvailable && _availability!.available >= _guests
                            ? AppTheme.sageGreen.withOpacity(0.1)
                            : AppTheme.elegantBurgundy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _availability!.isAvailable && _availability!.available >= _guests
                              ? AppTheme.sageGreen
                              : AppTheme.elegantBurgundy,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _availability!.isAvailable && _availability!.available >= _guests
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _availability!.isAvailable && _availability!.available >= _guests
                                ? AppTheme.sageGreen
                                : AppTheme.elegantBurgundy,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _availability!.isAvailable && _availability!.available >= _guests
                                  ? '${_availability!.available} place${_availability!.available > 1 ? 's' : ''} disponible${_availability!.available > 1 ? 's' : ''}'
                                  : 'Places insuffisantes (${_availability!.available} disponible${_availability!.available > 1 ? 's' : ''})',
                              style: TextStyle(
                                color: _availability!.isAvailable && _availability!.available >= _guests
                                    ? AppTheme.sageGreen
                                    : AppTheme.elegantBurgundy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  const Text(
                    'Notes (optionnel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Allergies, préférences de table...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.lightGrey),
                      ),
                    ),
                    onChanged: (value) => _notes = value,
                  ),
                  const SizedBox(height: 32),

                  // Bouton de réservation
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.roseGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Confirmer la réservation',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Écran pour modifier une réservation existante
class EditReservationScreen extends StatefulWidget {
  final Reservation reservation;
  final List<Map<String, dynamic>> places;

  const EditReservationScreen({
    Key? key,
    required this.reservation,
    required this.places,
  }) : super(key: key);

  @override
  State<EditReservationScreen> createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final _reservationService = ReservationService();
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _selectedDate;
  TimeSlot? _selectedTimeSlot;
  late int _guests;
  late String _notes;
  
  List<TimeSlot> _timeSlots = [];
  Availability? _availability;
  bool _isLoadingSlots = true;
  bool _isCheckingAvailability = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.reservation.reservationDate);
    _guests = widget.reservation.guests;
    _notes = widget.reservation.notes ?? '';
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    try {
      final slots = await _reservationService.getTimeSlots();
      if (mounted) {
        setState(() {
          _timeSlots = slots;
          _selectedTimeSlot = slots.firstWhere(
            (slot) => slot.slotTime == widget.reservation.reservationTime,
            orElse: () => slots.first,
          );
          _isLoadingSlots = false;
        });
        _checkAvailability();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedTimeSlot == null) return;

    setState(() => _isCheckingAvailability = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final availability = await _reservationService.checkAvailability(
        date: dateStr,
        time: _selectedTimeSlot!.slotTime,
        placeId: widget.reservation.placeId,
      );

      if (mounted) {
        setState(() {
          _availability = availability;
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingAvailability = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimeSlot == null) return;

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await _reservationService.updateReservation(
        id: widget.reservation.id!,
        reservationDate: dateStr,
        reservationTime: _selectedTimeSlot!.slotTime,
        guests: _guests,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation modifiée')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Modifier la Réservation'),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingSlots
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Date
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                          _availability = null;
                        });
                        _checkAvailability();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.lightGrey),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppTheme.deepNavy),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Créneau horaire
                  const Text(
                    'Créneau horaire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot?.id == slot.id;
                      return ChoiceChip(
                        label: Text(slot.formattedTime),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeSlot = selected ? slot : null;
                            _availability = null;
                          });
                          _checkAvailability();
                        },
                        selectedColor: AppTheme.roseGold,
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Nombre de personnes
                  const Text(
                    'Nombre de personnes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_guests personne${_guests > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setState(() => _guests++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Disponibilité
                  if (_isCheckingAvailability)
                    const Center(child: CircularProgressIndicator())
                  else if (_availability != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _availability!.available >= _guests
                            ? AppTheme.sageGreen.withOpacity(0.1)
                            : AppTheme.elegantBurgundy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_availability!.available} place${_availability!.available > 1 ? 's' : ''} disponible${_availability!.available > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: _availability!.available >= _guests
                              ? AppTheme.sageGreen
                              : AppTheme.elegantBurgundy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) => _notes = value,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.roseGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Enregistrer les modifications',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}