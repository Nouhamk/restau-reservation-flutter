import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundBeige = Color(0xFFF5EFE7);
    const bleuNuit = Color(0xFF283546);
    const accent = Color(0xFFCF8644);

    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            // HERO SECTION
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de fond : salle de resto moderne
                  Image.network(
                    'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?auto=compress&cs=tinysrgb&w=1200',
                    fit: BoxFit.cover,
                  ),
                  // Dégradé sombre
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                  // Contenu
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const _LogoTitle(),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // TODO: aller vers la carte
                                  },
                                  child: const Text(
                                    'Notre carte',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/reservation',
                                    );
                                  },
                                  child: const Text(
                                    'Réserver',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Bienvenue à L’Atelier du Bureau',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'VOTRE PAUSE\nGOURMANDE AU TRAVAIL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Une cuisine de saison, des plats généreux et une ambiance conviviale\n'
                          'pour transformer la cantine en véritable restaurant.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {
                                // TODO: page "Je découvre"
                              },
                              child: const Text(
                                'JE DÉCOUVRE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/reservation');
                              },
                              child: const Text(
                                'RÉSERVER',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CONTENU SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION CARTE
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'UNE CARTE GOURMANDE ET GÉNÉREUSE',
                            style: TextStyle(
                              color: bleuNuit,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: aller vers la carte
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Voir la carte',
                                style: TextStyle(
                                  color: bleuNuit,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: bleuNuit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _DishCard(
                          title: 'Burgers signature',
                          description:
                              'Pain brioché, viande française et garnitures maison.',
                          imageUrl:
                              'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=800',
                        ),
                        _DishCard(
                          title: 'Plats à partager',
                          description:
                              'Planches, tapas et finger food pour vos afterworks entre collègues.',
                          imageUrl:
                              'https://images.pexels.com/photos/3218467/pexels-photo-3218467.jpeg?auto=compress&cs=tinysrgb&w=800',
                        ),
                        _DishCard(
                          title: 'Salades & bowls',
                          description:
                              'Options plus légères, toujours colorées et gourmandes.',
                          imageUrl:
                              'https://images.pexels.com/photos/1640770/pexels-photo-1640770.jpeg?auto=compress&cs=tinysrgb&w=800',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // SECTION HISTOIRE
                    const Text(
                      'L’histoire de L’Atelier du Bureau',
                      style: TextStyle(
                        color: bleuNuit,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          "Né de l’envie de transformer une simple cantine d’entreprise en véritable restaurant,\n"
                          "L’Atelier du Bureau propose une cuisine maison, de saison, pensée pour les collaborateurs.\n\n"
                          "Ici, on prend le temps de faire une vraie pause : service au plateau, plats travaillés et ambiance chaleureuse,\n"
                          "juste en bas de vos bureaux.",
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SECTION EQUIPE
                    const Text(
                      'L’équipe',
                      style: TextStyle(
                        color: bleuNuit,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _TeamCard(
                            role: 'Chef de cuisine',
                            name: 'Amine BOUCHEF',
                            description:
                                'Passionné par les produits de saison, Amine revisite les classiques de brasserie '
                                'avec une touche moderne, en pensant au rythme de la journée de travail.',
                            icon: Icons.restaurant_menu,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _TeamCard(
                            role: 'Directeur de salle',
                            name: 'Lina MARTIN',
                            description:
                                'Toujours en salle, Lina veille à ce que chaque service soit fluide, chaleureux '
                                'et adapté aux contraintes des équipes (réunions, horaires, groupes).',
                            icon: Icons.supervisor_account,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PETIT TEXTE DE CONCLUSION
                    Text(
                      'Votre moment à L’Atelier du Bureau mérite une vraie pause 🍽️',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF5EFE7);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: beige.withOpacity(0.6)),
          ),
          child: const Icon(
            Icons.wine_bar,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'L’Atelier du Bureau',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _DishCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const _DishCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const bleuNuit = Color(0xFF283546);

    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: bleuNuit,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String role;
  final String name;
  final String description;
  final IconData icon;

  const _TeamCard({
    super.key,
    required this.role,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const bleuNuit = Color(0xFF283546);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bleuNuit.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: bleuNuit),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: bleuNuit,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
