class Commande {
  final int? id;
  final String numeroCommande;
  final int? utilisateurId;
  final int? tableId;
  final String type; // "sur_place", "livraison", "a_emporter"
  final String statut; // "en_attente", "en_preparation", "termine", "annule", "livre"
  final double total;
  final String? adresseLivraison;
  final DateTime createdAt;

  Commande({
    this.id,
    required this.numeroCommande,
    this.utilisateurId,
    this.tableId,
    required this.type,
    required this.statut,
    required this.total,
    this.adresseLivraison,
    required this.createdAt,
  });

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'],
      numeroCommande: map['numeroCommande'],
      utilisateurId: map['utilisateurId'],
      tableId: map['tableId'],
      type: map['type'],
      statut: map['statut'],
      total: map['total'].toDouble(),
      adresseLivraison: map['adresseLivraison'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroCommande': numeroCommande,
      'utilisateurId': utilisateurId,
      'tableId': tableId,
      'type': type,
      'statut': statut,
      'total': total,
      'adresseLivraison': adresseLivraison,
      'created_at': createdAt.toIso8601String(),
    };
  }
}