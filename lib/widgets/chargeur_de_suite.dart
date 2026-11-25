import 'package:flutter/material.dart';

/// Dernier élément d'une liste paginée : charge la page suivante dès qu'il
/// est construit, c'est-à-dire dès qu'il approche de l'écran.
class ChargeurDeSuite extends StatefulWidget {
  final VoidCallback surAffichage;
  final Color couleur;

  const ChargeurDeSuite({
    super.key,
    required this.surAffichage,
    this.couleur = Colors.pink,
  });

  @override
  State<ChargeurDeSuite> createState() => _ChargeurDeSuiteState();
}

class _ChargeurDeSuiteState extends State<ChargeurDeSuite> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.surAffichage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator(color: widget.couleur)),
    );
  }
}