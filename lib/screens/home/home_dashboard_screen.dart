// lib/screens/home/home_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the other screens
import 'package:pashuu/screens/home/disease_guide_screen.dart';
import 'package:pashuu/screens/home/milk_profit_calculator_screen.dart';
import 'package:pashuu/screens/home/my_herd_screen.dart';
import 'package:pashuu/screens/home/scan_animal_screen.dart';
// --- IMPORT THE NEW HISTORY SCREEN ---
import 'package:pashuu/screens/home/milk_profit_history_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final name = user.displayName;
      setState(() {
        _userName = (name != null && name.isNotEmpty) ? name : "User";
      });
    } else {
      setState(() {
        _userName = "Guest";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Welcome, ${_userName ?? '...'}!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBeautifulWeatherCard(context),
            const SizedBox(height: 24),
            _buildQuickActionsCarousel(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanAnimalScreen()),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('Scan Animal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildGridMenu(context),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Latest News',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildNewsCard('Expert Advice on Pest Control',
                  'Learn what the experts say...'),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS BELOW (ONLY _buildGridMenu IS MODIFIED) ---

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildGridItem(
          context,
          Icons.healing,
          'DISEASE GUIDE',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseGuideScreen()));
          },
        ),
        _buildGridItem(
          context,
          Icons.grass,
          'MY HERD',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHerdScreen()));
          },
        ),
        // --- THIS IS THE MODIFIED WIDGET ---
        _buildGridItem(
          context,
          Icons.history, // Changed icon
          'PROFIT HISTORY', // Changed label
              () {
            // Changed navigation target
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkProfitHistoryScreen()));
          },
        ),
        // -----------------------------------
        _buildGridItem(
          context,
          Icons.calculate,
          'PROFIT CALC',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkProfitCalculatorScreen()));
          },
        ),
      ],
    );
  }

  // --- No changes to any other widgets below this line ---

  Widget _buildBeautifulWeatherCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.lightBlue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '28°C',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black26)]),
                  ),
                  Text(
                    'Sunny',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Good for grazing',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Icon(
                Icons.wb_sunny,
                size: 90,
                color: Colors.white.withOpacity(0.8),
                shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCarousel(BuildContext context) {
    final List<Widget> items = [
      _buildCarouselItem(
        'Detect breed of cattles',
        'https://cdn-icons-png.flaticon.com/512/2928/2928929.png',
        Colors.brown.shade300,
            () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanAnimalScreen()));
        },
      ),
      _buildCarouselItem(
        'Calculate Milk Profit',
        'https://cdn-icons-png.flaticon.com/512/1166/1166005.png',
        Colors.green.shade300,
            () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MilkProfitCalculatorScreen()));
        },
      ),
      _buildCarouselItem(
        'Disease Guide',
        'https://cdn-icons-png.flaticon.com/512/3079/3079374.png',
        Colors.blue.shade300,
            () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DiseaseGuideScreen()));
        },
      ),
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: items,
    );
  }

  Widget _buildCarouselItem(String title, String imageUrl, Color bgColor, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor, bgColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(imageUrl, height: 60, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 1, color: Colors.black38)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, Function() onTap) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.article_outlined, size: 40, color: Colors.grey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}

