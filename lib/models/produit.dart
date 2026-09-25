class Produit {
  final int? id;
  final String nom;
  final String? description;
  final double prix;
  final int categorieId;
  final String imageUrl;
  final bool disponible;
  final int dureePreparation;
  final DateTime createdAt;

  int? nombreLikes;

  Produit({
    this.id,
    required this.nom,
    this.description,
    required this.prix,
    required this.categorieId,
    required this.imageUrl,
    this.disponible = true,
    this.dureePreparation = 10,
    required this.createdAt,
    this.nombreLikes,
  });

  factory Produit.fromMap(Map<String, dynamic> map){
    return Produit(
      id: map['id'],
      nom: map['nom'], 
      description: map['description'],
      prix: map['prix'].toDouble(), 
      categorieId: map['categorieId'], 
      imageUrl: map['imageUrl'], 
      disponible: map['disponible'] == 1,
      dureePreparation: map['dureePreparation'] ?? 10,
      createdAt: DateTime.parse(map['created_at']),
      nombreLikes: map['nombreLikes'],
      );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'categorieId': categorieId,
      'imageUrl': imageUrl,
      'disponible': disponible ? 1 : 0,
      'dureePreparation': dureePreparation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}