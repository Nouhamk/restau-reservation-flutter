/// Modèle représentant un utilisateur
class User {
  final int? id;
  final String email;
  final String? nom;
  final String? telephone;
  final String? role;

  User({
    this.id,
    required this.email,
    this.nom,
    this.telephone,
    this.role,
  });

  /// Créer un User depuis un JSON (réponse API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String,
      nom: json['nom'] as String?,
      telephone: json['telephone'] as String?,
      role: json['role'] as String?,
    );
  }

  /// Convertir un User en JSON (pour envoyer à l'API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'telephone': telephone,
      'role': role,
    };
  }

  /// Copier un User avec des modifications
  User copyWith({
    int? id,
    String? email,
    String? nom,
    String? telephone,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
    );
  }
}
