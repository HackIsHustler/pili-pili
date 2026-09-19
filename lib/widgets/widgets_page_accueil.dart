import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/models/produit_like.dart';
import 'package:pili_pili/style/style.dart';

class CarrouselProduits extends StatelessWidget {
  final List<Produit> produits;
  const CarrouselProduits({super.key, required this.produits});

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return const SizedBox.shrink();
    }

    // Mélange une copie de la liste (ne modifie pas l'originale)
    final produitsMelanges = List<Produit>.from(produits)..shuffle(Random());

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: produitsMelanges.length,
        itemBuilder: (context, index) {
          final produit = produitsMelanges[index];
          final file = File(produit.imageUrl);

          return Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  file.existsSync()
                      ? Image.file(file, fit: BoxFit.cover)
                      : Container(
                          color: Colors.red,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                  // Voile dégradé + nom du produit en bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        produit.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LesCategories extends StatelessWidget{
  final String nom;
  final bool selectionnee;
  final VoidCallback onTap;
  const LesCategories({
    super.key,
    required this.nom,
    this.selectionnee = false,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: onTap, 
        style: ElevatedButton.styleFrom(
          backgroundColor: selectionnee ? Colors.pink : Colors.white,
        ),
        icon: Icon(
          Icons.category,
          color: selectionnee ? Colors.white : StyleApplication.coloriconInPage),
        label: Text(
          nom,
          style: TextStyle(
            color: selectionnee ? Colors.white : Colors.pink,
          ),
          ),
        ),
    );
  }
}

class LesPlusPopulaires extends StatelessWidget {
  final List<Produit> items;
  const LesPlusPopulaires({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _ProduitCard(produit: items[index]);
      },
    );
  }
}

class _ProduitCard extends StatefulWidget {
  final Produit produit;
  const _ProduitCard({required this.produit});

  @override
  State<_ProduitCard> createState() => _ProduitCardState();
}

class _ProduitCardState extends State<_ProduitCard> {
  bool _isLiked = false;
  bool _isLoadingLike = true;

  @override
  void initState() {
    super.initState();
    _verifierLike();
  }

  Future<void> _verifierLike() async {
    final produitId = widget.produit.id;
    if (produitId == null) {
      setState(() => _isLoadingLike = false);
      return;
    }

    try {
      final userId = await SessionManager.getUserId();
      bool liked;

      if (userId != null) {
        liked = await DatabaseManager.utilisateurALike(
          produitId: produitId,
          utilisateurId: userId,
        );
      } else {
        final deviceId = await SessionManager.getOrCreateDeviceId();
        liked = await DatabaseManager.utilisateurALike(
          produitId: produitId,
          deviceId: deviceId,
        );
      }

      if (mounted) {
        setState(() {
          _isLiked = liked;
          _isLoadingLike = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLike = false);
    }
  }

  Future<void> _toggleLike() async {
    final produitId = widget.produit.id;
    if (produitId == null) return;

    final ancienEtat = _isLiked;
    setState(() => _isLiked = !_isLiked);

    try {
      final userId = await SessionManager.getUserId();
      final deviceId =
          userId == null ? await SessionManager.getOrCreateDeviceId() : null;

      if (ancienEtat) {
        await DatabaseManager.deleteProduitLike(
          produitId: produitId,
          utilisateurId: userId,
          deviceId: deviceId,
        );
      } else {
        await DatabaseManager.insertProduitLike(
          ProduitLike(
            produitId: produitId,
            utilisateurId: userId,
            deviceId: deviceId,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLiked = ancienEtat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;

    return Card(
      color: Colors.red,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
           Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _construireImage(produit.imageUrl),
                  )
                  ),
                  const SizedBox(height: 6,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(produit.nom),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${produit.prix} fcfa'),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.pink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Positioned(
            top: 4,
            right: 4,
            child: _isLoadingLike
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.white : Colors.white70,
                      size: 26,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  Widget _construireImage(String imageUrl) {
    final file = File(imageUrl);

    if (file.existsSync()){
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    //fichier introuvable
    return Container(
      color: Colors.white24,
      width: double.infinity,
      child: const Icon(Icons.image_not_supported, color: Colors.white, size: 40,),
    );
  }
}

//bottom navbar
class BottomNavBar extends StatelessWidget{
  final int currentIndex;
  final Function(int) onTap;  
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoris',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Commandes',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.verified_user),
          label: 'Profil',
          )
      ],
      );
  }
}

