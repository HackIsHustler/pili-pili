import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class ProfilController {
  Future<Utilisateur?> chargerUtilisateurCourant() async {
    final id = await SessionManager.getUserId();
    if (id == null) return null;
    return DatabaseManager.getUtilisateursById(id);
  }

  /// Retourne null si tout s'est bien passé, sinon le message d'erreur à afficher.
  Future<String?> modifierProfil({
    required Utilisateur actuel,
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
  }) async {
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || telephone.isEmpty) {
      return "Veuillez remplir tous les champs";
    }

    final emailValide = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailValide) {
      return "Adresse email invalide";
    }

    final emailNormalise = email.toLowerCase();

    final dejaPris = await DatabaseManager.emailExisteChezAutreUtilisateur(
      emailNormalise,
      actuel.id!,
    );
    if (dejaPris) {
      return "Cet email est déjà utilisé par un autre compte";
    }

    // On repart de l'utilisateur actuel pour conserver motDePasse et createdAt
    final misAJour = Utilisateur(
      id: actuel.id,
      nom: nom,
      prenom: prenom,
      email: emailNormalise,
      motDePasse: actuel.motDePasse,
      telephone: telephone,
      createdAt: actuel.createdAt,
    );

    await DatabaseManager.updateUtilisateur(misAJour);
    await SessionManager.updateUserInfos(
      email: emailNormalise,
      nom: nom,
      prenom: prenom,
    );

    return null;
  }
}