
import 'package:flutter/material.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widgets_page_favoris.dart';
import 'package:pili_pili/style/style.dart';

class PageFavoris extends StatefulWidget {
  const PageFavoris({super.key});

  @override
  State<PageFavoris> createState() => _PageFavorisState();
}

class _PageFavorisState extends State<PageFavoris> {
  List<Produit> _produits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  Future<void> _chargerProduits() async {
    setState(() => _isLoading = true);
    try {
      _produits = await DatabaseManager.getProduitsParPopularite();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Les plus aimés",
          style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerProduits,
              child: _produits.isEmpty
                  ? const Center(child: Text("Aucun produit trouvé"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _produits.length,
                      itemBuilder: (context, index) {
                        final produit = _produits[index];
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