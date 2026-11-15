import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/profile_screen.dart';

import '../models/city.dart';
import 'cities_screen.dart';

// Prva vizuelna verzija: podaci su primeri, bez baze i rezervacija.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tripType = 0;

  void showPreviewMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ova funkcionalnost još nije povezana.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 410,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const TravelImage(
                        url: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=85',
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFF9F9F7),
                              Color(0xCFFFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            stops: [0, 0.43, 1],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x00FFFFFF),
                              AppColors.lightScaffoldColor,
                            ],
                            stops: [0, 0.75, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 35,
                              color: AppColors.lightPrimary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'airvista',
                              style: TextStyle(
                                fontSize: 27,
                                letterSpacing: -1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                            const Spacer(),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: showPreviewMessage,
                              icon: const Badge(
                                smallSize: 7,
                                child: Icon(Icons.notifications_none_rounded),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'TVOJE NOVO PUTOVANJE\nPOČINJE OVDE',
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.8,
                            letterSpacing: 2.5,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Kuda putujemo\nsledeće?',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 44,
                            height: 0.98,
                            letterSpacing: -1.8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dodaj malo neba\nsvom danu.',
                          style: TextStyle(
                            color: Color(0xFF717673),
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xF9FFFFFF),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 22,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  tripButton('Povratni', Icons.flight, 0),
                                  const SizedBox(width: 3),
                                  tripButton('Jedan smer', Icons.sync_alt, 1),
                                  const SizedBox(width: 3),
                                  tripButton(
                                    'Više gradova',
                                    Icons.location_on_outlined,
                                    2,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Row(
                                    children: [
                                      Expanded(
                                        child: SearchField(
                                          label: 'Odakle',
                                          value: 'BEG',
                                          subtitle: 'Beograd',
                                          icon: Icons.flight_takeoff,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: SearchField(
                                          label: 'Dokle',
                                          value: 'FCO',
                                          subtitle: 'Rim',
                                          icon: Icons.flight_land,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x10000000),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.sync_alt,
                                      size: 18,
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              const Row(
                                children: [
                                  Expanded(
                                    child: SearchField(
                                      label: 'Polazak',
                                      value: 'Izaberi datum',
                                      icon: Icons.calendar_month_outlined,
                                      compact: true,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: SearchField(
                                      label: 'Putnici',
                                      value: '1 putnik',
                                      icon: Icons.person_outline,
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: showPreviewMessage,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.lightPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, size: 22),
                                      SizedBox(width: 16),
                                      Text(
                                        'Pretraži letove',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 17),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Popularne destinacije',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 23,
                            letterSpacing: -0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/destinations'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text(
                          'Vidi sve →',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Pronađi inspiraciju za sledeće putovanje.',
                    style: TextStyle(color: Color(0xFF777C78), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DestinationWidget(
                          city: 'Rim',
                          price: '89',
                          image: 'assets/images/rome.jpg',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DestinationWidget(
                          city: 'Pariz',
                          price: '99',
                          image: 'assets/images/Paris.jpg',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DestinationWidget(
                          city: 'Barselona',
                          price: '79',
                          image: 'assets/images/barcelona.jpg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            );
          } else if (index != 0) {
            showPreviewMessage();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_filled,
              color: AppColors.lightPrimary,
            ),
            label: 'Početna',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Pretraga'),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Putovanja',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget tripButton(String label, IconData icon, int index) {
    final selected = tripType == index;
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => tripType = index),
        style: TextButton.styleFrom(
          backgroundColor: selected
              ? AppColors.lightPrimary
              : const Color(0xFFF3F4F3),
          foregroundColor: selected ? Colors.white : AppColors.textColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 10))),
          ],
        ),
      ),
    );
  }
}

// Mali prikazi ostaju u istom fajlu, kao profesorov CustomListTile.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.compact = false,
  });

  final String label, value;
  final String? subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F3),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, size: compact ? 22 : 25, color: AppColors.lightPrimary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF818681),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 12 : 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF818681),
                    ),
                  ),
              ],
            ),
          ),
          if (compact)
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black54,
            ),
        ],
      ),
    );
  }
}

class DestinationWidget extends StatelessWidget {
  const DestinationWidget({
    super.key,
    required this.city,
    required this.price,
    required this.image,
  });
  final String city, price, image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CityDetailsScreen(
            city: cities.firstWhere((item) => item.name == city),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 128,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TravelImage(url: image),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC15201B)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 9,
                right: 6,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'od €$price',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.textColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelImage extends StatelessWidget {
  const TravelImage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) => const ColoredBox(
          color: Color(0xFFDCE5DE),
          child: Center(child: Icon(Icons.landscape_outlined)),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFDCE5DE),
        child: const Center(
          child: Icon(
            Icons.landscape_outlined,
            color: AppColors.lightPrimary,
            size: 40,
          ),
        ),
      ),
    );
  }
}
