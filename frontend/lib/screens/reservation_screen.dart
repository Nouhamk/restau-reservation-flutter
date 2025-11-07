import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservationPage extends StatefulWidget {
  final String authToken;
  final String baseUrl;

  const ReservationPage({
    super.key,
    required this.authToken,
    required this.baseUrl,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  int _guests = 2;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Limitations de l'utilisateur
  int _activeReservations = 0;
  int _remainingSlots = 3;
  bool _isLoadingLimits = true;

  final List<String> _timeSlots = [
    '12:00:00', '12:30:00', '13:00:00', 
    '19:00:00', '19:30:00', '20:00:00', 
    '20:30:00', '21:00:00', '21:30:00'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLimits();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLimits() async {
    try {
      final Uri uri = Uri.parse('${widget.baseUrl}/api/reservations/limits');
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (widget.authToken.isNotEmpty)
          'Authorization': 'Bearer ${widget.authToken}',
      };

      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _activeReservations = data['activeReservations'] ?? 0;
            _remainingSlots = data['remainingSlots'] ?? 3;
            _isLoadingLimits = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingLimits = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLimits = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF92400E),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
      if (_selectedTime != null) {
        _checkAvailability();
      }
    }
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _selectedTime == null) return;

    try {
      final Uri uri = Uri.parse(
        '${widget.baseUrl}/api/availability?date=${_formatDateForApi(_selectedDate!)}&time=$_selectedTime&place_id=1'
      );

      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final available = data['available'] ?? 0;
        final maxCapacity = data['maxCapacity'] ?? 0;
        final reserved = data['reserved'] ?? 0;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                available > 0 
                  ? '✓ $available places disponibles sur $maxCapacity'
                  : '✗ Complet ($reserved/$maxCapacity)',
              ),
              backgroundColor: available > 0 
                ? Colors.green.shade700 
                : Colors.red.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner une date et un horaire';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final Uri uri = Uri.parse('${widget.baseUrl}/api/reservations');
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (widget.authToken.isNotEmpty)
          'Authorization': 'Bearer ${widget.authToken}',
      };

      final Map<String, dynamic> bodyMap = {
        'reservation_date': _formatDateForApi(_selectedDate!),
        'reservation_time': _selectedTime,
        'guests': _guests,
        'notes': _notesController.text.trim(),
        'place_id': 1,
      };

      final http.Response response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reservationId = data['reservationId']?.toString() ?? '';
        
        // Recharger les limites après succès
        await _loadUserLimits();
        
        setState(() {
          _successMessage = reservationId.isNotEmpty
            ? '🎉 Réservation #$reservationId créée avec succès !\n\n'
              'Votre table pour $_guests personne${_guests > 1 ? 's' : ''} le '
              '${_selectedDate!.day.toString().padLeft(2, '0')}/'
              '${_selectedDate!.month.toString().padLeft(2, '0')} à '
              '${_selectedTime!.substring(0, 5)} est en attente de confirmation.\n\n'
              'Vous serez contacté au ${_phoneController.text}.'
            : '🎉 Réservation créée avec succès !\n\n'
              'Elle est en attente de confirmation. '
              'Vous serez contacté rapidement.';
          _selectedDate = null;
          _selectedTime = null;
          _guests = 2;
          _phoneController.clear();
          _notesController.clear();
        });

        // Auto-scroll to top to show success message
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Scrollable.ensureVisible(
              _formKey.currentContext!,
              duration: const Duration(milliseconds: 300),
            );
          }
        });
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        String message = 'Erreur lors de la réservation';
        
        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            message = data['error'].toString();
            
            // Ajouter info sur places disponibles si fourni
            if (data['available'] != null) {
              final available = data['available'];
              message += '\n\nℹ️ Il reste $available place${available > 1 ? 's' : ''} disponible${available > 1 ? 's' : ''} pour ce créneau.';
            }
          }
        }
        
        setState(() => _errorMessage = message);
      } else if (response.statusCode == 401) {
        setState(() => _errorMessage = 
          '🔒 Session expirée. Veuillez vous reconnecter.');
        
        // Rediriger vers login après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        String message = 'Erreur lors de la réservation';
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic> && data['error'] != null) {
            message = data['error'].toString();
          } else if (data is Map<String, dynamic> && data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}
        setState(() => _errorMessage = '❌ $message');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 
        '🌐 Impossible de contacter le serveur.\n\n'
        'Vérifiez votre connexion internet et réessayez.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const amber900 = Color(0xFF78350F);
    const amber700 = Color(0xFF92400E);
    const amber50 = Color(0xFFFFFBEB);
    const orange50 = Color(0xFFFFF7ED);

    return Scaffold(
      backgroundColor: orange50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: amber900,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Réserver une table',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [amber900, const Color(0xFF991B1B)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      Icon(Icons.restaurant_menu, 
                          size: 48, color: Colors.white70),
                      SizedBox(height: 8),
                      Text(
                        'Les AL',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Pub Anglais Authentique',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [amber700, const Color(0xFF991B1B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: amber700.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.celebration, 
                            size: 40, color: Colors.white70),
                        SizedBox(height: 12),
                        Text(
                          'Réservez votre moment convivial',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'serif',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'dans notre authentique pub anglais',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Compteur de réservations
                  if (!_isLoadingLimits)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _remainingSlots > 0 
                          ? Colors.blue.shade50 
                          : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _remainingSlots > 0
                            ? Colors.blue.shade200
                            : Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _remainingSlots > 0 
                              ? Icons.info_outline 
                              : Icons.warning_amber_rounded,
                            color: _remainingSlots > 0
                              ? Colors.blue.shade700
                              : Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _remainingSlots > 0
                                    ? 'Réservations disponibles'
                                    : 'Limite atteinte',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _remainingSlots > 0
                                      ? Colors.blue.shade900
                                      : Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _remainingSlots > 0
                                    ? '$_remainingSlots créneaux restants sur 3'
                                    : 'Vous avez 3 réservations actives. '
                                      'Annulez-en une pour réserver à nouveau.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _remainingSlots > 0
                                      ? Colors.blue.shade700
                                      : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Messages
                          if (_successMessage != null)
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Date
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, 
                                        size: 18, color: amber700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Date de réservation',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.event, color: amber700),
                                        const SizedBox(width: 12),
                                        Text(
                                          _selectedDate == null
                                              ? 'Sélectionner une date'
                                              : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                                  '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                                  '${_selectedDate!.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _selectedDate == null
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time Slots
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, 
                                        size: 18, color: amber700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Horaire',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _timeSlots.map((time) {
                                    final isSelected = _selectedTime == time;
                                    final displayTime = time.substring(0, 5);
                                    
                                    return InkWell(
                                      onTap: () {
                                        setState(() => _selectedTime = time);
                                        _checkAvailability();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? amber700 
                                              : Colors.grey.shade100,
                                          borderRadius: 
                                              BorderRadius.circular(12),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: amber700
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: 
                                                        const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          displayTime,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Guests
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.people, 
                                        size: 18, color: amber700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Nombre de personnes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int>(
                                  value: _guests,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: 
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: List.generate(8, (i) => i + 1)
                                      .map((num) => DropdownMenuItem(
                                            value: num,
                                            child: Text(
                                              '$num personne${num > 1 ? 's' : ''}',
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) => setState(() => 
                                      _guests = val!),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Phone
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.phone, 
                                        size: 18, color: amber700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Téléphone',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: 06 01 02 03 04',
                                    border: OutlineInputBorder(
                                      borderRadius: 
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Téléphone requis';
                                    }
                                    if (val.trim().length < 8) {
                                      return 'Numéro trop court';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Notes
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.note, 
                                        size: 18, color: amber700),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Notes spéciales (optionnel)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _notesController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Allergies, préférences...',
                                    border: OutlineInputBorder(
                                      borderRadius: 
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (_isSubmitting || _remainingSlots <= 0) 
                                    ? null 
                                    : _submitReservation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: amber700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: 
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_outline),
                                          SizedBox(width: 8),
                                          Text(
                                            'Confirmer la réservation',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Votre réservation sera en attente de validation. '
                              'Vous serez notifié par téléphone.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Features
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [amber50, orange50],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildFeature('🍺', 
                                    'Cuisine traditionnelle & moderne'),
                                const SizedBox(height: 12),
                                _buildFeature('🍷', 
                                    'Large sélection de bières & vins'),
                                const SizedBox(height: 12),
                                _buildFeature('🎵', 
                                    'Ambiance chaleureuse & conviviale'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}