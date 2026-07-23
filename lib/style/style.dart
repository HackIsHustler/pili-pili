import 'package:flutter/material.dart';

class StyleApplication{
  //taille des icons dans appbar
  static const double iconAppBarSize = 30;

  //taille de licone dans appbar
  static const colorIcon = Colors.white;

  //couleur des icones dans une pages
  static const coloriconInPage = Colors.pink;

  //le titre de l'application
  static const titre = TextStyle(
    fontSize: 25.0,
    color: Colors.white,
  );
  static const sousTitre = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );
  static const taillTextSimple = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white
  );

  static var styleboutonCategorie = ElevatedButton.styleFrom(
    fixedSize: Size.fromHeight(50),
  );

  static const textSurBagde = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}