import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/providers/notification_provider.dart';
import 'package:pili_pili/services/session_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

class PageNotifications extends StatefulWidget {
  const PageNotifications({super.key});

  @override
  State<PageNotifications> createState() => _PageNotificationsState();
}

class _PageNotificationsState extends State<PageNotifications> {
  String _role = 'client';

  @override
  void initState() {
    super.initState();
    _chargerRole();
  }

  Future<void> _chargerRole() async {
    final role = await SessionManager.getUserRole();
    if (mounted) {
      setState(() => _role = role ?? 'client');
    }
  }

  Future<void> _gererClicNotification(BuildContext context, dynamic notif) async {
    final provider = context.read<NotificationProvider>();

    // Marque comme lue dans tous les cas
    if (!notif.lu) {
      await provider.marquerCommeLue(notif.id);
    }

    // Cas spécifique livreur : tente d'accepter la course
    if (_role == 'livreur' && notif.commandeId != null) {
      final succes = await provider.accepterLivraison(notif.commandeId);

      if (!mounted) return;

      if (succes) {
        SnackBarHelper.success(context, "Livraison acceptée ! Vous êtes en charge de cette commande.");
      } else {
        SnackBarHelper.warning(context, "Un autre livreur a déjà accepté cette commande.");
      }
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final jour = local.day.toString().padLeft(2, '0');
    final mois = local.month.toString().padLeft(2, '0');
    final heure = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "$jour/$mois à $heure:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text("Notifications", style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? const Center(child: Text("Aucune notification"))
              : RefreshIndicator(
                  onRefresh: () => context.read<NotificationProvider>().chargerNotifications(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                    final notif = provider.notifications[index];
                    final bool estLivraisonAAccepter =
                        _role == 'livreur' && notif.commandeId != null && notif.type == 'commande';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: notif.lu ? null : Colors.pink[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  notif.lu ? Icons.notifications_none : Icons.notifications_active,
                                  color: notif.lu ? Colors.grey : Colors.pink,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.message,
                                        style: TextStyle(
                                          fontWeight: notif.lu ? FontWeight.normal : FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(notif.createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Maintenant ces blocs sont des enfants de la Column, PAS du Row
                            if (estLivraisonAAccepter) ...[
                              const SizedBox(height: 12),
                              Builder(
                              builder: (context) {
                      final livreurId = provider.livreurIdPourCommande(notif.commandeId!);

                      if (livreurId == null) {
                      //pas encore prise - bouton actif
                      return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                      onPressed: () => _gererClicNotification(context, notif),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.delivery_dining, size: 20),
                      label: const Text(
                      "Accepter cette livraison",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      ),
                      );
                      }
                      return FutureBuilder<int?>(
                      future: SessionManager.getUserId(),
                      builder: (context, snapshot) {
                      final monId = snapshot.data;
                      final estMoi = monId != null && monId == livreurId;

                      return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                      color: estMoi ? Colors.green[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estMoi ? Colors.green : Colors.grey[400]!),
                      ),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(
                      estMoi ? Icons.check_circle : Icons.block,
                      size: 18,
                      color: estMoi ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 8,),
                      Text(
                      estMoi ? "Vous avez accepte cette livraison" : "Deja prise par un autre livreur",
                      style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: estMoi ? Colors.green[800] : Colors.grey[700],
                      ),
                      )
                      ],
                      ),
                      );
                      },
                      );
                      },
                              ),
                            ] else if (!notif.lu) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _gererClicNotification(context, notif),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  child: const Text(
                                    "Marquer comme lue",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                    },
        
                  ),
                ),
    );
  }
}