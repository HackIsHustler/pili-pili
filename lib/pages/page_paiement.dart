import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/panier_provider.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

class PagePaiement extends StatefulWidget {
  const PagePaiement({super.key});

  @override
  State<PagePaiement> createState() => _PagePaiementState();
}

class _PagePaiementState extends State<PagePaiement> {
  String? _modeSelectionne;

  final List<Map<String, dynamic>> _moyensPaiement = [
    {'id': 'airtel_money', 'label': 'Airtel Money', 'icon': Icons.phone_android, 'color': Colors.red},
    {'id': 'moov_money', 'label': 'Moov Money', 'icon': Icons.phone_android, 'color': Colors.blue},
    {'id': 'gourroussdja', 'label': 'Gourroussdja', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
    {'id': 'carte_bancaire', 'label': 'Carte bancaire', 'icon': Icons.credit_card, 'color': Colors.purple},
  ];

  Future<void> _confirmerPaiement() async {
    if (_modeSelectionne == null) {
      SnackBarHelper.warning(context, "Veuillez sélectionner un moyen de paiement.");
      return;
    }

    final panierProvider = context.read<PanierProvider>();
    final commandeProvider = context.read<CommandeProvider>();

    final numero = await commandeProvider.passerCommande(
      items: panierProvider.items,
      type: panierProvider.typeCommande,
      adresseLivraison: panierProvider.adresseLivraison,
      modePaiement: _modeSelectionne!,
    );

    if (!mounted) return;

    if (numero != null) {
      panierProvider.vider();
      _afficherConfirmation(numero);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(commandeProvider.erreur ?? "Erreur lors de la commande")),
      );
    }
  }

  void _afficherConfirmation(String numero) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Commande confirmée !"),
        content: Text("Votre commande $numero a bien été enregistrée."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Retour à l'accueil"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panierProvider = context.watch<PanierProvider>();
    final commandeProvider = context.watch<CommandeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Passer à la caisse", style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Récapitulatif",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${panierProvider.nombreArticles} article(s)"),
                Text(
                  "${panierProvider.total} fcfa",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "Moyen de paiement",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _moyensPaiement.length,
                itemBuilder: (context, index) {
                  final moyen = _moyensPaiement[index];
                  final bool selectionne = _modeSelectionne == moyen['id'];

                  return Card(
                    elevation: selectionne ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectionne ? Colors.pink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (moyen['color'] as Color).withValues(alpha: 0.15),
                        child: Icon(moyen['icon'] as IconData, color: moyen['color'] as Color),
                      ),
                      title: Text(
                        moyen['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: selectionne
                          ? const Icon(Icons.check_circle, color: Colors.pink)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      onTap: () {
                        setState(() => _modeSelectionne = moyen['id'] as String);
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: commandeProvider.isSubmitting ? null : _confirmerPaiement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: commandeProvider.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Confirmer le paiement",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}