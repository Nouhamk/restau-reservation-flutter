class Reservation {
  final int? id;
  final int userId;
  final String reservationDate;
  final String reservationTime;
  final int guests;
  final String status;
  final String? notes;
  final int? placeId;
  final String? placeName;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    this.id,
    required this.userId,
    required this.reservationDate,
    required this.reservationTime,
    required this.guests,
    this.status = 'pending',
    this.notes,
    this.placeId,
    this.placeName,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      reservationDate: json['reservation_date'] as String,
      reservationTime: json['reservation_time'] as String,
      guests: json['guests'] as int,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      placeId: json['place_id'] as int?,
      placeName: json['place_name'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'reservation_date': reservationDate,
      'reservation_time': reservationTime,
      'guests': guests,
      'status': status,
      if (notes != null) 'notes': notes,
      if (placeId != null) 'place_id': placeId,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'rejected':
        return 'Refusée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(reservationDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return reservationDate;
    }
  }

  String get formattedTime {
    try {
      final parts = reservationTime.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return reservationTime;
    }
  }
}

class TimeSlot {
  final int id;
  final String slotTime;
  final int maxCapacity;

  TimeSlot({
    required this.id,
    required this.slotTime,
    required this.maxCapacity,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as int,
      slotTime: json['slot_time'] as String,
      maxCapacity: json['max_capacity'] as int,
    );
  }

  String get formattedTime {
    try {
      final parts = slotTime.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return slotTime;
    }
  }
}

class Availability {
  final int maxCapacity;
  final int reserved;
  final int available;

  Availability({
    required this.maxCapacity,
    required this.reserved,
    required this.available,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      maxCapacity: json['maxCapacity'] as int,
      reserved: json['reserved'] as int,
      available: json['available'] as int,
    );
  }

  bool get isAvailable => available > 0;
}