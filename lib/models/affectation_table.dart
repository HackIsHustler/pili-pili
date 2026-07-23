class AffectationTable {
  final int? id;
  final int tableId;
  final int utilisateurId; // Serveur
  final DateTime dateDebut;
  final DateTime? dateFin;

  AffectationTable({
    this.id,
    required this.tableId,
    required this.utilisateurId,
    required this.dateDebut,
    this.dateFin,
  });

  factory AffectationTable.fromMap(Map<String, dynamic> map) {
    return AffectationTable(
      id: map['id'],
      tableId: map['tableId'],
      utilisateurId: map['utilisateurId'],
      dateDebut: DateTime.parse(map['dateDebut']),
      dateFin: map['dateFin'] != null ? DateTime.parse(map['dateFin']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableId': tableId,
      'utilisateurId': utilisateurId,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
    };
  }
}