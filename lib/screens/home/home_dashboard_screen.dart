import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning, Alex!'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather and Forecast Card
            _buildWeatherCard(),
            const SizedBox(height: 24),

            // Soil Health and Improve Pasture
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Scan Animal Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('Scan Animal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 24),

            // Grid Menu
            _buildGridMenu(context),
            const SizedBox(height: 24),

            // Latest News
            const Text('Latest News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildNewsCard('Expert Advice on Pest Control', 'Learn what the experts say...'),
            const SizedBox(height: 12),
            _buildNewsCard('New Subsidy Schemes Announced', 'Details about government support...'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: NetworkImage('https://via.placeholder.com/400x150/81C784/FFFFFF?text=Pasture'), // Placeholder image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('28°C Sunny', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('3-Day Forecast & Industry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text('Normal: 60% humidity. Good for grazing.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Image.network('https://via.placeholder.com/150/5D4037/FFFFFF?text=Soil', height: 80), // Placeholder
                  const SizedBox(height: 8),
                  const Text('Soil Health Review'),
                  const SizedBox(height: 4),
                  TextButton(onPressed: () {}, child: const Text('Select Block')),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Image.network('https://via.placeholder.com/150/A5D6A7/FFFFFF?text=Pasture', height: 80), // Placeholder
                  const SizedBox(height: 8),
                  const Text('Improve Pasture'),
                  const SizedBox(height: 4),
                  TextButton(onPressed: () {}, child: const Text('Learn How')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildGridItem(context, Icons.healing, 'DISEASE GUIDE'),
        _buildGridItem(context, Icons.grass, 'MY HERD'),
        _buildGridItem(context, Icons.local_florist, 'PASTURE CARE'),
        _buildGridItem(context, Icons.calculate, 'PROFIT CALC'),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {},
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
