import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import './../widgets/widget_page_commandes.dart';
import './../style/style.dart';

class PageCommandes extends StatelessWidget {
  const PageCommandes({super.key});

  @override
  Widget build(BuildContext context) {
    final commandeProvider = context.watch<CommandeProvider>();

    if (commandeProvider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackBarHelper.error(context, commandeProvider.erreur!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<CommandeProvider>().chargerCommandes(),
            icon: const Icon(
              Icons.refresh,
              color: StyleApplication.colorIcon,
              size: StyleApplication.iconAppBarSize,
            ),
          ),
        ],
      ),
      body: commandeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : commandeProvider.commandes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune commande',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: commandeProvider.commandes.length,
                  itemBuilder: (context, index) {
                    final commande = commandeProvider.commandes[index];
                    final date = DateTime.parse(commande['created_at']);

                    return CommandeItem(
                      id: commande['numeroCommande'].toString(),
                      date: _formatDate(date),
                      total: (commande['total'] as num).toInt(),
                      statut: commande['statut'],
                      nombreArticles: commande['nombreArticles'] ?? 0,
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final jour = local.day.toString().padLeft(2, '0');
    final mois = local.month.toString().padLeft(2, '0');
    final annee = (local.year % 100).toString().padLeft(2, '0');
    final heure = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "$jour-$mois-$annee   $heure:$minute";
  }
}