// lib/screens/home/disease_guide_screen.dart

import 'package:flutter/material.dart';

// --- 1. ENHANCED DATA MODEL & FILTERS ---
enum Species { All, Buffalo, Cattle }

class DiseaseEntry {
  final String name;
  final String localName;
  final Species species;
  final List<String> symptoms;
  final List<String> prevention;
  final String keywords; // For search filtering

  const DiseaseEntry({
    required this.name,
    required this.localName,
    required this.species,
    required this.symptoms,
    required this.prevention,
    required this.keywords,
  });

  // Helper for search and filtering
  bool matches(String query, Species selectedSpecies) {
    final lowerQuery = query.toLowerCase();
    final String searchableText =
        '${name.toLowerCase()} ${localName.toLowerCase()} ${keywords.toLowerCase()}';

    final bool queryMatches = query.isEmpty || searchableText.contains(lowerQuery);
    final bool speciesMatches = selectedSpecies == Species.All || species == selectedSpecies;

    return queryMatches && speciesMatches;
  }
}

class DiseaseGuideScreen extends StatefulWidget {
  const DiseaseGuideScreen({super.key});

  @override
  State<DiseaseGuideScreen> createState() => _DiseaseGuideScreenState();
}

class _DiseaseGuideScreenState extends State<DiseaseGuideScreen> {
  late final List<DiseaseEntry> _allDiseases;
  List<DiseaseEntry> _filteredDiseases = [];
  final TextEditingController _searchController = TextEditingController();
  Species _selectedSpecies = Species.All;

  @override
  void initState() {
    super.initState();
    _allDiseases = _getDiseaseData(); // Populate all diseases from your original data
    _runFilter(); // Initialize filtered diseases
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    setState(() {
      _filteredDiseases = _allDiseases
          .where((disease) =>
          disease.matches(_searchController.text, _selectedSpecies))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Guide'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        // Subtle gradient background for a more premium feel
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // --- Search and Filter UI ---
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildFilterChips(theme),
                ],
              ),
            ),
            const Divider(height: 1),

