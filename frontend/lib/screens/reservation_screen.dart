import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservationPage extends StatefulWidget {
  final String authToken; // JWT éventuel
  final String baseUrl;   // ex: http://localhost:3000

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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guests = 2;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 30),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _formatDateForApi(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTimeForApi(TimeOfDay time) {
    final String h = time.hour.toString().padLeft(2, '0');
    final String m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Veuillez choisir une date et un horaire.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final String reservationDate = _formatDateForApi(_selectedDate!);
    final String reservationTime = _formatTimeForApi(_selectedTime!);

    try {
      // ⚠️ adapte ici si ton back utilise /api/reservations
      final Uri uri = Uri.parse('${widget.baseUrl}/reservations');

      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
        if (widget.authToken.isNotEmpty)
          'Authorization': 'Bearer ${widget.authToken}',
      };

      final Map<String, dynamic> bodyMap = <String, dynamic>{
        'reservation_date': reservationDate,
        'reservation_time': reservationTime,
        'guests': _guests,
        'phone': _phoneController.text.trim(),
      };

      final String bodyJson = jsonEncode(bodyMap);

      final http.Response response =
          await http.post(uri, headers: headers, body: bodyJson);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        String? reservationId;

        try {
          final dynamic data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            reservationId =
                data['reservation']?['id']?.toString() ?? data['id']?.toString();
          }
        } catch (_) {
          // ignore JSON errors
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reservationId != null
                  ? 'Réservation #$reservationId créée avec succès.\nElle est en attente de confirmation.'
                  : 'Réservation créée avec succès.\nElle est en attente de confirmation.',
            ),
          ),
        );

        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _guests = 2;
          _phoneController.clear();
        });
      } else if (response.statusCode == 409) {
        setState(() {
          _errorMessage =
              'Le créneau choisi est complet. Veuillez choisir un autre horaire.';
        });
      } else {
        String backendMessage = 'Erreur lors de la réservation.';

        try {
          final dynamic data = jsonDecode(response.body);
          if (data is Map<String, dynamic> && data['message'] != null) {
            backendMessage = data['message'].toString();
          }
        } catch (_) {
          // ignore JSON errors
        }

        setState(() {
          _errorMessage = backendMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Erreur réseau : impossible de contacter le serveur. ($e)';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundBeige = Color(0xFFF5EFE7);
    const Color beigeClair = Color(0xFFFFF7ED);
    const Color bleuNuit = Color(0xFF283546);

    String dateLabel;
    if (_selectedDate == null) {
      dateLabel = 'Choisir une date';
    } else {
      final int d = _selectedDate!.day;
      final int m = _selectedDate!.month;
      final int y = _selectedDate!.year;
      dateLabel =
          '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/$y';
    }

    String timeLabel;
    if (_selectedTime == null) {
      timeLabel = 'Choisir un horaire';
    } else {
      final int h = _selectedTime!.hour;
      final int mn = _selectedTime!.minute;
      timeLabel =
          '${h.toString().padLeft(2, '0')}h${mn.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      backgroundColor: backgroundBeige,
      appBar: AppBar(
        backgroundColor: backgroundBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Réserver une table'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Votre moment au QG Gourmand',
                    style: TextStyle(
                      color: bleuNuit,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choisissez votre créneau, on s’occupe du reste.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: beigeClair,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Détails de la réservation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: bleuNuit,
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: bleuNuit,
                              ),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(dateLabel),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: bleuNuit,
                                side: const BorderSide(
                                  color: Colors.black26,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Horaire',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: bleuNuit,
                              ),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time_rounded),
                              label: Text(timeLabel),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: bleuNuit,
                                side: const BorderSide(
                                  color: Colors.black26,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Nombre de personnes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: bleuNuit,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: _guests,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.black26,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: List<DropdownMenuItem<int>>.generate(
                                8,
                                (int index) {
                                  final int value = index + 1;
                                  final String label =
                                      '$value personne${value == 1 ? '' : 's'}';
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(label),
                                  );
                                },
                              ),
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() {
                                    _guests = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Téléphone',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: bleuNuit,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Ex : 06 01 02 03 04',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le téléphone est obligatoire.';
                                }
                                if (value.trim().length < 8) {
                                  return 'Numéro de téléphone trop court.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _submitReservation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bleuNuit,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Confirmer la réservation',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Votre réservation sera d\'abord en attente de validation. '
                              'Vous serez notifié lorsque le statut passera à "confirmée", "refusée" ou "annulée".',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
