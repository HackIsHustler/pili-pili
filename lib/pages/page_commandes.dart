import 'package:flutter/material.dart';
import './../widgets/widget_page_commandes.dart';
import './../data/mock_data.dart';
import './../style/style.dart';

class PageCommandes  extends StatefulWidget{
  const PageCommandes({super.key});

  @override
  State<PageCommandes> createState() => _PageCommandesState();
}

class _PageCommandesState extends State<PageCommandes> {
  List<Map<String, dynamic>> commandes = [];

  @override
  void initState() {
    super.initState();
    _chargerCommandes();
  }

  void _chargerCommandes() {
    setState(() {
      commandes = MockData.commandes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes', style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _chargerCommandes,
            icon: const Icon(Icons.refresh, color: StyleApplication.colorIcon, size: StyleApplication.iconAppBarSize),
          ),
        ],
      ),
      body: commandes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune commande',
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
              itemCount: commandes.length,
              itemBuilder: (context, index) {
                final commande = commandes[index];
                return CommandeItem(
                  id: commande['id'],
                  date: commande['date'],
                  total: commande['total'],
                  statut: commande['statut'],
                  nombreArticles: commande['nombreArticles'],
                );
              },
            ),
    );
  }
}