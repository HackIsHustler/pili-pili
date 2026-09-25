import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_cuisine_provider.dart';
import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/style/style.dart';

class PageCuisine extends StatelessWidget {
  const PageCuisine({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommandeCuisineProvider()..chargerCommandes(),
      child: const _PageCuisineContenu(),
    );
  }
}

class _PageCuisineContenu extends StatelessWidget {
  const _PageCuisineContenu();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeCuisineProvider>();

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Commandes à préparer', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<CommandeCuisineProvider>().chargerCommandes(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (provider.commandesEnAttente.isEmpty && provider.commandesEnPreparation.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: Text("Aucune commande pour le moment", style: TextStyle(fontSize: 18, color: Colors.white))),
                    ),

                  if (provider.commandesEnAttente.isNotEmpty) ...[
                    const Text("En attente", style: StyleApplication.sousTitre),
                    const SizedBox(height: 10),
                    ...provider.commandesEnAttente.map(
                      (c) => _CarteCommandeEnAttente(commande: c),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (provider.commandesEnPreparation.isNotEmpty) ...[
                    const Text("En préparation", style: StyleApplication.sousTitre),
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
              Text("Accepter la commande #${commande.numeroCommande}", style: StyleApplication.sousTitre),
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
                    context.read<CommandeCuisineProvider>().accepterCommande(commande.id!, valeur);
                  },
                  child: const Text("Lancer la préparation", style: TextStyle(color: Colors.white)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.pink),
        title: Text("Commande #${commande.numeroCommande}"),
        subtitle: Text("${commande.type} · ${commande.total.toInt()} fcfa"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () => _ouvrirDialogueAcceptation(context),
          child: const Text("Accepter", style: TextStyle(color: Colors.white)),
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
    final restant = commande.tempsRestant ?? Duration.zero;
    final presque = restant.inSeconds <= 30;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: presque ? Colors.orange[50] : null,
      child: ListTile(
        leading: Icon(Icons.local_fire_department, color: presque ? Colors.orange : Colors.pink),
        title: Text("Commande #${commande.numeroCommande}"),
        subtitle: Text("${commande.type} · ${commande.total.toInt()} fcfa"),
        trailing: Text(
          _formatDuree(restant),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: presque ? Colors.orange : Colors.pink,
          ),
        ),
      ),
    );
  }
}