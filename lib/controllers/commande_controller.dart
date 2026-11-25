import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/models/commande_produit.dart';
import 'package:pili_pili/models/panier_item_model.dart';
import 'package:pili_pili/models/notification.dart' as noti;
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class CommandeController {
  Future<List<Map<String, dynamic>>> chargerCommandes({
    int limite = 20,
    String? curseurDate,
    int? curseurId,
  }) async {
    final userId = await SessionManager.getUserId();

    if (userId != null) {
      return DatabaseManager.getCommandesAvecDetails(
        utilisateurId: userId,
        limite: limite,
        curseurDate: curseurDate,
        curseurId: curseurId,
      );
    } else {
      final deviceId = await SessionManager.getOrCreateDeviceId();
      return DatabaseManager.getCommandesAvecDetails(
        deviceId: deviceId,
        limite: limite,
        curseurDate: curseurDate,
        curseurId: curseurId,
      );
    }
  }

  Future<void> marquerTerminee(int commandeId){
    return DatabaseManager.updateStatutCommande(commandeId, "termine").then((_) => null);
  }

  Future<String> passerCommande({
    required List<PanierItemModel> items,
    required String type,
    String? adresseLivraison,
    int? tableId,
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
      tableId: tableId,
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
    await _notifierSelonType(
      commandeId: commandeId,
      numero: numero,
      type: type,
      tableId: tableId,
    );

    return numero;
  }

  Future<void> _notifierSelonType({
    required int commandeId,
    required String numero,
    required String type,
    int? tableId,
  }) async {
    if (( type == 'sur_place' || type == 'a_emporter') && tableId != null) {
      final affectation = await DatabaseManager.getAffectationActiveByTable(tableId);
      if (affectation != null) {
        await DatabaseManager.insertNotification(
          noti.Notification(
            utilisateurId: affectation.utilisateurId, 
            type: 'commande', 
            message: 'Nouvelle commande $numero sur votre table $tableId', 
            createdAt: DateTime.now(),
            )
          );
      }
    } else if (type == 'livraison') {
      final livreurs = await DatabaseManager.getAllLivreursActifs();
      for (final livreur in livreurs) {
        await DatabaseManager.insertNotification(
          noti.Notification(
            utilisateurId: livreur['utilisateurId'], 
            type: 'commande', 
            message: 'Nouvelle commande $numero à livrer',
            commandeId: commandeId, 
            createdAt: DateTime.now(),
            )
          );
      }
    }
  }
}