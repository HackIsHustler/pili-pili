import 'package:flutter/material.dart';
import 'package:pili_pili/pages/page_panier.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import '../widgets/widgets_page_accueil.dart';
import 'package:pili_pili/models/produit.dart';
import '../style/style.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key});

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  List<Categorie> _categories = [];
  int? _categorieSelectionneeId; // null = "Tout"
  bool _isLoading = true;

  List<Produit> _produits = [];


  @override
  void initState() {
    super.initState();
    _chargerCategories();
    _chargerProduits();
  }

  Future<void> _chargerCategories() async {
    setState(() => _isLoading = true);
    try {
      _categories = await DatabaseManager.getAllCategorie();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _chargerProduits() async {
    try{
      _produits = await DatabaseManager.getProduitsParPopularite();
      setState(() {
        
      });
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  List<Produit> get _produitsFiltres{
    if (_categorieSelectionneeId == null){
      return _produits;
    }
    return _produits
          .where((p) => p.categorieId == _categorieSelectionneeId)
          .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PILI-PILI", style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        leading: const CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/logob.png'),
          radius: 25,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PagePanier(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              width: 50.0,
              height: 50.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.shopping_cart,
                size: 30,
                color: StyleApplication.coloriconInPage,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    CarrouselProduits(produits: _produits),

                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1, // +1 pour "Tout"
                        itemBuilder: (context, subIndex) {
                          if (subIndex == 0) {
                            return LesCategories(
                              nom: "Tout",
                              selectionnee: _categorieSelectionneeId == null,
                              onTap: () {
                                setState(() {
                                  _categorieSelectionneeId = null;
                                });
                              },
                            );
                          }

                          final categorie = _categories[subIndex - 1];
                          return LesCategories(
                            nom: categorie.nom,
                            selectionnee:
                                _categorieSelectionneeId == categorie.id,
                            onTap: () {
                              setState(() {
                                _categorieSelectionneeId = categorie.id;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      child: _produitsFiltres.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text("Aucun produit dans cette categorie"),
                        ),
                        )
                      : LesPlusPopulaires(
                        items: _produitsFiltres,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}