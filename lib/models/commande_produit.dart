class CommandeProduit {
  final int? id;
  final int commandeId;
  final int produitId;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;

  CommandeProduit({
    this.id,
    required this.commandeId,
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal,
  });

  factory CommandeProduit.fromMap(Map<String, dynamic> map) {
    return CommandeProduit(
      id: map['id'],
      commandeId: map['commandeId'],
      produitId: map['produitId'],
      quantite: map['quantite'],
      prixUnitaire: map['prixUnitaire'].toDouble(),
      sousTotal: map['sousTotal'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commandeId': commandeId,
      'produitId': produitId,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
      'sousTotal': sousTotal,
    };
  }
}