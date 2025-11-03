import 'package:flutter/material.dart';

class MyHerdScreen extends StatelessWidget {
  const MyHerdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Herd'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatCard(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          _buildAnimalCard('Holstein Friesian', 'Cow', 'Healthy', 'https://via.placeholder.com/150/000000/FFFFFF?text=Cow'),
          _buildAnimalCard('Jersey', 'Cow', 'Lactating', 'https://via.placeholder.com/150/D2691E/FFFFFF?text=Cow'),
          _buildAnimalCard('Murrah Buffalo', 'Buffalo', 'Healthy', 'https://via.placeholder.com/150/2F4F4F/FFFFFF?text=Buffalo'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildStatCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Animals', '62', Colors.green),
            _buildStatItem('Lactating', '18', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(label: const Text('All'), onSelected: (b) {}, selected: true),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Buffaloes'), onSelected: (b) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Cows'), onSelected: (b) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Goats'), onSelected: (b) {}),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(String name, String type, String status, String imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(type, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == 'Healthy' ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status, style: TextStyle(fontSize: 12, color: status == 'Healthy' ? Colors.green.shade800 : Colors.orange.shade800)),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View Details')),
          ],
        ),
      ),
    );
  }
}
