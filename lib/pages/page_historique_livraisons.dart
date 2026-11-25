import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_livreur_provider.dart';
import 'package:pili_pili/widgets/chargeur_de_suite.dart';
import 'package:pili_pili/style/style.dart';

class PageHistoriqueLivraisons extends StatefulWidget {
  const PageHistoriqueLivraisons({super.key});

  @override
  State<PageHistoriqueLivraisons> createState() => _PageHistoriqueLivraisonsState();
}

class _PageHistoriqueLivraisonsState extends State<PageHistoriqueLivraisons> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CommandeLivreurProvider>().chargerHistorique();
    });
  }

  String _formatDate(String iso) {
    final d = DateTime.parse(iso).toLocal();
    final jour = d.day.toString().padLeft(2, '0');
    final mois = d.month.toString().padLeft(2, '0');
    final annee = (d.year % 100).toString().padLeft(2, '0');
    final heure = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return "$jour-$mois-$annee   $heure:$minute";
  }

  Widget _statResume(String valeur, String label) {
    return Column(
      children: [
        Text(
          valeur,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _enTete(CommandeLivreurProvider provider) {
    return Card(
      color: Colors.pink,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statResume("${provider.nombreLivraisons}", "livraison(s)"),
            _statResume("${provider.totalLivre}", "fcfa livrés"),
          ],
        ),
      ),
    );
  }

  Widget _carte(Map<String, dynamic> c) {
    final prenom = c['clientPrenom'];
    final nom = c['clientNom'];
    final client = (prenom != null && nom != null) ? "$prenom $nom" : "Client invité";

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.check, color: Colors.green),
        ),
        title: Text(
          'Commande #${c['numeroCommande']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$client\n${_formatDate(c['created_at'])}"),
        isThreeLine: true,
        trailing: Text(
          '${(c['total'] as num).toInt()} fcfa',
          style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeLivreurProvider>();

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Historique des livraisons', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoadingHistorique
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
        onRefresh: () => context
            .read<CommandeLivreurProvider>()
            .chargerHistorique(silencieux: true),
        child: provider.historique.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.history, size: 80, color: Colors.white70),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Aucune livraison effectuée',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: 1 +
              provider.historique.length +
              (provider.resteHistorique ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) return _enTete(provider);

            final i = index - 1;
            if (i >= provider.historique.length) {
              return ChargeurDeSuite(
                couleur: Colors.white,
                surAffichage: () => context
                    .read<CommandeLivreurProvider>()
                    .chargerPlusHistorique(),
              );
            }
            return _carte(provider.historique[i]);
          },
        ),
      ),
    );
  }
}