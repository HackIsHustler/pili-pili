// controllers/produit_controller.dart
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/models/produit_like.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class ProduitController {
  Future<List<Produit>> chargerProduitsParPopularite() {
    return DatabaseManager.getProduitsParPopularite();
  }

  Future<bool> estLike(int produitId) async {
    final userId = await SessionManager.getUserId();

    if (userId != null) {
      return DatabaseManager.utilisateurALike(
        produitId: produitId,
        utilisateurId: userId,
      );
    } else {
      final deviceId = await SessionManager.getOrCreateDeviceId();
      return DatabaseManager.utilisateurALike(
        produitId: produitId,
        deviceId: deviceId,
      );
    }
  }

  Future<void> liker(int produitId) async {
    final userId = await SessionManager.getUserId();
    final deviceId = userId == null ? await SessionManager.getOrCreateDeviceId() : null;

    await DatabaseManager.insertProduitLike(
      ProduitLike(
        produitId: produitId,
        utilisateurId: userId,
        deviceId: deviceId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> retirerLike(int produitId) async {
    final userId = await SessionManager.getUserId();
    final deviceId = userId == null ? await SessionManager.getOrCreateDeviceId() : null;

    await DatabaseManager.deleteProduitLike(
      produitId: produitId,
      utilisateurId: userId,
      deviceId: deviceId,
    );
  }
}