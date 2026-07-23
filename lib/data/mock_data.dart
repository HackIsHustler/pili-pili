import 'package:flutter/material.dart';

class MockData {
  static List<Map<String, dynamic>> get produitsPopulaires{
    return List.generate(
      6,
      (index) => {
        'nom': 'Produit ${index + 1}',
        'prix': (10 + index * 5),
        'image': 'assets/images/produit_${index + 1}.png',
      },
      );
  }

   static List<Map<String, dynamic>> get produitsFavoris {
    return [
      {'nom': 'Pili Pili Spécial', 'prix': 2500, 'likes': 45},
      {'nom': 'Sauce Piquante', 'prix': 1800, 'likes': 38},
      {'nom': 'Mélange Épices', 'prix': 3200, 'likes': 29},
      {'nom': 'Poivre Noir', 'prix': 1500, 'likes': 22},
      {'nom': 'Piment Rouge', 'prix': 1200, 'likes': 18},
      {'nom': 'Gingembre', 'prix': 2000, 'likes': 15},
    ];
  }

  static List<Map<String, dynamic>> get commandes {
  return [
    {
      'id': 'CMD-001',
      'date': '25/06/2026',
      'total': 8500,
      'statut': 'Livrée',
      'nombreArticles': 4,
    },
    {
      'id': 'CMD-002',
      'date': '20/06/2026',
      'total': 3200,
      'statut': 'Livrée',
      'nombreArticles': 2,
    },
    {
      'id': 'CMD-003',
      'date': '15/06/2026',
      'total': 1500,
      'statut': 'En cours',
      'nombreArticles': 1,
    },
    {
      'id': 'CMD-004',
      'date': '10/06/2026',
      'total': 6200,
      'statut': 'Livrée',
      'nombreArticles': 3,
    },
    {
      'id': 'CMD-005',
      'date': '05/06/2026',
      'total': 2100,
      'statut': 'Annulée',
      'nombreArticles': 2,
    },
  ];
}

static Map<String, String> get utilisateur {
  return {
    'nom': 'Utilisateur',
    'email': 'utilisateur@email.com',
    'telephone': '+237 6XX XX XX XX',
  };
}

static List<Map<String, dynamic>> get panier {
  return [
    {'nom': 'Pili Pili Spécial', 'prix': 2500, 'quantite': 2},
    {'nom': 'Sauce Piquante', 'prix': 1800, 'quantite': 1},
    {'nom': 'Mélange Épices', 'prix': 3200, 'quantite': 3},
    {'nom': 'Poivre Noir', 'prix': 1500, 'quantite': 1},
  ];
}

  static List<Map<String, dynamic>> get categories{
    return [
      {'nom': 'pili pili', 'icone': Icons.fireplace},
    ];
  }
}