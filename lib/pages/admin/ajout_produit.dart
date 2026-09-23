import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/champ_de_saisie.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pili_pili/style/style.dart';

class AjoutProduitPage extends StatefulWidget {
  const AjoutProduitPage({super.key});

  @override
  State<AjoutProduitPage> createState() => _AjoutProduitPageState();
}

class _AjoutProduitPageState extends State<AjoutProduitPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  int? _categorieId;
  bool _disponible = true;
  bool _isSubmitting = false;
  List<Categorie> _categories = [];

  Future<String> _copierImagePermanente(File image) async {
  final directoryPermanent = await getApplicationDocumentsDirectory();
  final nomFichier = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
  final nouveauChemin = path.join(directoryPermanent.path, nomFichier);
  final nouveauFichier = await image.copy(nouveauChemin);
  return nouveauFichier.path;
}

  @override
  void initState() {
    super.initState();
    _chargerCategories();
  }

  Future<void> _pickerImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.pink,),
                title: const Text("Prendre une Photo"),
                onTap: () async {
                  Navigator.pop(context);
                   final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                    );
                      if (image != null){
                      setState(() {
                        _imageFile = File(image.path);
                      });
                    }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text("Prendre dans Galerie"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                    );
                      if (image != null){
                            setState(() {
                        _imageFile = File(image.path);
                      });
                      }
                },
              )
            ],
          )
          );
      }
      );
    
  }

  Future<void> _chargerCategories() async {
    try {
      final categories = await DatabaseManager.getAllCategorie();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty) {
            _categorieId = _categories.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur chargement catégories: $e");
      }
    }
  }

  Future<void> _ajouterProduit() async {
    final nom = _nomController.text.trim();
    final description = _descriptionController.text.trim();
    final prixText = _prixController.text.trim();


    if (nom.isEmpty || prixText.isEmpty || _categorieId == null) {
      SnackBarHelper.warning(context, "Veuillez remplir tous les champs obligatoires");
      return;
    }
    
    if (_imageFile == null) {
      SnackBarHelper.warning(context, "veuillez selectionnez une image");
      return;
    }

    final prix = double.tryParse(prixText);
    if (prix == null || prix <= 0) {
      SnackBarHelper.warning(context, "Veuillez entrer un prix valide");
      return;
    }

    //verifie si une image a ete selectionne
    setState(() => _isSubmitting = true);
    String? imagePath;
    try {
      imagePath = await _copierImagePermanente(_imageFile!);
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur lors de la copie de l'image: $e");
        setState(() => _isSubmitting = false);
      }
      return;
    }
    
    try {
      final produit = Produit(
        nom: nom,
        description: description.isNotEmpty ? description : null,
        prix: prix,
        categorieId: _categorieId!,
        imageUrl: imagePath!,
        disponible: _disponible,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseManager.insertProduit(produit);

      if (!mounted) return;

      if (id > 0) {
        SnackBarHelper.success(context, "Produit ajouté avec succès !");
        Navigator.pop(context, true);
      } else {
        SnackBarHelper.error(context, "Erreur lors de l'ajout");
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text(
          "Ajouter un produit",
          style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthTextField(
                controller: _nomController,
                hintText: "Nom du produit",
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _descriptionController,
                hintText: "Description (optionnelle)",
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _prixController,
                hintText: "Prix",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Dropdown Catégorie
              _categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                    iconEnabledColor: Colors.white,
                      initialValue: _categorieId,
                      items: _categories.map((categorie) {
                        return DropdownMenuItem(
                          value: categorie.id,
                          child: Text(categorie.nom, style: StyleApplication.taillTextSimple,),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categorieId = value;
                        });
                      },
                      dropdownColor: Colors.pink,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Catégorie",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),

              // Switch Disponible
              Row(
                children: [
                  const Text("Disponible", style: StyleApplication.taillTextSimple,),
                  Switch(
                    value: _disponible,
                    onChanged: (value) {
                      setState(() {
                        _disponible = value;
                      });
                    },
                    activeThumbColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 8,),
                         GestureDetector(
              onTap: _pickerImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size:50, color: Colors.white,),
                        SizedBox(height: 8,),
                        Text(
                          "Appuyez pour selectionner une image",
                          style: StyleApplication.taillTextSimple,
                        )
                      ],
                    ),
              ),
             ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _ajouterProduit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Ajouter",
                          style: StyleApplication.textSurLeBouton,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}