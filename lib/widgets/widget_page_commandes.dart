import 'dart:async';
import 'package:flutter/material.dart';
import '../style/style.dart';

class CommandeItem extends StatelessWidget {
  final String id;
  final String date;
  final int total;
  final String statut;
  final int nombreArticles;
  final DateTime? dateDebutPreparation;
  final int? dureeEstimeeMinutes;

  const CommandeItem({
    super.key,
    required this.id,
    required this.date,
    required this.total,
    required this.statut,
    required this.nombreArticles,
    this.dateDebutPreparation,
    this.dureeEstimeeMinutes,
  });

  Color _getStatutColor() {
    switch (statut.toLowerCase()) {
      case 'termine':
      case 'livre':
        return Colors.green;
      case 'en_preparation':
      case 'en_attente':
        return Colors.orange;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatutLabel() {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'en_preparation':
        return 'En préparation';
      case 'termine':
        return 'Terminée';
      case 'annule':
        return 'Annulée';
      case 'livre':
        return 'Livrée';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enPreparation = statut.toLowerCase() == 'en_preparation' && dateDebutPreparation != null && dureeEstimeeMinutes != null;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #$id',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatutColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatutLabel(),
                    style: TextStyle(
                      color: _getStatutColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: StyleApplication.coloriconInPage,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.shopping_bag,
                  size: 16,
                  color: StyleApplication.coloriconInPage,
                ),
                const SizedBox(width: 4),
                Text(
                  '$nombreArticles articles',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            if(enPreparation) ...[
              const SizedBox(height: 14),
              _CountdownCirculaire(
                dateDebutPreparation: dateDebutPreparation!,
                dureeEstimeeMinutes: dureeEstimeeMinutes!,
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$total fcfa',
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownCirculaire extends StatefulWidget {
  final DateTime dateDebutPreparation;
  final int dureeEstimeeMinutes;

  const _CountdownCirculaire({
    required this.dateDebutPreparation,
    required this.dureeEstimeeMinutes,
  });

  @override
  State<_CountdownCirculaire> createState() => _CountdownCirculaireState();
}

class _CountdownCirculaireState extends State<_CountdownCirculaire> {
  late final Duration _dureeTotal;
  late final DateTime _dateFin;
  Timer? _timer;
  Duration _restant = Duration.zero;

  @override
  void initState() {
    super.initState();
    _dureeTotal = Duration(minutes: widget.dureeEstimeeMinutes);
    _dateFin = widget.dateDebutPreparation.add(_dureeTotal);
    _calculerRestant();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculerRestant());
  }

  void _calculerRestant() {
    final diff = _dateFin.difference(DateTime.now());
    setState(() {
      _restant = diff.isNegative ? Duration.zero : diff;
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final secondes = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secondes";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progres = _dureeTotal.inSeconds == 0 ? 0.0 : 1 - (_restant.inSeconds / _dureeTotal.inSeconds);
    final bool termine = _restant == Duration.zero;
    return Row(
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progres.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(termine ? Colors.green : Colors.pink),
                strokeWidth: 4,
              ),
              Icon(
                termine ? Icons.check : Icons.local_fire_department,
                size: 20,
                color: termine ? Colors.green : Colors.pink,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          termine ? "Prêt" : "Prét dans ${_format(_restant)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: termine ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }
}