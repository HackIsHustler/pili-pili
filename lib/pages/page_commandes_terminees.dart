import 'package:flutter/material.dart';
import 'package:pili_pili/widgets/chargeur_de_suite.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/providers/commande_cuisine_provider.dart';
import 'package:pili_pili/widgets/widget_details_commande_cuisine.dart';
import 'package:pili_pili/style/style.dart';

class PageCommandesTerminees extends StatefulWidget {
  const PageCommandesTerminees({super.key});

  @override
  State<PageCommandesTerminees> createState() => _PageCommandesTermineesState();
}

class _PageCommandesTermineesState extends State<PageCommandesTerminees> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CommandeCuisineProvider>().chargerTerminees();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final jour = d.day.toString().padLeft(2, '0');
    final mois = d.month.toString().padLeft(2, '0');
    final annee = (d.year % 100).toString().padLeft(2, '0');
    final heure = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return "$jour-$mois-$annee   $heure:$minute";
  }

  String _labelStatut(String statut) {
    switch (statut) {
      case 'en_livraison':
        return 'En livraison';
      case 'livre':
        return 'Livrée';
      default:
        return 'Prête';
    }
  }

  Color _couleurStatut(String statut) {
    return statut == 'en_livraison' ? Colors.blue : Colors.green;
  }

  Widget _enTete(int total) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$total",
              style: const TextStyle(
                color: Colors.pink,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text("commande(s) préparée(s)"),
          ],
        ),
      ),
    );
  }

  Widget _carte(CommandeCuisineProvider provider, Commande c) {
    final id = c.id!;
    final debut = c.dateDebutPreparation ?? c.createdAt;
    final couleur = _couleurStatut(c.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Commande #${c.numeroCommande}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labelStatut(c.statut),
                    style: TextStyle(
                      color: couleur,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Préparée le ${_formatDate(debut)}"
                  "${c.dureeEstimeeMinutes != null ? " · ${c.dureeEstimeeMinutes} min" : ""}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            DetailsCommandeCuisine(
              type: c.type,
              numeroTable: provider.numeroTable(id),
              lignes: provider.lignesPour(id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeCuisineProvider>();

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Commandes terminées', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoadingTerminees
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
        onRefresh: () => context
            .read<CommandeCuisineProvider>()
            .chargerTerminees(silencieux: true),
        child: provider.commandesTerminees.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.check_circle_outline, size: 80, color: Colors.white70),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Aucune commande terminée',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          // 1 en-tête + les commandes + 1 indicateur de chargement s'il en reste
          itemCount: 1 +
              provider.commandesTerminees.length +
              (provider.resteTerminees ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) return _enTete(provider.totalTerminees);

            final i = index - 1;
            if (i >= provider.commandesTerminees.length) {
              return ChargeurDeSuite(
                couleur: Colors.white,
                surAffichage: () =>
                    context.read<CommandeCuisineProvider>().chargerPlusTerminees(),
              );
            }
            return _carte(provider, provider.commandesTerminees[i]);
          },
        ),
      ),
    );
  }
}