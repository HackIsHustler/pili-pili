import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_livreur_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/style/style.dart';

class PageCommandesALivrer extends StatefulWidget {
  const PageCommandesALivrer({super.key});

  @override
  State<PageCommandesALivrer> createState() => _PageCommandesALivrerState();
}

class _PageCommandesALivrerState extends State<PageCommandesALivrer> {
  @override
  void initState() {
    super.initState();
    // Recharge à chaque ouverture : le livreur vient peut-être d'accepter une course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CommandeLivreurProvider>().chargerCommandes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommandeLivreurProvider>();

    if (provider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackBarHelper.error(context, provider.erreur!);
        context.read<CommandeLivreurProvider>().effacerErreur();
      });
    }

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Commandes à livrer', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => context.read<CommandeLivreurProvider>().chargerCommandes(),
        child: provider.commandes.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.delivery_dining, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Aucune livraison en cours',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: provider.commandes.length,
          itemBuilder: (context, index) {
            return _CarteLivraison(commande: provider.commandes[index]);
          },
        ),
      ),
    );
  }
}

class _CarteLivraison extends StatelessWidget {
  final Map<String, dynamic> commande;
  const _CarteLivraison({required this.commande});

  String get _statut => commande['statut'] as String;

  String _labelStatut() {
    switch (_statut) {
      case 'en_attente':
        return 'En attente de la cuisine';
      case 'en_preparation':
        return 'En préparation';
      case 'termine':
        return 'Prête, à récupérer';
      case 'en_livraison':
        return 'En cours de livraison';
      default:
        return _statut;
    }
  }

  Color _couleurStatut() {
    switch (_statut) {
      case 'en_attente':
        return Colors.grey;
      case 'en_preparation':
        return Colors.orange;
      case 'termine':
        return Colors.green;
      case 'en_livraison':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _demarrer(BuildContext context) async {
    final succes = await context
        .read<CommandeLivreurProvider>()
        .demarrerLivraison(commande['id'] as int);

    if (!context.mounted) return;
    if (succes) {
      SnackBarHelper.success(context, "Livraison démarrée. Bonne route !");
    } else {
      SnackBarHelper.warning(context, "Cette commande n'est pas encore prête.");
    }
  }

  void _confirmerLivraison(BuildContext context) {
    ConfirmationDialogue.show(
      context,
      title: "Confirmer la livraison",
      message: "Avez-vous bien remis la commande ${commande['numeroCommande']} au client ?",
      confirmText: "Oui, livrée",
      confirmColor: Colors.green,
      onConfirm: () async {
        final succes = await context
            .read<CommandeLivreurProvider>()
            .marquerLivree(commande['id'] as int);

        if (!context.mounted) return;
        if (succes) {
          SnackBarHelper.success(context, "Livraison terminée !");
        } else {
          SnackBarHelper.warning(context, "Impossible de valider cette livraison.");
        }
      },
    );
  }

  Widget _boutonAction(BuildContext context) {
    switch (_statut) {
      case 'termine':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _demarrer(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.delivery_dining, size: 20),
            label: const Text(
              "Démarrer la livraison",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );

      case 'en_livraison':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _confirmerLivraison(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text(
              "Marquer comme livrée",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );

      default:
      // en_attente / en_preparation : le livreur doit patienter
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "En attente de la cuisine",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prenom = commande['clientPrenom'];
    final nom = commande['clientNom'];
    final telephone = commande['clientTelephone'];
    final nomClient = (prenom != null && nom != null) ? "$prenom $nom" : "Client invité";
    final adresse = commande['adresseLivraison'] ?? 'Adresse non renseignée';
    final total = (commande['total'] as num).toInt();
    final nbArticles = commande['nombreArticles'] ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${commande['numeroCommande']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _couleurStatut().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labelStatut(),
                    style: TextStyle(
                      color: _couleurStatut(),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.pink),
                const SizedBox(width: 8),
                Expanded(child: Text(nomClient)),
              ],
            ),
            if (telephone != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18, color: Colors.pink),
                  const SizedBox(width: 8),
                  Text(telephone),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.pink),
                const SizedBox(width: 8),
                Expanded(child: Text(adresse)),
              ],
            ),

            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$nbArticles article(s)', style: const TextStyle(color: Colors.grey)),
                Text(
                  '$total fcfa',
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _boutonAction(context),
          ],
        ),
      ),
    );
  }
}