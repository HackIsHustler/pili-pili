class Utilisateur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String telephone;
  final DateTime createdAt;

  Utilisateur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.telephone,
    required this.createdAt
  });

  factory Utilisateur.fromMap(Map<String,dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'], 
      email: map['email'], 
      motDePasse: map['motDePasse'], 
      telephone: map['telephone'],  
      createdAt: DateTime.parse(map['created_at']),
      );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'motDePasse': motDePasse,
      'telephone': telephone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}