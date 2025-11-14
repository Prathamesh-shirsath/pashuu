// lib/screens/home/home_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching news URLs

// Import the other screens
import 'package:pashuu/screens/home/disease_guide_screen.dart';
import 'package:pashuu/screens/home/milk_profit_calculator_screen.dart';
import 'package:pashuu/screens/home/my_herd_screen.dart';
import 'package:pashuu/screens/home/scan_animal_screen.dart';
import 'package:pashuu/screens/home/milk_profit_history_screen.dart';
import 'package:pashuu/screens/home/settings_screen.dart'; // Add settings screen import

// --- IMPORTS FOR DYNAMIC FEATURES ---
import 'package:pashuu/models/article_model.dart';
import 'package:pashuu/services/news_service.dart';
import 'package:pashuu/models/weather_model.dart';
import 'package:pashuu/services/weather_service.dart';
// ------------------------------------

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String? _userName;
  // --- STATE VARIABLES FOR DYNAMIC DATA ---
  late Future<List<Article>> _newsFuture;
  late Future<Weather> _weatherFuture;
  // ----------------------------------------

  @override
  void initState() {
    super.initState();
    _getUserName();
    _fetchData(); // Initial data fetch
  }

  void _fetchData() {
    // Call the services when the screen loads or is refreshed
    _newsFuture = NewsService().fetchNews();
    _weatherFuture = WeatherService().fetchWeather('Delhi'); // Change city if needed
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
            onPressed: () {
              // TODO: Implement notification screen navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28), // Added Settings icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // When user pulls to refresh, fetch both news and weather again
          setState(() {
            _fetchData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LIVE WEATHER SECTION ---
                _buildWeatherSection(),
                const SizedBox(height: 24),
                // ----------------------------

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
                      backgroundColor: Colors.teal.shade400, // Specific color for this button
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50), // Full width
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildGridMenu(context),
                ),
                const SizedBox(height: 24),

                // --- LIVE NEWS SECTION ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Latest News',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildNewsSection(),
                // --------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS BELOW ---

  // --- NEW WIDGET TO BUILD THE WEATHER SECTION ---
  Widget _buildWeatherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())));
          } else if (snapshot.hasError) {
            print("Weather FutureBuilder error: ${snapshot.error}");
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 160,
                padding: const EdgeInsets.all(20),
                child: Center(child: Text('Failed to load weather data.\n${snapshot.error}', textAlign: TextAlign.center,)),
              ),
            );
          } else if (snapshot.hasData) {
            return _buildBeautifulWeatherCard(context, snapshot.data!);
          } else {
            return const SizedBox.shrink(); // Should not happen
          }
        },
      ),
    );
  }

  // --- UPDATED WEATHER CARD TO DISPLAY LIVE DATA ---
  Widget _buildBeautifulWeatherCard(BuildContext context, Weather weather) {
    IconData weatherIcon;
    String recommendation = "Have a great day!";

    switch (weather.condition) {
      case 'Clear':
        weatherIcon = Icons.wb_sunny;
        recommendation = 'Sunny! Good for grazing.';
        break;
      case 'Clouds':
        weatherIcon = Icons.cloud;
        recommendation = 'Cloudy, good weather.';
        break;
      case 'Rain':
      case 'Drizzle':
        weatherIcon = Icons.grain;
        recommendation = 'Rainy day, check on shelter.';
        break;
      case 'Thunderstorm':
        weatherIcon = Icons.flash_on;
        recommendation = 'Stormy! Keep animals safe.';
        break;
      default:
        weatherIcon = Icons.cloud_outlined;
        recommendation = 'Check local weather updates.';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.lightBlue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black26)]),
                ),
                Text(
                  weather.condition,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  recommendation,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            Icon(
              weatherIcon,
              size: 90,
              color: Colors.white.withOpacity(0.8),
              shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TO BUILD THE NEWS LIST ---
  Widget _buildNewsSection() {
    return FutureBuilder<List<Article>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Improved error message for the user
          print("News FutureBuilder error: ${snapshot.error}"); // Keep for debugging
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load latest news. Please check your internet connection, refresh the page, or try again later. Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No news articles found for your region/query at this time. Try refreshing!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        } else {
          final articles = snapshot.data!;
          return Column(
            children: articles.map((article) =>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildNewsCard(article),
                )).toList(),
          );
        }
      },
    );
  }

  // --- UPDATED NEWS CARD WIDGET WITH IMAGE FALLBACK ---
  Widget _buildNewsCard(Article article) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
      child: InkWell(
        onTap: () async {
          if (article.url != null) {
            final uri = Uri.parse(article.url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open news link: ${article.url}')),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE DISPLAY OR FALLBACK ---
            /*
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              Image.network(
                article.urlToImage!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if the network image itself fails to load
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.grey[600], size: 50),
                        const SizedBox(height: 8),
                        Text('Image not loaded', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
              )
            else // --- Fallback when urlToImage is null or empty ---
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[200], // Light grey background for the placeholder
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.newspaper, color: Colors.grey[600], size: 60), // A news-related icon
                    const SizedBox(height: 10),
                    Text(
                      'No Image Available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // --- END IMAGE DISPLAY OR FALLBACK ---*/

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (article.description != null && article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MOVED INSIDE _HomeDashboardScreenState ---
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
        _buildGridItem(
          context,
          Icons.history,
          'PROFIT HISTORY',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkProfitHistoryScreen()));
          },
        ),
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

  // --- MOVED INSIDE _HomeDashboardScreenState ---
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

  // --- MOVED INSIDE _HomeDashboardScreenState ---
  Widget _buildCarouselItem(String title, String imageUrl, Color bgColor, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
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

  // --- MOVED INSIDE _HomeDashboardScreenState ---
  Widget _buildGridItem(BuildContext context, IconData icon, String label, Function() onTap) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
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
}