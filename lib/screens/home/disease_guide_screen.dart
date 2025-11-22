// lib/screens/home/disease_guide_screen.dart

import 'package:flutter/material.dart';
import '../../data/disease_data.dart';
import '../../models/disease_entry_model.dart';

class DiseaseGuideScreen extends StatefulWidget {
  const DiseaseGuideScreen({super.key});

  @override
  State<DiseaseGuideScreen> createState() => _DiseaseGuideScreenState();
}

class _DiseaseGuideScreenState extends State<DiseaseGuideScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Species _speciesFilter = Species.All;
  List<DiseaseEntry> _results = allDiseaseData;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _results = allDiseaseData.where((d) {
        return d.matches(
          _searchCtrl.text.trim(),
          _speciesFilter,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Guide"),
        backgroundColor: theme.primaryColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(theme),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text("No disease found"))
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _results.length,
              itemBuilder: (c, i) =>
                  DiseaseCard(disease: _results[i]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "Search disease...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Species.values.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(s.displayName),
              selected: _speciesFilter == s,
              selectedColor: theme.primaryColor.withOpacity(.2),
              onSelected: (_) {
                setState(() => _speciesFilter = s);
                _applyFilter();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// -------------------------------------------------
// FULL IMAGE CARD STYLE
// -------------------------------------------------

class DiseaseCard extends StatelessWidget {
  final DiseaseEntry disease;
  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  DiseaseDetailScreen(disease: disease))),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              disease.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            ListTile(
              title: Text(
                disease.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Text(disease.localName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            )
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------
// DETAIL SCREEN
// -------------------------------------------------

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseEntry disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(disease.name),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              disease.image,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease.localName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  _section(
                    title: "लक्षण (Symptoms)",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    list: disease.symptoms,
                  ),
                  const SizedBox(height: 16),

                  _section(
                    title: "रोकथाम (Prevention)",
                    icon: Icons.shield,
                    color: Colors.green,
                    list: disease.prevention,
                  ),
                  const SizedBox(height: 16),

                  _section(
                    title: "पहली सहायता (First Aid)",
                    icon: Icons.health_and_safety,
                    color: Colors.blue,
                    list: disease.firstAid,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> list,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17),
        ),
        children: list
            .map(
              (e) => ListTile(
            leading: Icon(Icons.check_circle, color: color),
            title: Text(e),
          ),
        )
            .toList(),
      ),
    );
  }
}
