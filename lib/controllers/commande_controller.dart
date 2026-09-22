import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/models/commande_produit.dart';
import 'package:pili_pili/models/panier_item_model.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class CommandeController {
  Future<List<Map<String, dynamic>>> chargerCommandes() async {
    final userId = await SessionManager.getUserId();

    if (userId != null) {
      return DatabaseManager.getCommandesAvecDetails(utilisateurId: userId);
    } else {
      final deviceId = await SessionManager.getOrCreateDeviceId();
      return DatabaseManager.getCommandesAvecDetails(deviceId: deviceId);
    }
  }

  Future<String> passerCommande({
    required List<PanierItemModel> items,
    required String type,
    String? adresseLivraison,
    required String modePaiement,
  }) async {
    if (items.isEmpty) {
      throw Exception('Le panier est vide');
    }

    final userId = await SessionManager.getUserId();
    final deviceId = userId == null ? await SessionManager.getOrCreateDeviceId() : null;

    final numero = await DatabaseManager.genererNumeroCommande();
    final total = items.fold<double>(0, (t, item) => t + item.sousTotal);

    final commande = Commande(
      numeroCommande: numero,
      utilisateurId: userId,
      deviceId: deviceId,
      type: type,
      statut: 'en_attente',
      total: total,
      adresseLivraison: type == 'livraison' ? adresseLivraison : null,
      modePaiement: modePaiement,
      createdAt: DateTime.now(),
    );

    final commandeId = await DatabaseManager.insertCommande(commande);

    final lignes = items.map((item) {
      return CommandeProduit(
        commandeId: commandeId,
        produitId: item.produit.id!,
        quantite: item.quantite,
        prixUnitaire: item.produit.prix,
        sousTotal: item.sousTotal.toDouble(),
      );
    }).toList();

    await DatabaseManager.insertMultipleCommandeProduits(lignes);

    return numero;
  }
}