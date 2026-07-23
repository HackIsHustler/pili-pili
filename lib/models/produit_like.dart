class ProduitLike {
  final int? id;
  final int produitId;
  final String? deviceId;
  final int? utilisateurId;
  final DateTime createdAt;

  ProduitLike({
    this.id,
    required this.produitId,
    this.utilisateurId,
    this.deviceId,
    required this.createdAt,
  });

  factory ProduitLike.fromMap(Map<String, dynamic> map) {
    return ProduitLike(
      id: map['id'],
      produitId: map['produitId'],
      deviceId: map['deviceId'],
      utilisateurId: map['utilisateurId'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produitId': produitId,
      'deviceId': deviceId,
      'utilisateurId': utilisateurId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}