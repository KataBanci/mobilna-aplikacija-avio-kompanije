import 'package:flutter/material.dart';

import '../models/city.dart';

// Lokalne ocene traju dok je aplikacija pokrenuta; nema serverskih recenzija.
final Map<String, ({int stars, String comment})> _reviews = {};

class CityImage extends StatelessWidget {
  const CityImage(this.city, {super.key});
  final City city;

  @override
  Widget build(BuildContext context) => Image.asset(
    city.image,
    fit: BoxFit.cover,
    errorBuilder: (_, error, stack) => const ColoredBox(
      color: Color(0xFFDCE5DE),
      child: Center(child: Icon(Icons.landscape_outlined, size: 48)),
    ),
  );
}

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Destinacije')),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 230,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CityDetailsScreen(city: city),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: CityImage(city),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            city.country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class CityDetailsScreen extends StatefulWidget {
  const CityDetailsScreen({super.key, required this.city});
  final City city;

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  late final TextEditingController _comment;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    final review = _reviews[widget.city.name];
    _stars = review?.stars ?? 0;
    _comment = TextEditingController(text: review?.comment ?? '');
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Widget section(String title, Widget content) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        content,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final city = widget.city;
    final review = _reviews[city.name];
    return Scaffold(
      appBar: AppBar(title: Text(city.name)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: CityImage(city),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${city.name}, ${city.country}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        city.slogan,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      section(
                        'O gradu',
                        Text(
                          city.about,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
                      section(
                        'Šta može da se vidi',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final attraction in city.attractions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '•  ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Expanded(
                                      child: Text(
                                        attraction,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      section(
                        'Informacije za putovanje',
                        const Text(
                          'Vreme za posetu, valuta, jezik, vremenska zona i okvirni budžet biće dodati nakon provere podataka.',
                        ),
                      ),
                      section(
                        'Ocene i recenzije',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review == null
                                  ? 'Još nema lokalnih recenzija.'
                                  : 'Lokalna ocena: ${review.stars}/5 · 1 recenzija',
                            ),
                            if (review != null && review.comment.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(review.comment),
                              ),
                            const SizedBox(height: 8),
                            const Text('Tvoja ocena'),
                            Wrap(
                              children: [
                                for (var i = 1; i <= 5; i++)
                                  IconButton(
                                    tooltip: '$i od 5 zvezdica',
                                    onPressed: () => setState(() => _stars = i),
                                    icon: Icon(
                                      i <= _stars
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                              ],
                            ),
                            TextField(
                              controller: _comment,
                              maxLength: 500,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Tvoj komentar (opciono)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            FilledButton(
                              onPressed: _stars == 0
                                  ? null
                                  : () {
                                      setState(
                                        () => _reviews[city.name] = (
                                          stars: _stars,
                                          comment: _comment.text.trim(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Ocena je sačuvana za ovu sesiju.',
                                          ),
                                        ),
                                      );
                                    },
                              child: Text(
                                review == null
                                    ? 'Sačuvaj ocenu'
                                    : 'Izmeni ocenu',
                              ),
                            ),
                            const Text(
                              'Ocene i komentari su lokalni i brišu se nakon ponovnog pokretanja aplikacije.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
