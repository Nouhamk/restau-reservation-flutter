/// Modèle représentant un lieu/restaurant (branche)
class Place {
  final int? id;
  final String name;
  final String address;
  final String? phone;
  final int? capacity;
  final DateTime? createdAt;

  Place({
    this.id,
    required this.name,
    required this.address,
    this.phone,
    this.capacity,
    this.createdAt,
  });

  /// Créer un Place depuis un JSON (réponse API)
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int?,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      capacity: json['capacity'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convertir un Place en JSON (pour envoyer à l'API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (capacity != null) 'capacity': capacity,
    };
  }

  /// Copier un Place avec des modifications
  Place copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    int? capacity,
    DateTime? createdAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
