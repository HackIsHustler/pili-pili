import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/panier_provider.dart';
import 'package:pili_pili/pages/page_paiement.dart';
import '../widgets/widget_page_panier.dart';
import '../style/style.dart';

class PagePanier extends StatelessWidget {
  const PagePanier({super.key});

  @override
  Widget build(BuildContext context) {
    final panierProvider = context.watch<PanierProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: panierProvider.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Votre panier est vide',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      ...panierProvider.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return PanierItem(
                          nom: item.produit.nom,
                          prix: item.produit.prix.toInt(),
                          quantite: item.quantite,
                          onIncrement: () => context.read<PanierProvider>().incrementerQuantite(index),
                          onDecrement: () => context.read<PanierProvider>().decrementerQuantite(index),
                          onDelete: () => context.read<PanierProvider>().supprimerProduit(index),
                        );
                      }),

                      const SizedBox(height: 8),
                      const Text(
                        "Type de commande",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _TypeChip(
                            label: "Sur place",
                            value: "sur_place",
                            selectionnee: panierProvider.typeCommande == "sur_place",
                          ),
                          const SizedBox(width: 8),
                          _TypeChip(
                            label: "À emporter",
                            value: "a_emporter",
                            selectionnee: panierProvider.typeCommande == "a_emporter",
                          ),
                          const SizedBox(width: 8),
                          _TypeChip(
                            label: "Livraison",
                            value: "livraison",
                            selectionnee: panierProvider.typeCommande == "livraison",
                          ),
                        ],
                      ),

                      if (panierProvider.typeCommande == "livraison") ...[
                        const SizedBox(height: 14),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Adresse de livraison",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            context.read<PanierProvider>().definirAdresseLivraison(value);
                          },
                        ),
                      ],
                    ],
                  ),
          ),
          if (panierProvider.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '${panierProvider.total} fcfa',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const PagePaiement()),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      'Passer la commande',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selectionnee;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selectionnee,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<PanierProvider>().definirTypeCommande(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selectionnee ? Colors.pink : Colors.white,
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selectionnee ? Colors.white : Colors.pink,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}