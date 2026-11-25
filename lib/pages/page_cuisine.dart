import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_cuisine_provider.dart';
import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/widgets/widget_details_commande_cuisine.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

class PageCuisine extends StatefulWidget {
  const PageCuisine({super.key});

  @override
  State<PageCuisine> createState() => _PageCuisineState();
}

class _PageCuisineState extends State<PageCuisine> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CommandeCuisineProvider>().chargerCommandes(silencieux: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeCuisineProvider>();

    if (provider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackBarHelper.error(context, provider.erreur!);
        context.read<CommandeCuisineProvider>().effacerErreur();
      });
    }

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Commandes à préparer', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
        onRefresh: () => context
            .read<CommandeCuisineProvider>()
            .chargerCommandes(silencieux: true),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (provider.commandesEnAttente.isEmpty &&
                provider.commandesEnPreparation.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    "Aucune commande pour le moment",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

            if (provider.commandesEnAttente.isNotEmpty) ...[
              const Text(
                "En attente",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              ...provider.commandesEnAttente.map(
                    (c) => _CarteCommandeEnAttente(commande: c),
              ),
              const SizedBox(height: 20),
            ],

            if (provider.commandesEnPreparation.isNotEmpty) ...[
              const Text(
                "En préparation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              ...provider.commandesEnPreparation.map(
                    (c) => _CarteCommandeEnPreparation(commande: c),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarteCommandeEnAttente extends StatelessWidget {
  final Commande commande;
  const _CarteCommandeEnAttente({required this.commande});

  String _ilYa(DateTime date) {
    final d = DateTime.now().difference(date);
    if (d.inMinutes < 1) return "Reçue à l'instant";
    if (d.inMinutes < 60) return "Reçue il y a ${d.inMinutes} min";
    return "Reçue il y a ${d.inHours} h ${d.inMinutes % 60} min";
  }

  void _ouvrirDialogueAcceptation(BuildContext context) {
    final provider = context.read<CommandeCuisineProvider>();
    int duree = provider.dureeSuggeree(commande.id!);
    final controller = TextEditingController(text: duree.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Accepter la commande #${commande.numeroCommande}",
                  style: StyleApplication.sousTitre),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Durée de préparation (minutes)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  onPressed: () {
                    final valeur = int.tryParse(controller.text.trim());
                    if (valeur == null || valeur <= 0) return;
                    Navigator.pop(context);
                    context
                        .read<CommandeCuisineProvider>()
                        .accepterCommande(commande.id!, valeur);
                  },
                  child: const Text("Lancer la préparation",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeCuisineProvider>();
    final id = commande.id!;

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
                  "Commande #${commande.numeroCommande}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  _ilYa(commande.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DetailsCommandeCuisine(
              type: commande.type,
              numeroTable: provider.numeroTable(id),
              lignes: provider.lignesPour(id),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => _ouvrirDialogueAcceptation(context),
                icon: const Icon(Icons.local_fire_department, size: 18, color: Colors.white),
                label: const Text(
                  "Accepter",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteCommandeEnPreparation extends StatelessWidget {
  final Commande commande;
  const _CarteCommandeEnPreparation({required this.commande});

  String _formatDuree(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final secondes = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secondes";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeCuisineProvider>();
    final id = commande.id!;
    final restant = commande.tempsRestant ?? Duration.zero;
    final presque = restant.inSeconds <= 30;
    final couleur = presque ? Colors.orange : Colors.pink;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: presque ? Colors.orange[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: couleur),
                const SizedBox(width: 8),
                Text(
                  "Commande #${commande.numeroCommande}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  _formatDuree(restant),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: couleur),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DetailsCommandeCuisine(
              type: commande.type,
              numeroTable: provider.numeroTable(id),
              lignes: provider.lignesPour(id),
            ),
          ],
        ),
      ),
    );
  }
}