class Notification {
  final int? id;
  final int utilisateurId;
  final String type; // "commande", "table", "stock"
  final String message;
  final bool lu;
  final int? commandeId;
  final DateTime createdAt;

  Notification({
    this.id,
    required this.utilisateurId,
    required this.type,
    required this.message,
    this.lu = false,
    this.commandeId,
    required this.createdAt,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      utilisateurId: map['utilisateurId'],
      type: map['type'],
      message: map['message'],
      lu: map['lu'] == 1,
      commandeId: map['commandeId'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'type': type,
      'message': message,
      'lu': lu ? 1 : 0,
      'commandeId': commandeId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}