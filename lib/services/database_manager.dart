
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/models/notification.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/models/commande.dart';
import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/models/produit_like.dart';
import 'package:pili_pili/models/commande_produit.dart';
import 'package:pili_pili/models/affectation_table.dart';
import 'package:pili_pili/models/personnel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static Database? _database;
  static const int _databaseVersion = 1;

  static Future<Database> initDb() async {
    if (_database != null) return _database!;

    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'restaurant.db');

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: (Database db, int version) async {
          await _createTables(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // Migration future
        },
      );
      return _database!;
    } catch (e) {
      throw Exception("Erreur init DB: $e");
    }
  }

  static Future<void> _createTables(Database db) async {
    // 1. Table utilisateurs
    await db.execute('''
      CREATE TABLE utilisateurs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        motDePasse TEXT NOT NULL,
        telephone TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Dans _createTables
      await db.execute('''
        CREATE TABLE personnels(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          utilisateurId INTEGER NOT NULL,
          role TEXT NOT NULL,
          restaurantId INTEGER,
          actif INTEGER DEFAULT 1,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id) ON DELETE CASCADE
        )
      ''');

    // 2. Table tables
    await db.execute('''
      CREATE TABLE tables(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero INTEGER UNIQUE NOT NULL,
        capacite INTEGER NOT NULL,
        statut TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 3. Table categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT UNIQUE NOT NULL,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 4. Table produits
    await db.execute('''
      CREATE TABLE produits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT,
        prix REAL NOT NULL,
        categorieId INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        disponible INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (categorieId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 5. Table commandes
    await db.execute('''
      CREATE TABLE commandes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numeroCommande TEXT UNIQUE NOT NULL,
        utilisateurId INTEGER,
        deviceId TEXT,
        tableId INTEGER,
        type TEXT NOT NULL,
        statut TEXT NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        adresseLivraison TEXT,
        modePaiement TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id) ON DELETE SET NULL,
        FOREIGN KEY (tableId) REFERENCES tables(id) ON DELETE SET NULL
      )
    ''');

    // 6. Table commande_produits
    await db.execute('''
      CREATE TABLE commande_produits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commandeId INTEGER NOT NULL,
        produitId INTEGER NOT NULL,
        quantite INTEGER NOT NULL DEFAULT 1,
        prixUnitaire REAL NOT NULL,
        sousTotal REAL NOT NULL,
        FOREIGN KEY (commandeId) REFERENCES commandes(id) ON DELETE CASCADE,
        FOREIGN KEY (produitId) REFERENCES produits(id) ON DELETE CASCADE
      )
    ''');

    // 7. Table produits_likes
    await db.execute('''
      CREATE TABLE produits_likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produitId INTEGER NOT NULL,
        deviceId TEXT,
        utilisateurId INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (produitId) REFERENCES produits(id) ON DELETE CASCADE,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        UNIQUE(produitId, utilisateurId),
        UNIQUE(produitId, deviceId)
      )
    ''');

    // 8. Table notifications
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateurId INTEGER NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        lu INTEGER DEFAULT 0,
        commandeId INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (commandeId) REFERENCES commandes(id) ON DELETE CASCADE
      )
    ''');

    // 9. Table affectations_tables
    await db.execute('''
      CREATE TABLE affectations_tables(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableId INTEGER NOT NULL,
        utilisateurId INTEGER NOT NULL,
        dateDebut DATETIME NOT NULL,
        dateFin DATETIME,
        FOREIGN KEY (tableId) REFERENCES tables(id) ON DELETE CASCADE,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id) ON DELETE CASCADE
      )
    ''');
  }

  // Fermeture de la base
  static Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }


  // les methodes pour  gerer les entites

  //Methodes pour l'utilisateur

  //inserer un utilisateur
  static Future<int> insertUtilisateur(Utilisateur utilisateur) async {
    final db = await initDb();
    return await db.insert('utilisateurs', utilisateur.toMap());
  }

  //recuperer tous les utilisateurs
  static Future<List<Utilisateur>> getAllUtilisateurs() async {
    final db = await initDb();
    final maps = await db.query('utilisateurs');
    return maps.map((map) => Utilisateur.fromMap(map)).toList();
  }

  //recuperer un utilisateur par son id
  static Future<Utilisateur?> getUtilisateursById(int id) async {
    final db = await initDb();
    final maps = await db.query(
      'utilisateurs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Utilisateur.fromMap(maps.first) : null;
  }

  //recuperer un utilisateur par son mail
  static Future<Utilisateur?> getUtilisateursByEmail(String email) async {
    final db = await initDb();
    final maps = await db.query(
      'utilisateurs',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return maps.isNotEmpty ? Utilisateur.fromMap(maps.first) : null;
  }

  //mettre a jours les infos de l'utiliateur
  static Future<int> updateUtilisateur(Utilisateur utilisateur) async {
    final db = await initDb();
    return db.update(
      'utilisateurs',
       utilisateur.toMap(),
       where: 'id = ?',
       whereArgs: [utilisateur.id],
       );
  }

  //supprimer un utilisateur
  static Future<int> deleteUtilisateur(int id) async {
    final db = await initDb();
    return db.delete(
      'utilisateurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD pour personnels

// Insérer un personnel
static Future<int> insertPersonnel(Personnel personnel) async {
  final db = await initDb();
  return await db.insert('personnels', personnel.toMap());
}

// Récupérer tous les personnels
static Future<List<Personnel>> getAllPersonnels() async {
  final db = await initDb();
  final maps = await db.query('personnels');
  return maps.map((map) => Personnel.fromMap(map)).toList();
}

// Récupérer le rôle d'un utilisateur (table personnels)
static Future<String?> getRoleByUtilisateurId(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'personnels',
    where: 'utilisateurId = ?',
    whereArgs: [utilisateurId],
    limit: 1,
  );
  if (maps.isNotEmpty) {
    return maps.first['role'] as String;
  }
  return null; // L'utilisateur n'est pas un personnel
}

static Future<bool> emailExisteChezAutreUtilisateur(String email, int utilisateurId) async {
  final db = await initDb();
  final result = await db.query(
    'utilisateurs',
    where: 'email = ? and id != ?',
    whereArgs: [email.toLowerCase(), utilisateurId],
    limit: 1,
  );
  return result.isNotEmpty;
}

//recuperer tous les personnels avec leurs informations utilisateur
static Future<List<Map<String, dynamic>>> getAllPersonnelsWithUsers() async {
  final db = await initDb();
  return await db.rawQuery('''
    SELECT
    p.*,
    u.nom,
    u.prenom,
    u.email,
    u.telephone
    FROM personnels p
    INNER JOIN utilisateurs u ON p.utilisateurId = u.id
    ORDER BY p.created_at DESC
    ''');
    }

//desactiver ou activer un personnels
static Future<int> updateStatutPersonnel(int id, bool actif) async {
  final db = await initDb();
  return await db.update(
    'personnels',
    {'actif': actif ? 1 : 0},
     where: 'id = ?',
     whereArgs: [id]
     );
}

//mettre a jour le role d'un personnel
static Future<int> updateRolePersonnel (int id, String role) async {
  final db = await initDb();
  return await db.update(
    'personnels', 
    {'role': role},
    where: 'id = ?',
    whereArgs: [id],
    );
}

//recuperer un personnel par utilisateur
static Future<Personnel?> getPersonnelByutilisateurId(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'personnels',
    where: 'utilisateurId = ?',
    whereArgs: [utilisateurId],
    limit: 1,
  );
  if (maps.isNotEmpty) {
    return Personnel.fromMap(maps.first);
  }
  return null;
}
  //methode pour gerer les produits

  //inserer un produit
  static Future<int> insertProduit(Produit produit) async {
    final db = await initDb();
    return await db.insert('produits', produit.toMap());
  }

  //recuperer tous les produits
  static Future<List<Produit>> getAllProduits() async {
    final db = await initDb();
    final maps = await db.query('produits');
    return maps.map((map) => Produit.fromMap(map)).toList();
  }

  //mettre a jours un produit
  static Future<int> updateProduit(Produit produit) async {
    final db = await initDb();
    return await db.update(
      'produits',
       produit.toMap(),
       where: 'id = ?',
       whereArgs: [produit.id],
       );
  }

  //supprimer un produit
  static Future<int> deleteProduit(int id) async {
    final db = await initDb();
    return await db.delete(
      'produits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //le CRUD pour la table categorie

  //inserer une categorie
  static Future<int> insertCategorie(Categorie categorie) async {
    final db = await initDb();
    return await db.insert('categories', categorie.toMap());
  }

  //recuperer tous les categories
  static Future<List<Categorie>> getAllCategorie() async {
    final db = await initDb();
    final maps = await db.query('categories');
    return maps.map((map) => Categorie.fromMap(map)).toList();
  }

  //mettre a jours le categorie
  static Future<int> updateCategorie(Categorie categorie) async {
    final db = await initDb();
    return await db.update(
      'categories',
       categorie.toMap(),
       where: 'id = ?',
       whereArgs: [categorie.id],
       );
  }

  //supprimer une categorie
  static Future<int> deleteCategorie(int id) async {
    final db = await initDb();
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Compter les catégories
static Future<int> countCategories() async {
  final db = await initDb();
  final result = await db.rawQuery('SELECT COUNT(*) as total FROM categories');
  return Sqflite.firstIntValue(result) ?? 0;
}

  //les CRUD pour table

  //inserer une table
 static Future<int> insertTable(TableRestaurant table) async {
  final db = await initDb();
  return await db.insert('tables', table.toMap());
 }

 //recuperer tous les tables
 static Future<List<TableRestaurant>> getAllTable() async {
  final db = await initDb();
  final maps = await db.query('tables');
  return  maps.map((map) => TableRestaurant.fromMap(map)).toList();
 }

 //mettre a jours une table
 static Future<int> updateTable(TableRestaurant table) async {
  final db = await initDb();
  return await db.update(
    'tables', 
    table.toMap(),
    where: 'id = ?',
    whereArgs: [table.id],
    );
 }

 // Mettre à jour le statut d'une table
static Future<int> updateStatutTable(int tableId, String statut) async {
  final db = await initDb();
  return await db.update(
    'tables',
    {'statut': statut},
    where: 'id = ?',
    whereArgs: [tableId],
  );
}

 //supprimer une table
 static Future<int> deleteTable(int id) async {
  final db = await initDb();
  return await db.delete(
    'tables',
    where: 'id = ?',
    whereArgs: [id],
  );
 }

 //le CRUD pour une notification

 //inserer une notification
 static Future<int> insertNotification(Notification notification) async {
  final db = await initDb();
  return await db.insert('notifications', notification.toMap());
 }

 //recuperer les notifications pour un utilisateur (plus recentes)
 static Future<List<Notification>> getNotificationsByUtilsateur(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'notifications',
    where: 'utilisateurId = ?',
    whereArgs: [utilisateurId],
    orderBy: 'created_at DESC',
  );
  return maps.map((map) => Notification.fromMap(map)).toList();
 }

 //recuperation de tous les notifications
 static Future<List<Notification>> getAllNotifications() async {
  final db = await initDb();
  final maps = await db.query('notifications');
  return  maps.map((map) => Notification.fromMap(map)).toList();
 }

 //marquer une notifictions comme lue
 static Future<int> marquerNotificationCommeLu(int id) async {
  final db = await initDb();
  return await db.update(
    'notifications',
     {'lu': 1},
     where: 'id = ?',
     whereArgs: [id],
     );
 }

 //supprimer une notification
 static Future<int> deleteNotification(int id) async {
  final db = await initDb();
  return await db.delete(
    'notifications',
    where: 'id = ?',
    whereArgs: [id],
  );
 }

 //supprimer toutes les notifications lu les plus anciennes
 static Future<int> deleteAllNotificationsLues() async {
  final db = await initDb();
  return await db.delete(
    'notifications',
    where: 'lu = 1',
  );
 }

 //les CRUD pour les commandes

// Insérer une commande
static Future<int> insertCommande(Commande commande) async {
  final db = await initDb();
  return await db.insert('commandes', commande.toMap());
}

// Récupérer toutes les commandes
static Future<List<Commande>> getAllCommandes() async {
  final db = await initDb();
  final maps = await db.query('commandes', orderBy: 'created_at DESC');
  return maps.map((map) => Commande.fromMap(map)).toList();
}

// Récupérer une commande par ID
static Future<Commande?> getCommandeById(int id) async {
  final db = await initDb();
  final maps = await db.query(
    'commandes',
    where: 'id = ?',
    whereArgs: [id],
  );
  return maps.isNotEmpty ? Commande.fromMap(maps.first) : null;
}

// Récupérer les commandes par statut
static Future<List<Commande>> getCommandesByStatut(String statut) async {
  final db = await initDb();
  final maps = await db.query(
    'commandes',
    where: 'statut = ?',
    whereArgs: [statut],
    orderBy: 'created_at DESC',
  );
  return maps.map((map) => Commande.fromMap(map)).toList();
}

// Récupérer les commandes par type (sur_place, livraison, a_emporter)
static Future<List<Commande>> getCommandesByType(String type) async {
  final db = await initDb();
  final maps = await db.query(
    'commandes',
    where: 'type = ?',
    whereArgs: [type],
    orderBy: 'created_at DESC',
  );
  return maps.map((map) => Commande.fromMap(map)).toList();
}

// Récupérer les commandes d'un utilisateur
static Future<List<Commande>> getCommandesByUtilisateur(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'commandes',
    where: 'utilisateurId = ?',
    whereArgs: [utilisateurId],
    orderBy: 'created_at DESC',
  );
  return maps.map((map) => Commande.fromMap(map)).toList();
}

// Mettre à jour le statut d'une commande
static Future<int> updateStatutCommande(int id, String nouveauStatut) async {
  final db = await initDb();
  return await db.update(
    'commandes',
    {'statut': nouveauStatut},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Mettre à jour le total d'une commande
static Future<int> updateTotalCommande(int id, double nouveauTotal) async {
  final db = await initDb();
  return await db.update(
    'commandes',
    {'total': nouveauTotal},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Supprimer une commande (rare)
static Future<int> deleteCommande(int id) async {
  final db = await initDb();
  return await db.delete(
    'commandes',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Récupérer les commandes d'un utilisateur connecté ou d'un appareil anonyme,
// avec le nombre d'articles de chaque commande
static Future<List<Map<String, dynamic>>> getCommandesAvecDetails({
  int? utilisateurId,
  String? deviceId,
}) async {
  final db = await initDb();

  String where;
  List<dynamic> whereArgs;

  if (utilisateurId != null) {
    where = 'c.utilisateurId = ?';
    whereArgs = [utilisateurId];
  } else if (deviceId != null) {
    where = 'c.deviceId = ?';
    whereArgs = [deviceId];
  } else {
    throw Exception('deviceId ou utilisateurId requis');
  }

  return await db.rawQuery('''
    SELECT
      c.*,
      COUNT(cp.id) as nombreArticles
    FROM commandes c
    LEFT JOIN commande_produits cp ON cp.commandeId = c.id
    WHERE $where
    GROUP BY c.id
    ORDER BY c.created_at DESC
  ''', whereArgs);
}

// Générer un numéro de commande unique
static Future<String> genererNumeroCommande() async {
  final db = await initDb();
  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM commandes')
  ) ?? 0;
  return 'CMD-${(count + 1).toString().padLeft(4, '0')}';
}

//  CRUD pour produits_likes 

// Ajouter un like (anonyme ou connecté)
static Future<int> insertProduitLike(ProduitLike like) async {
  final db = await initDb();
  return await db.insert('produits_likes', like.toMap());
}

// Supprimer un like (anonyme ou connecté)
static Future<int> deleteProduitLike({
  required int produitId,
  String? deviceId,
  int? utilisateurId,
}) async {
  final db = await initDb();
  
  String where;
  List<dynamic> whereArgs;
  
  if (utilisateurId != null) {
    // Utilisateur connecté
    where = 'produitId = ? AND utilisateurId = ?';
    whereArgs = [produitId, utilisateurId];
  } else if (deviceId != null) {
    // Utilisateur anonyme
    where = 'produitId = ? AND deviceId = ?';
    whereArgs = [produitId, deviceId];
  } else {
    throw Exception('DeviceId ou utilisateurId requis');
  }
  
  return await db.delete(
    'produits_likes',
    where: where,
    whereArgs: whereArgs,
  );
}

// Vérifier si un utilisateur (anonyme ou connecté) a liké un produit
static Future<bool> utilisateurALike({
  required int produitId,
  String? deviceId,
  int? utilisateurId,
}) async {
  final db = await initDb();
  
  String where;
  List<dynamic> whereArgs;
  
  if (utilisateurId != null) {
    where = 'produitId = ? AND utilisateurId = ?';
    whereArgs = [produitId, utilisateurId];
  } else if (deviceId != null) {
    where = 'produitId = ? AND deviceId = ?';
    whereArgs = [produitId, deviceId];
  } else {
    throw Exception('DeviceId ou utilisateurId requis');
  }
  
  final maps = await db.query(
    'produits_likes',
    where: where,
    whereArgs: whereArgs,
    limit: 1,
  );
  return maps.isNotEmpty;
}

// Compter les likes d'un produit (total anonyme + connecté)
static Future<int> countLikesByProduit(int produitId) async {
  final db = await initDb();
  final result = await db.rawQuery('''
    SELECT COUNT(*) as total FROM produits_likes WHERE produitId = ?
  ''', [produitId]);
  return Sqflite.firstIntValue(result) ?? 0;
}

// Récupérer les likes d'un utilisateur connecté
static Future<List<ProduitLike>> getLikesByUtilisateur(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'produits_likes',
    where: 'utilisateurId = ?',
    whereArgs: [utilisateurId],
  );
  return maps.map((map) => ProduitLike.fromMap(map)).toList();
}

// Récupérer les likes d'un appareil (anonyme)
static Future<List<ProduitLike>> getLikesByDevice(String deviceId) async {
  final db = await initDb();
  final maps = await db.query(
    'produits_likes',
    where: 'deviceId = ?',
    whereArgs: [deviceId],
  );
  return maps.map((map) => ProduitLike.fromMap(map)).toList();
}

// Récupérer tous les likes d'un produit
static Future<List<ProduitLike>> getLikesByProduit(int produitId) async {
  final db = await initDb();
  final maps = await db.query(
    'produits_likes',
    where: 'produitId = ?',
    whereArgs: [produitId],
  );
  return maps.map((map) => ProduitLike.fromMap(map)).toList();
}

// Supprimer tous les likes d'un produit (quand le produit est supprimé)
static Future<int> deleteLikesByProduit(int produitId) async {
  final db = await initDb();
  return await db.delete(
    'produits_likes',
    where: 'produitId = ?',
    whereArgs: [produitId],
  );
}

// CRUD pour commande_produits 

// Ajouter un produit à une commande
static Future<int> insertCommandeProduit(CommandeProduit commandeProduit) async {
  final db = await initDb();
  return await db.insert('commande_produits', commandeProduit.toMap());
}

// Ajouter plusieurs produits à une commande (en une fois)
static Future<void> insertMultipleCommandeProduits(List<CommandeProduit> items) async {
  final db = await initDb();
  final batch = db.batch();
  for (var item in items) {
    batch.insert('commande_produits', item.toMap());
  }
  await batch.commit();
}

// Récupérer tous les produits d'une commande
static Future<List<CommandeProduit>> getProduitsByCommande(int commandeId) async {
  final db = await initDb();
  final maps = await db.query(
    'commande_produits',
    where: 'commandeId = ?',
    whereArgs: [commandeId],
  );
  return maps.map((map) => CommandeProduit.fromMap(map)).toList();
}

// Récupérer une ligne de commande par ID
static Future<CommandeProduit?> getCommandeProduitById(int id) async {
  final db = await initDb();
  final maps = await db.query(
    'commande_produits',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  return maps.isNotEmpty ? CommandeProduit.fromMap(maps.first) : null;
}

// Mettre à jour la quantité d'un produit dans une commande
static Future<int> updateQuantiteCommandeProduit(int id, int nouvelleQuantite) async {
  final db = await initDb();
  
  // Récupérer le prix unitaire actuel
  final item = await getCommandeProduitById(id);
  if (item == null) return 0;
  
  final nouveauSousTotal = item.prixUnitaire * nouvelleQuantite;
  
  return await db.update(
    'commande_produits',
    {
      'quantite': nouvelleQuantite,
      'sousTotal': nouveauSousTotal,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Supprimer un produit d'une commande
static Future<int> deleteCommandeProduit(int id) async {
  final db = await initDb();
  return await db.delete(
    'commande_produits',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Supprimer tous les produits d'une commande
static Future<int> deleteAllProduitsByCommande(int commandeId) async {
  final db = await initDb();
  return await db.delete(
    'commande_produits',
    where: 'commandeId = ?',
    whereArgs: [commandeId],
  );
}

// Calculer le total d'une commande
static Future<double> calculerTotalCommande(int commandeId) async {
  final db = await initDb();
  final result = await db.rawQuery('''
    SELECT SUM(sousTotal) as total FROM commande_produits WHERE commandeId = ?
  ''', [commandeId]);
  
  final total = result.isNotEmpty && result.first['total'] != null
      ? result.first['total'] as double
      : 0.0;
  
  return total;
}

// Récupérer les produits d'une commande avec leurs détails (produit + quantité)
static Future<List<Map<String, dynamic>>> getProduitsDetailsByCommande(int commandeId) async {
  final db = await initDb();
  return await db.rawQuery('''
    SELECT 
      cp.*,
      p.nom as produitNom,
      p.prix as produitPrix,
      p.imageUrl
    FROM commande_produits cp
    INNER JOIN produits p ON cp.produitId = p.id
    WHERE cp.commandeId = ?
  ''', [commandeId]);
}

// Récupérer les produits triés par nombre de likes (du plus populaire au moins populaire)
static Future<List<Produit>> getProduitsParPopularite() async {
  final db = await initDb();
  final maps = await db.rawQuery('''
    SELECT
      p.*,
      COUNT(pl.id) as nombreLikes
    FROM produits p
    LEFT JOIN produits_likes pl ON pl.produitId = p.id
    GROUP BY p.id
    ORDER BY nombreLikes DESC
  ''');
  return maps.map((map) => Produit.fromMap(map)).toList();
}

//  CRUD pour affectations_tables

// Affecter un serveur à une table
static Future<int> insertAffectationTable(AffectationTable affectation) async {
  final db = await initDb();
  return await db.insert('affectations_tables', affectation.toMap());
}

// Récupérer toutes les affectations
static Future<List<AffectationTable>> getAllAffectations() async {
  final db = await initDb();
  final maps = await db.query(
    'affectations_tables',
    orderBy: 'dateDebut DESC',
  );
  return maps.map((map) => AffectationTable.fromMap(map)).toList();
}

// Récupérer une affectation par ID
static Future<AffectationTable?> getAffectationById(int id) async {
  final db = await initDb();
  final maps = await db.query(
    'affectations_tables',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  return maps.isNotEmpty ? AffectationTable.fromMap(maps.first) : null;
}

// Récupérer les affectations d'un serveur (actives)
static Future<List<AffectationTable>> getAffectationsByServeur(int utilisateurId) async {
  final db = await initDb();
  final maps = await db.query(
    'affectations_tables',
    where: 'utilisateurId = ? AND dateFin IS NULL',
    whereArgs: [utilisateurId],
  );
  return maps.map((map) => AffectationTable.fromMap(map)).toList();
}

// Récupérer la table affectée à un serveur (active)
static Future<AffectationTable?> getAffectationActiveByTable(int tableId) async {
  final db = await initDb();
  final maps = await db.query(
    'affectations_tables',
    where: 'tableId = ? AND dateFin IS NULL',
    whereArgs: [tableId],
    limit: 1,
  );
  return maps.isNotEmpty ? AffectationTable.fromMap(maps.first) : null;
}

// Récupérer toutes les tables avec leur serveur affecté
static Future<List<Map<String, dynamic>>> getTablesWithServeur() async {
  final db = await initDb();
  return await db.rawQuery('''
    SELECT 
      t.*,
      u.nom as serveurNom,
      u.prenom as serveurPrenom,
      a.id as affectationId,
      a.dateDebut
    FROM tables t
    LEFT JOIN affectations_tables a ON t.id = a.tableId AND a.dateFin IS NULL
    LEFT JOIN utilisateurs u ON a.utilisateurId = u.id
    ORDER BY t.numero
  ''');
}

//verifier si un numero de table existe deja 
static Future<bool> tableNumeroExiste(int numero) async {
  final db = await initDb();
  final result = await db.rawQuery(
  'SELECT COUNT(*) as total FROM tables WHERE numero = ?',
  [numero]
  );
  final count = Sqflite.firstIntValue(result) ?? 0;
  return count > 0;
}
// Terminer une affectation (dateFin = maintenant)
static Future<int> terminerAffectation(int id) async {
  final db = await initDb();
  return await db.update(
    'affectations_tables',
    {'dateFin': DateTime.now().toIso8601String()},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Terminer toutes les affectations d'un serveur
static Future<int> terminerAffectationsByServeur(int utilisateurId) async {
  final db = await initDb();
  return await db.update(
    'affectations_tables',
    {'dateFin': DateTime.now().toIso8601String()},
    where: 'utilisateurId = ? AND dateFin IS NULL',
    whereArgs: [utilisateurId],
  );
}

// Supprimer une affectation
static Future<int> deleteAffectation(int id) async {
  final db = await initDb();
  return await db.delete(
    'affectations_tables',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// ========== Statistiques pour le Dashboard ==========

// Compter les commandes
static Future<int> countCommandes() async {
  final db = await initDb();
  final result = await db.rawQuery('SELECT COUNT(*) as total FROM commandes');
  return Sqflite.firstIntValue(result) ?? 0;
}

// Compter les tables
static Future<int> countTables() async {
  final db = await initDb();
  final result = await db.rawQuery('SELECT COUNT(*) as total FROM tables');
  return Sqflite.firstIntValue(result) ?? 0;
}

// Compter les produits
static Future<int> countProduits() async {
  final db = await initDb();
  final result = await db.rawQuery('SELECT COUNT(*) as total FROM produits');
  return Sqflite.firstIntValue(result) ?? 0;
}

// Compter les serveurs
static Future<int> countPersonnels() async {
  final db = await initDb();
  final result = await db.rawQuery(
    'SELECT COUNT(*) as total FROM personnels'
  );
  return Sqflite.firstIntValue(result) ?? 0;
}

}