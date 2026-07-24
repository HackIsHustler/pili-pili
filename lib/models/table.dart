class TableRestaurant{
  final int? id;
  final int numero;
  final int capacite;
  final String statut;
  final DateTime createdAt;

  TableRestaurant({
    this.id,
    required this.numero,
    required this.capacite,
    required this.statut,
    required this.createdAt,
  });

  factory TableRestaurant.fromMap(Map<String, dynamic> map){
    return TableRestaurant(
      id: map['id'],
      numero: map['numero'], 
      capacite: map['capacite'], 
      statut: map['statut'], 
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'numero': numero,
      'capacite': capacite,
      'statut': statut,
      'created_at': createdAt.toIso8601String()
    };
  }
}