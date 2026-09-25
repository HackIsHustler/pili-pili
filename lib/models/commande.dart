class Commande {
  final int? id;
  final String numeroCommande;
  final int? utilisateurId;
  final String? deviceId;
  final int? tableId;
  final String type; // "sur_place", "livraison", "a_emporter"
  final String statut; // "en_attente", "en_preparation", "termine", "annule", "livre"
  final double total;
  final String? adresseLivraison;
  final String? modePaiement; // "espece", "carte", "mobile_money"
  final DateTime? dateDebutPreparation;
  final int? dureeEstimeeMinutes;
  final DateTime createdAt;

  Commande({
    this.id,
    required this.numeroCommande,
    this.utilisateurId,
    this.deviceId,
    this.tableId,
    required this.type,
    required this.statut,
    required this.total,
    this.adresseLivraison,
    this.modePaiement,
    this.dateDebutPreparation,
    this.dureeEstimeeMinutes,
    required this.createdAt,
  });

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'],
      numeroCommande: map['numeroCommande'],
      utilisateurId: map['utilisateurId'],
      deviceId: map['deviceId'],
      tableId: map['tableId'],
      type: map['type'],
      statut: map['statut'],
      total: map['total'].toDouble(),
      adresseLivraison: map['adresseLivraison'],
      modePaiement: map['modePaiement'],
      dateDebutPreparation: map['dateDebutPreparation'] != null ? DateTime.parse(map['dateDebutPreparation']) : null,
      dureeEstimeeMinutes: map['dureeEstimeeMinutes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroCommande': numeroCommande,
      'utilisateurId': utilisateurId,
      'deviceId': deviceId,
      'tableId': tableId,
      'type': type,
      'statut': statut,
      'total': total,
      'adresseLivraison': adresseLivraison,
      'modePaiement': modePaiement,
      'dateDebutPreparation': dateDebutPreparation?.toIso8601String(),
      'dureeEstimeeMinutes': dureeEstimeeMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DateTime? get dateFinEstimee {
    if (dateDebutPreparation == null || dureeEstimeeMinutes == null) {
      return null;
    }
    return dateDebutPreparation!.add(Duration(minutes: dureeEstimeeMinutes!));
  }

  Duration? get tempsRestant {
    final fin = dateFinEstimee;
    if (fin == null) return null;
    final diff = fin.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get estExpiree {
    final fin = dateFinEstimee;
    return fin != null && DateTime.now().isAfter(fin);
  }
}