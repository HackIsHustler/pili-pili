import 'package:flutter/material.dart';
import '../widgets/widgets_page_favoris.dart';
import '../data/mock_data.dart';
import './../style/style.dart';

class PageFavoris  extends StatefulWidget{
  const PageFavoris({super.key});

  @override
  State<PageFavoris> createState() => _PageFavorisState();
}

class _PageFavorisState extends State<PageFavoris>{
  List<Map<String, dynamic>> produits = [];

  @override 
  void initState(){
    super.initState();
    _chargerProduits();
  }

  void _chargerProduits(){
    setState(() {
      produits = MockData.produitsFavoris;
    });
  }

  void _mettreAjourLikes(int index){
    setState(() {
      produits[index]['likes'] = produits[index]['likes'] + 1;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoris", style: StyleApplication.titre,),
        centerTitle: true,
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            onPressed: _chargerProduits, 
            icon: Icon(Icons.refresh, color: StyleApplication.colorIcon, size: StyleApplication.iconAppBarSize,)
            )
        ],
      ),
      body: produits.isEmpty? const Center(
        child: CircularProgressIndicator(),
      )
      : ListView.builder(
         padding: const EdgeInsets.all(15.0),
          itemCount:  produits.length,
          itemBuilder: (context, index){
          final produit = produits[index];
          return GestureDetector(
            onTap: () => _mettreAjourLikes(index),
            child: FavorisItem(
              nom: produit['nom'], 
              prix: produit['prix'], 
              likes: produit['likes']
              ),
          );
        }
        )
    );
  }
}