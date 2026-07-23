class Categorie {
  final int? id;
  final String nom;
  final String? description;
  final DateTime createdAt;

  Categorie({
    this.id,
    required this.nom,
    this.description,
    required this.createdAt,
  });

  factory Categorie.fromMap(Map<String, dynamic> map){
    return Categorie(
      id: map['id'],
      nom: map['nom'], 
      description: map['description'],
      createdAt: DateTime.parse(map['created_at'])
      );
  }

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'nom': nom,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}