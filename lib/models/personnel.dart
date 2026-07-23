class Personnel {
  final int? id;
  final int utilisateurId;
  final String role; // "admin", "serveur", "cuisinier", "livreur"
  final int? restaurantId; // Si plusieurs restaurants plus tard
  final bool actif;
  final DateTime createdAt;

  Personnel({
    this.id,
    required this.utilisateurId,
    required this.role,
    this.restaurantId,
    this.actif = true,
    required this.createdAt,
  });

  factory Personnel.fromMap(Map<String, dynamic> map) {
    return Personnel(
      id: map['id'],
      utilisateurId: map['utilisateurId'],
      role: map['role'],
      restaurantId: map['restaurantId'],
      actif: map['actif'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'role': role,
      'restaurantId': restaurantId,
      'actif': actif ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}