import 'package:flutter/material.dart';
import 'package:pili_pili/style/style.dart';

class _Faq {
  final String question;
  final String reponse;
  const _Faq(this.question, this.reponse);
}

class _SectionAide {
  final String titre;
  final IconData icone;
  final List<_Faq> questions;
  const _SectionAide(this.titre, this.icone, this.questions);
}

// ---------- Sections propres à chaque rôle ----------

const _sectionServeur = _SectionAide('Espace serveur', Icons.table_restaurant, [
  _Faq(
    "Comment suis-je prévenu d'une nouvelle commande ?",
    "Quand un client commande sur place ou à emporter en choisissant le numéro d'une table qui vous est affectée, vous recevez une notification.\n\nOuvrez Profil > Notifications. Un badge rouge indique le nombre de notifications non lues.",
  ),
  _Faq(
    "Comment marquer une notification comme lue ?",
    "Touchez « Marquer comme lue » sous la notification.",
  ),
  _Faq(
    "Pourquoi je ne reçois aucune notification ?",
    "Vous devez être affecté à la table du client. L'administrateur fait cette affectation dans « Attribution des tables ». Sans affectation active sur cette table, personne n'est prévenu.",
  ),
]);

const _sectionCuisinier = _SectionAide('Espace cuisine', Icons.kitchen, [
  _Faq(
    "Comment accepter une commande ?",
    "Ouvrez Profil > Commandes à préparer et touchez « Accepter » sur la commande.\n\nLa durée proposée correspond au produit le plus long à préparer de la commande. Vous pouvez la modifier avant de toucher « Lancer la préparation ».",
  ),
  _Faq(
    "Que se passe-t-il à la fin du compte à rebours ?",
    "La commande passe automatiquement à « Terminée », sans action de votre part. Le client est alerté, avec un son et une vibration si son application est ouverte.",
  ),
  _Faq(
    "Puis-je modifier la durée après avoir lancé la préparation ?",
    "Non. La durée se règle uniquement au moment d'accepter la commande.",
  ),
]);

const _sectionLivreur = _SectionAide('Espace livreur', Icons.delivery_dining, [
  _Faq(
    "Comment recevoir une livraison ?",
    "Chaque commande en livraison envoie une notification à tous les livreurs. Ouvrez Profil > Notifications et touchez « Accepter cette livraison ».\n\nLe premier livreur qui accepte obtient la course. Les autres voient « Déjà prise par un autre livreur ».",
  ),
  _Faq(
    "Quand puis-je démarrer une livraison ?",
    "Ouvrez Profil > Commandes à livrer. Le bouton « Démarrer la livraison » s'active quand la cuisine a terminé la commande (statut « Prête, à récupérer »).",
  ),
  _Faq(
    "Comment terminer une livraison ?",
    "Touchez « Marquer comme livrée », puis confirmez que vous avez remis la commande au client.",
  ),
  _Faq(
    "Où retrouver mes livraisons passées ?",
    "Dans Profil > Historique des livraisons, avec le nombre de livraisons effectuées et leur total.",
  ),
]);

const _sectionAdmin = _SectionAide('Espace administrateur', Icons.dashboard, [
  _Faq(
    "Où se trouvent les outils d'administration ?",
    "Dans Profil > Dashboard Admin.",
  ),
]);

// ---------- Sections pour tout le monde ----------

const _sectionsGenerales = <_SectionAide>[
  _SectionAide('Commander', Icons.shopping_cart_outlined, [
    _Faq(
      "Comment passer une commande ?",
      "1. Sur l'accueil, touchez l'icône panier d'un produit.\n2. Ouvrez le panier avec l'icône en haut à droite. Le badge indique le nombre d'articles.\n3. Choisissez le type de commande.\n4. Touchez « Passer la commande », choisissez un moyen de paiement et confirmez.",
    ),
    _Faq(
      "Quelle différence entre sur place, à emporter et livraison ?",
      "Sur place et à emporter : vous êtes au restaurant. Choisissez le numéro affiché sur votre table, pour que le serveur sache où vous apporter votre commande.\n\nLivraison : indiquez votre adresse, un livreur vous apporte la commande.",
    ),
    _Faq(
      "Dois-je avoir un compte pour commander ?",
      "Non. Sans compte, la commande est associée à votre appareil.\n\nAttention : les commandes passées sans compte n'apparaissent plus une fois que vous êtes connecté.",
    ),
    _Faq(
      "Quels moyens de paiement sont proposés ?",
      "Airtel Money, Moov Money, Gourroussdja et carte bancaire.",
    ),
  ]),
  _SectionAide('Suivre ma commande', Icons.receipt_long, [
    _Faq(
      "Que signifient les statuts ?",
      "• En attente : la cuisine n'a pas encore accepté la commande.\n• En préparation : la cuisine prépare votre commande.\n• Terminée : votre commande est prête.\n• En livraison : le livreur est en route.\n• Livrée : la commande a été remise.\n• Annulée : la commande a été annulée.",
    ),
    _Faq(
      "À quoi sert le cercle avec le minuteur ?",
      "Il indique le temps restant avant que votre commande soit prête. À zéro, la commande passe à « Terminée ».",
    ),
    _Faq(
      "Pourquoi mon téléphone ne sonne pas quand ma commande est prête ?",
      "Le son et la vibration ne se déclenchent que si l'application est ouverte. Vérifiez aussi que le volume n'est pas coupé.",
    ),
    _Faq(
      "Le statut de ma commande ne change pas, que faire ?",
      "Touchez l'icône d'actualisation en haut de l'écran Commandes.",
    ),
  ]),
  _SectionAide('Favoris', Icons.favorite_outline, [
    _Faq(
      "Comment aimer un produit ?",
      "Touchez le cœur en haut de la carte du produit. Touchez-le à nouveau pour retirer votre like.",
    ),
    _Faq(
      "À quoi sert l'onglet Favoris ?",
      "Il classe les produits du plus aimé au moins aimé, pour vous aider à choisir.",
    ),
  ]),
  _SectionAide('Mon compte', Icons.person_outline, [
    _Faq(
      "Comment modifier mes informations ?",
      "Ouvrez Profil > Modifier le profil. Vous devez être connecté.",
    ),
    _Faq(
      "Comment me déconnecter ?",
      "Ouvrez Profil et touchez « Se déconnecter ».",
    ),
  ]),
];

_SectionAide? _sectionPourRole(String role) {
  switch (role) {
    case 'serveur':
      return _sectionServeur;
    case 'cuisinier':
      return _sectionCuisinier;
    case 'livreur':
      return _sectionLivreur;
    case 'admin':
      return _sectionAdmin;
    default:
      return null; // client : uniquement les sections générales
  }
}

// ---------- Page ----------

class PageAide extends StatelessWidget {
  final String role;
  const PageAide({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final sectionRole = _sectionPourRole(role);
    final sections = <_SectionAide>[
      if (sectionRole != null) sectionRole,
      ..._sectionsGenerales,
    ];

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text('Aide', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(section.icone, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      section.titre,
                      style: StyleApplication.sousTitre.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ...section.questions.map(
                  (q) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    q.question,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.reponse, style: const TextStyle(height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          Card(
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: Colors.pink),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Une question sans réponse ? Adressez-vous au personnel du restaurant.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}