import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import 'package:pili_pili/providers/notification_provider.dart';
import 'package:pili_pili/providers/produit_provider.dart';
import 'package:pili_pili/providers/commande_livreur_provider.dart';
import 'package:pili_pili/providers/commande_cuisine_provider.dart';


Future<void> rechargerDonneesUtilisateur(BuildContext context) async {
  final commandes = context.read<CommandeProvider>();
  final notifiations = context.read<NotificationProvider>();
  final produits = context.read<ProduitProvider>();
  final livraisons =context.read<CommandeLivreurProvider>();
  final cuisine = context.read<CommandeCuisineProvider>();

  await Future.wait([
    commandes.chargerCommandes(),
    notifiations.chargerNotifications(),
    produits.chargerProduits(),
    livraisons.chargerCommandes(),
    livraisons.chargerHistorique(),
    cuisine.chargerCommandes(silencieux: true),
  ]);
}