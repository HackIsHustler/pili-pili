import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Clés
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserNom = 'user_nom';
  static const String _keyUserPrenom = 'user_prenom';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';

  //  Démarrer une session
  static Future<void> startSession({
    required int userId,
    required String email,
    required String nom,
    required String prenom,
    required String role
  }) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserNom, value: nom);
    await _storage.write(key: _keyUserPrenom, value: prenom);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
  }

  //  Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  //  Récupérer l'ID de l'utilisateur
  static Future<int?> getUserId() async {
    final value = await _storage.read(key: _keyUserId);
    return value != null ? int.tryParse(value) : null;
  }

  //  Récupérer l'email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  //  Récupérer le nom
  static Future<String?> getUserNom() async {
    return await _storage.read(key: _keyUserNom);
  }

  //  Récupérer le prénom
  static Future<String?> getUserPrenom() async {
    return await _storage.read(key: _keyUserPrenom);
  }

  //  Récupérer le rôle
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  //  Ajouter cette méthode
  static Future<void> setUserRole(String? role) async {
    role ??= 'client';
    await _storage.write(key: _keyUserRole, value: role);
  }

  //  Récupérer toutes les infos de session
  static Future<Map<String, dynamic>?> getSession() async {
    final userId = await getUserId();
    if (userId == null) return null;

    return {
      'userId': userId,
      'email': await getUserEmail(),
      'nom': await getUserNom(),
      'prenom': await getUserPrenom(),
      'role': await getUserRole(),
    };
  }

  //  Fermer la session (déconnexion)
  static Future<void> endSession() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserNom);
    await _storage.delete(key: _keyUserPrenom);
    await _storage.delete(key: _keyUserRole);
    await _storage.write(key: _keyIsLoggedIn, value: 'false');
  }

  // Supprimer toutes les données (débogage)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

}