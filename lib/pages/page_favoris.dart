import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/produit_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widgets_page_favoris.dart';
import 'package:pili_pili/style/style.dart';

class PageFavoris extends StatelessWidget {
  const PageFavoris({super.key});

  @override
  Widget build(BuildContext context) {
    final produitProvider = context.watch<ProduitProvider>();

    if (produitProvider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackBarHelper.error(context, produitProvider.erreur!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Les plus aimés", style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: produitProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<ProduitProvider>().chargerProduits(),
              child: produitProvider.produits.isEmpty
                  ? const Center(child: Text("Aucun produit trouvé"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: produitProvider.produits.length,
                      itemBuilder: (context, index) {
                        final produit = produitProvider.produits[index];
                        return FavorisItem(
                          nom: produit.nom,
                          prix: produit.prix.toInt(),
                          likes: produit.nombreLikes ?? 0,
                          imageUrl: produit.imageUrl,
                        );
                      },
                    ),
            ),
    );
  }
}