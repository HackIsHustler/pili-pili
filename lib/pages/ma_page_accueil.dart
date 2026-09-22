import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/pages/page_panier.dart';
import 'package:pili_pili/providers/categorie_provider.dart';
import 'package:pili_pili/providers/produit_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/providers/panier_provider.dart';
import '../widgets/widgets_page_accueil.dart';
import '../style/style.dart';

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    final categorieProvider = context.watch<CategorieProvider>();
    final produitProvider = context.watch<ProduitProvider>();

    final bool isLoading =
        categorieProvider.isLoading || produitProvider.isLoading;

    if (categorieProvider.erreur != null || produitProvider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final message = categorieProvider.erreur ?? produitProvider.erreur!;
        SnackBarHelper.error(context, message);
      });
    }

    final produitsFiltres = produitProvider.produitsFiltres(
      categorieProvider.categorieSelectionneeId,
    );

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
                MaterialPageRoute(builder: (context) => const PagePanier()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
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
                if (context.watch<PanierProvider>().nombreArticles > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${context.watch<PanierProvider>().nombreArticles}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.all(5.0)),
                    CarrouselProduits(produits: produitProvider.produits),

                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categorieProvider.categories.length + 1,
                        itemBuilder: (context, subIndex) {
                          if (subIndex == 0) {
                            return LesCategories(
                              nom: "Tout",
                              selectionnee:
                                  categorieProvider.categorieSelectionneeId ==
                                  null,
                              onTap: () {
                                context
                                    .read<CategorieProvider>()
                                    .selectionnerCategorie(null);
                              },
                            );
                          }

                          final categorie =
                              categorieProvider.categories[subIndex - 1];
                          return LesCategories(
                            nom: categorie.nom,
                            selectionnee:
                                categorieProvider.categorieSelectionneeId ==
                                categorie.id,
                            onTap: () {
                              context
                                  .read<CategorieProvider>()
                                  .selectionnerCategorie(categorie.id);
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      child: produitsFiltres.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  "Aucun produit dans cette categorie",
                                ),
                              ),
                            )
                          : LesPlusPopulaires(items: produitsFiltres),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
