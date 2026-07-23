import 'package:flutter/material.dart';
import '../widgets/widget_page_panier.dart';
import '../style/style.dart';
import '../data/mock_data.dart';

class PagePanier extends StatefulWidget {
  const PagePanier({super.key});

  @override
  State<PagePanier> createState() => _PagePanierState();
}

class _PagePanierState extends State<PagePanier> {
  List<Map<String, dynamic>> panier = [];

  @override
  void initState() {
    super.initState();
    _chargerPanier();
  }

  void _chargerPanier() {
    setState(() {
      panier = MockData.panier;
    });
  }

  void _incrementerQuantite(int index) {
    setState(() {
      panier[index]['quantite'] = (panier[index]['quantite'] ?? 1) + 1;
    });
  }

  void _decrementerQuantite(int index) {
    setState(() {
      if (panier[index]['quantite'] > 1) {
        panier[index]['quantite'] = (panier[index]['quantite'] ?? 1) - 1;
      }
    });
  }

  void _supprimerProduit(int index) {
    setState(() {
      panier.removeAt(index);
    });
  }

  int _calculerTotal() {
    int total = 0;
    for (var item in panier) {
      total += (item['prix'] as int ) * (item['quantite'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculerTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier', style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _chargerPanier,
            icon: const Icon(Icons.refresh, color: StyleApplication.colorIcon, size: StyleApplication.iconAppBarSize,),
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des produits
          Expanded(
            child: panier.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Votre panier est vide',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: panier.length,
                    itemBuilder: (context, index) {
                      final item = panier[index];
                      return PanierItem(
                        nom: item['nom'] ?? 'Produit',
                        prix: item['prix'] ?? 0,
                        quantite: item['quantite'] ?? 1,
                        onIncrement: () => _incrementerQuantite(index),
                        onDecrement: () => _decrementerQuantite(index),
                        onDelete: () => _supprimerProduit(index),
                      );
                    },
                  ),
          ),
          // Total + Payer
          if (panier.isNotEmpty)
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
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$total fcfa',
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
                      // Action passer la commande
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Passer la commande',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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