            // --- Disease List ---
            Expanded(
              child: _filteredDiseases.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _filteredDiseases.length,
                itemBuilder: (context, index) {
                  final disease = _filteredDiseases[index];
                  return DiseaseCard(disease: disease);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search disease name (e.g., FMD)...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Species.values.map((species) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(species.name),
              selected: _selectedSpecies == species,
              onSelected: (selected) {
                setState(() {
                  _selectedSpecies = selected ? species : Species.All;
                });
                _runFilter();
              },
              avatar: Icon(
                _getIconForSpecies(species),
                color: _selectedSpecies == species ? theme.primaryColor : Colors.grey.shade600,
              ),
              selectedColor: theme.primaryColor.withOpacity(0.2),
              checkmarkColor: theme.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForSpecies(Species species) {
    switch (species) {
      case Species.Buffalo: return Icons.kitesurfing; // Placeholder icon
      case Species.Cattle: return Icons.ac_unit; // Placeholder icon
      case Species.All:
      default:
        return Icons.select_all;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Diseases Found',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS FOR THE MAIN SCREEN ---

class DiseaseCard extends StatelessWidget {
  final DiseaseEntry disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DiseaseDetailScreen(disease: disease),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.medication_liquid_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      disease.localName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// --- THE DETAIL SCREEN ---

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
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disease.name,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                        Text(
                          '(${disease.localName})',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(disease.species.name, style: TextStyle(color: theme.primaryColor)),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- EXPANDABLE SECTIONS ---
            InfoSection(
              title: 'Symptoms / लक्षणे',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange.shade700,
              points: disease.symptoms,
            ),
            const SizedBox(height: 16),
            InfoSection(
              title: 'Prevention / प्रतिबंध',
              icon: Icons.shield_outlined,
              iconColor: Colors.blue.shade700,
              points: disease.prevention,
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET FOR THE DETAIL SCREEN ---

class InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> points;

  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: points.map((point) => ListTile(
          leading: Icon(Icons.arrow_right, color: iconColor),
          title: Text(point),
        )).toList(),
      ),
    );
  }
}


// --- 2. YOUR ORIGINAL DATA, CONVERTED TO THE NEW MODEL ---
// This is the same data from your context, just structured as a list of DiseaseEntry objects.
List<DiseaseEntry> _getDiseaseData() {
  return [
    // --- Existing Diseases ---
    DiseaseEntry(
      name: 'Foot-and-Mouth Disease',
      localName: 'मुख-खुर रोग',
      species: Species.Buffalo,
      symptoms: [
        'Blisters/vesicles in mouth and on feet',
        'Excessive salivation, lameness',
        'Sudden drop in milk yield',
      ],
      prevention: [
        'Regular vaccination (follow local schedule)',
        'Strict movement control and isolation of new animals',
        'Disinfection of equipment and vehicles',
      ],
      keywords: 'fmd foot-and-mouth mouth blisters fever',
    ),
    DiseaseEntry(
      name: 'Mastitis',
      localName: 'अवतीण/स्तनदाह',
      species: Species.Buffalo,
      symptoms: [
        'Swollen, hot or painful udder',
        'Abnormal milk — clots, blood or watery',
        'Reduced milk production',
      ],
      prevention: [
        'Good milking hygiene and clean environment',
        'Proper milking technique and equipment maintenance',
        'Prompt treatment of clinical cases',
      ],
      keywords: 'mastitis udder inflammation milk clots fever',
    ),
    DiseaseEntry(
      name: 'Brucellosis',
      localName: 'घोंगरा रोग',
      species: Species.Buffalo,
      symptoms: [
        'Abortions, stillbirths, weak calves',
        'Reduced fertility',
        'Occasional fever and malaise',
      ],
      prevention: [
        'Test and remove infected animals; use certified replacements',
        'Practice hygienic handling of birth materials',
        'Vaccinate where national programs recommend',
      ],
      keywords: 'brucellosis abortion reproductive infertility fever',
    ),
    DiseaseEntry(
      name: 'Bovine Tuberculosis',
      localName: 'गायी क्षयरोग',
      species: Species.Cattle,
      symptoms: [
        'Chronic coughing, weight loss',
        'Reduced appetite, intermittent fever',
      ],
      prevention: [
        'Regular testing and culling of reactors',
        'Good ventilation and avoid close confinement',
        'Use TB-free breeding stock',
      ],
      keywords: 'bovine tuberculosis tb chronic cough weight loss',
    ),
    DiseaseEntry(
      name: 'Bovine Viral Diarrhea',
      localName: 'वायरल अतिसार',
      species: Species.Cattle,
      symptoms: [
        'Diarrhea, fever, nasal discharge',
        'Reproductive failures and weak calves',
      ],
      prevention: [
        'Vaccination and biosecurity to prevent introduction',
        'Test and remove persistently infected animals',
      ],
      keywords: 'bovine viral diarrhea bvd diarrhea fever reproductive problems',
    ),
    DiseaseEntry(
      name: 'Ketosis',
      localName: 'दुधखाटी',
      species: Species.Cattle,
      symptoms: [
        'Reduced appetite, drop in milk yield',
        'Sweet/acetone smell on breath, sometimes nervous signs',
      ],
      prevention: [
        'Balanced diets in transition period; avoid sudden feed changes',
        'Monitor body condition and treat early with vet guidance',
      ],
      keywords: 'ketosis metabolic decreased appetite milk drop nervous',
    ),

    // --- NEWLY ADDED DISEASES ---

    DiseaseEntry(
      name: 'Haemorrhagic Septicaemia (HS)',
      localName: 'गलघोटू (Galghotu)',
      species: Species.Buffalo, // Particularly severe in buffaloes
      symptoms: [
        'High fever (106-107°F)',
        'Sudden drop in milk',
        'Swelling in the throat, neck, and brisket region',
        'Difficulty in breathing (respiratory distress)',
        'Profuse salivation',
        'Sudden death within 24 hours is common',
      ],
      prevention: [
        'Pre-monsoon vaccination is highly effective',
        'Isolate sick animals immediately',
        'Avoid sharing contaminated water sources or pastures',
      ],
      keywords: 'hs haemorrhagic septicaemia galghotu swelling throat breathing fever sudden death',
    ),
    DiseaseEntry(
      name: 'Black Quarter (BQ)',
      localName: 'फड़क्या (Fadkya)',
      species: Species.Cattle, // Primarily affects young, well-fed cattle
      symptoms: [
        'High fever, loss of appetite, and depression',
        'Characteristic swelling in heavy muscles (thigh, shoulder)',
        'Swelling is hot and painful initially, then becomes cold and painless',
        'A crackling (crepitating) sound when the swelling is pressed',
        'Severe lameness',
      ],
      prevention: [
        'Vaccination before the monsoon season',
        'Proper disposal of infected carcasses (burning or deep burial)',
        'Avoid grazing on pastures known to be contaminated',
      ],
      keywords: 'bq black quarter fadkya lameness swelling crackling sound muscle',
    ),
    DiseaseEntry(
      name: 'Theileriosis',
      localName: 'गोचीड ताप (Gochid Taap)',
      species: Species.Cattle, // Especially affects crossbred and exotic cattle
      symptoms: [
        'Persistent high fever',
        'Swelling of lymph nodes (especially near the ears and shoulders)',
        'Anemia (pale gums and eyes)',
        'Loss of appetite and weight loss',
        'Difficulty breathing (due to fluid in lungs)',
      ],
      prevention: [
        'Strict and regular tick control program (acaricide application)',
        'Fencing pastures to prevent wildlife contact',
        'Inspect and quarantine new animals for ticks',
      ],
      keywords: 'theileriosis tick fever gochid taap lymph nodes anemia weakness parasite',
    ),
    DiseaseEntry(
      name: 'Bloat (Tympanites)',
      localName: 'पोटफुगी (Potphugi)',
      species: Species.Cattle,
      symptoms: [
        'Visible distention of the left side of the abdomen',
        'Signs of discomfort (kicking at belly, restlessness)',
        'Grunting and difficulty breathing',
        'Sudden collapse and death if not treated quickly',
      ],
      prevention: [
        'Gradual introduction to lush, green pastures (especially legumes)',
        'Provide dry hay or roughage before turning out to graze',
        'Use anti-bloat oils or agents mixed in feed or water',
      ],
      keywords: 'bloat tympanites potphugi stomach gas distended abdomen pasture',
    ),
    DiseaseEntry(
      name: 'Anthrax',
      localName: 'फाशी / घटसर्प',
      species: Species.Cattle,
      symptoms: [
        'Sudden death is the most common sign',
        'High fever, staggering, and trembling before death',
        'Dark, non-clotting blood from nose, mouth, and anus after death',
        'Absence of rigor mortis (stiffening) after death',
        'WARNING: Do not open the carcass of a suspected Anthrax case.',
      ],
      prevention: [
        'Annual vaccination in areas where the disease is common',
        'Report any suspected case to a veterinarian immediately',
        'Proper, safe disposal of carcasses (deep burial with lime or burning)',
      ],
      keywords: 'anthrax phashi sudden death blood zoonotic danger',
    ),
  ];
}