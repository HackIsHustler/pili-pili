import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import './../widgets/widget_page_commandes.dart';
import './../style/style.dart';

class PageCommandes extends StatefulWidget {
  const PageCommandes({super.key});

  @override
  State<PageCommandes> createState() => _PageCommandesState();
}

class _PageCommandesState extends State<PageCommandes> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _jouerAlerte() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/alerte_fin_cuisson.wav'));
    } catch (_) {}

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(pattern: [0, 300, 150, 300]);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandeProvider = context.watch<CommandeProvider>();

    if (commandeProvider.erreur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackBarHelper.error(context, commandeProvider.erreur!);
      });
    }

    if (commandeProvider.dernierIdTermine != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jouerAlerte();
        SnackBarHelper.success(context, "Commande #${commandeProvider.dernierIdTermine} terminée");
        commandeProvider.consommerNotificationFin();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<CommandeProvider>().chargerCommandes(),
            icon: const Icon(
              Icons.refresh,
              color: StyleApplication.colorIcon,
              size: StyleApplication.iconAppBarSize,
            ),
          ),
        ],
      ),
      body: commandeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : commandeProvider.commandes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune commande',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: commandeProvider.commandes.length,
                  itemBuilder: (context, index) {
                    final commande = commandeProvider.commandes[index];
                    final date = DateTime.parse(commande['created_at']);

                    return CommandeItem(
                      id: commande['numeroCommande'].toString(),
                      date: _formatDate(date),
                      total: (commande['total'] as num).toInt(),
                      statut: commande['statut'],
                      nombreArticles: commande['nombreArticles'] ?? 0,
                      dateDebutPreparation: commande['dateDebutPreparation'] != null
                          ? DateTime.parse(commande['dateDebutPreparation'])
                          : null,
                      dureeEstimeeMinutes: commande['dureeEstimeeMinutes'],
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final jour = local.day.toString().padLeft(2, '0');
    final mois = local.month.toString().padLeft(2, '0');
    final annee = (local.year % 100).toString().padLeft(2, '0');
    final heure = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "$jour-$mois-$annee   $heure:$minute";
  }
}