import 'package:flutter/material.dart';

// --- 1. Data Model ---
enum Species {
  all('All species'),
  buffalo('Buffalo'),
  cattle('Cattle');

  final String displayName;
  const Species(this.displayName);
}

class DiseaseEntry {
  final String name;
  final String localName;
  final Species species;
  final List<String> symptoms;
  final List<String> prevention;
  final String keywords; // For search filtering

  DiseaseEntry({
    required this.name,
    required this.localName,
    required this.species,
    required this.symptoms,
    required this.prevention,
    required this.keywords,
  });

  // Helper for search
  bool matches(String query, Species selectedSpecies) {
    final lowerQuery = query.toLowerCase();
    final String searchableText =
        '${name.toLowerCase()} ${localName.toLowerCase()} ${keywords.toLowerCase()} ${symptoms.map((s) => s.toLowerCase()).join(' ')} ${prevention.map((p) => p.toLowerCase()).join(' ')}';

    final bool queryMatches = query.isEmpty || searchableText.contains(lowerQuery);
    final bool speciesMatches = selectedSpecies == Species.all || species == selectedSpecies;

    return queryMatches && speciesMatches;
  }
}

class DiseaseGuideScreen extends StatefulWidget {
  const DiseaseGuideScreen({super.key});

  @override
  State<DiseaseGuideScreen> createState() => _DiseaseGuideScreenState();
}

class _DiseaseGuideScreenState extends State<DiseaseGuideScreen> {
  late List<DiseaseEntry> _allDiseases;
  List<DiseaseEntry> _filteredDiseases = [];
  final TextEditingController _searchController = TextEditingController();
  Species _selectedSpeciesFilter = Species.all;
  final double _cardBorderRadius = 12.0; // Consistent border radius

  @override
  void initState() {
    super.initState();
    _allDiseases = _getDiseaseData(); // Populate all diseases
    _filterDiseases(); // Initialize filtered diseases
    _searchController.addListener(_filterDiseases);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDiseases);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDiseases() {
    setState(() {
      _filteredDiseases = _allDiseases
          .where((disease) =>
          disease.matches(_searchController.text, _selectedSpeciesFilter))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      // Revert to a standard AppBar for app consistency
      appBar: AppBar(
        title: const Text('Disease Guide'),
        backgroundColor: primaryColor, // Use app's primary color
        foregroundColor: Colors.white, // White text/icons on primary background
        elevation: 4, // Add some elevation
      ),
      body: Container(
        // Keep the distinct background gradient for this screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEFBD8), // #fefbd8
              Color(0xFFE0F7FA), // #e0f7fa
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Adjust top padding after standard AppBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buffalo & Cattle Diseases',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // Use primary color for header title
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Concise symptoms (2–3) and practical prevention steps for each disease. Use the search and filters to find entries quickly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceColor.withOpacity(0.7), // Use onSurface with opacity for muted text
                    ),
                  ),
                ],
              ),
            ),
            // Controls (Search Bar and Filter Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(width: 10),
                  _buildSpeciesFilter(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredDiseases.isEmpty
                  ? Center(
                child: Text(
                  'No diseases found matching your criteria.',
                  style: TextStyle(fontSize: 16, color: onSurfaceColor.withOpacity(0.6)),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filteredDiseases.length,
                itemBuilder: (context, index) {
                  final disease = _filteredDiseases[index];
                  return _buildDiseaseCard(disease);
                },
              ),
            ),
            _buildFooter(onSurfaceColor),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search disease or symptom...',
        prefixIcon: Icon(Icons.search, color: onSurfaceColor.withOpacity(0.6)), // Muted search icon
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius), // Consistent border radius
          borderSide: BorderSide.none, // No border for a cleaner look
        ),
        enabledBorder: OutlineInputBorder( // Ensure border radius applies when enabled
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.1), width: 1), // Subtle border
        ),
        focusedBorder: OutlineInputBorder( // Highlight when focused
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Primary color highlight
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Adjusted padding
      ),
      style: TextStyle(color: onSurfaceColor),
    );
  }

  Widget _buildSpeciesFilter() {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius), // Consistent border radius
        border: Border.all(color: onSurfaceColor.withOpacity(0.1)), // Subtle border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Species>(
          value: _selectedSpeciesFilter,
          icon: Icon(Icons.arrow_drop_down, color: onSurfaceColor.withOpacity(0.6)), // Muted dropdown icon
          style: TextStyle(fontSize: 15, color: onSurfaceColor), // Use onSurface for text
          onChanged: (Species? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSpeciesFilter = newValue;
                _filterDiseases();
              });
            }
          },
          items: Species.values.map<DropdownMenuItem<Species>>((Species value) {
            return DropdownMenuItem<Species>(
              value: value,
              child: Text(value.displayName),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseEntry disease) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardBorderRadius)), // Consistent border radius
      elevation: 4, // Slightly less aggressive shadow than HTML, aligns with general Flutter Material cards
      shadowColor: onSurfaceColor.withOpacity(0.1), // Softer shadow color
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardBorderRadius), // Consistent border radius
          border: const Border(left: BorderSide(color: Color(0xFF00796B), width: 8)), // Keep distinct left border
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Species: ${disease.species.displayName}',
                style: TextStyle(fontSize: 13, color: onSurfaceColor.withOpacity(0.7)), // Muted text
              ),
              const SizedBox(height: 4),
              Text(
                '${disease.name} (${disease.localName})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor, // Use primary color for disease name
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Symptoms / लक्षणे:', color: primaryColor), // Use primary color
            const SizedBox(height: 6),
            ...disease.symptoms.map((s) => Text('• $s', style: TextStyle(color: onSurfaceColor.withOpacity(0.8)))).toList(),
            const SizedBox(height: 12),
            _buildSectionTitle('Prevention / प्रतिबंध:', color: primaryColor), // Use primary color
            const SizedBox(height: 6),
            ...disease.prevention.map((p) => Text('• $p', style: TextStyle(color: onSurfaceColor.withOpacity(0.8)))).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = Colors.black}) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: color,
      ),
    );
  }

  Widget _buildFooter(Color onSurfaceColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Note: This page provides general information only. For diagnosis and treatment, always consult a qualified veterinarian. Follow local animal health regulations and national vaccination schedules.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: onSurfaceColor.withOpacity(0.6)), // Muted footer text
      ),
    );
  }

  // Your existing "Report a Sickness" button - already consistent
  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement navigation or action for reporting sickness
        },
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: const Text('Report a Sickness', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // --- 2. Hardcoded Disease Data (Same as before) ---
  List<DiseaseEntry> _getDiseaseData() {
    return [
      DiseaseEntry(
        name: 'Foot-and-Mouth Disease',
        localName: 'मुख-खुर रोग',
        species: Species.buffalo,
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
        species: Species.buffalo,
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
        species: Species.buffalo,
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
        name: 'Haemorrhagic Septicemia',
        localName: 'रक्तस्रावी सेप्टीसीमिया / गोट्या रोग',
        species: Species.buffalo,
        symptoms: [
          'Sudden high fever, depression',
          'Swelling of throat and neck, respiratory distress',
          'Rapid death in severe outbreaks',
        ],
        prevention: [
          'Vaccination in endemic areas',
          'Improve drainage and avoid overcrowding',
          'Quick isolation and treatment of cases',
        ],
        keywords: 'haemorrhagic septicemia hs pasteurella sudden death fever swelling',
      ),
      DiseaseEntry(
        name: 'Lumpy Skin Disease',
        localName: 'गाठीचा रोग',
        species: Species.buffalo,
        symptoms: [
          'Firm nodules on skin, sometimes in mouth',
          'Fever, enlarged lymph nodes',
          'Reduced milk, weight loss',
        ],
        prevention: [
          'Vector control (insect repellents, nets)',
          'Vaccination where available',
          'Isolate affected animals and dispose of lesions hygienically',
        ],
        keywords: 'lumpy skin disease lsd nodules fever skin lesions',
      ),
      DiseaseEntry(
        name: 'Theileriosis',
        localName: 'किंचूळजन्य रोग',
        species: Species.buffalo,
        symptoms: [
          'Fever, anemia, weakness',
          'Jaundice in severe cases (urine dark)',
        ],
        prevention: [
          'Regular tick control (acaricides, pasture management)',
          'Use healthy, tick-free replacements',
          'Prompt treatment with anti-protozoals as advised by vet',
        ],
        keywords: 'tick fever theileriosis babesiosis fever anemia ticks',
      ),
      DiseaseEntry(
        name: 'Anthrax',
        localName: 'गुळथोळा',
        species: Species.buffalo,
        symptoms: [
          'Sudden death; bleeding from natural openings',
          'High fever before death in some cases',
        ],
        prevention: [
          'Vaccination in high-risk zones',
          'Avoid handling carcasses; report to authorities',
          'Burn or deep-bury carcasses and disinfect site',
        ],
        keywords: 'anthrax sudden death blood from orifices swelling fever',
      ),
      DiseaseEntry(
        name: 'Internal Parasites',
        localName: 'अंतर्गत जंत / कृमी',
        species: Species.buffalo,
        symptoms: [
          'Diarrhea, poor body condition, weight loss',
          'Poor growth in young animals',
        ],
        prevention: [
          'Regular deworming as per veterinary plan',
          'Rotate grazing and avoid overstocking',
          'Maintain clean water and feed troughs',
        ],
        keywords: 'parasitic gastroenteritis worms diarrhea weight loss',
      ),
      DiseaseEntry(
        name: 'Foot Rot',
        localName: 'पाय कुज रोग',
        species: Species.buffalo,
        symptoms: [
          'Foul-smelling discharge between claws, lameness',
          'Swelling and tenderness of foot',
        ],
        prevention: [
          'Keep housing dry and clean; regular hoof trimming',
          'Foot baths with recommended disinfectant',
          'Isolate and treat affected animals early',
        ],
        keywords: 'foot rot interdigital infection lameness swelling',
      ),
      DiseaseEntry(
        name: 'Bovine Tuberculosis',
        localName: 'गायी क्षयरोग',
        species: Species.cattle,
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
        species: Species.cattle,
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
        species: Species.cattle,
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
      DiseaseEntry(
        name: 'Hypocalcemia',
        localName: 'दूध ताप',
        species: Species.cattle,
        symptoms: [
          'Muscle weakness, ataxia; often occurs around calving',
          'Reduced rumen motility, lying down and inability to rise',
        ],
        prevention: [
          'Balanced pre-calving diet; appropriate calcium management',
          'Provide dry cow nutrition and monitor close-up cows',
        ],
        keywords: 'milk fever hypocalcemia downer weakness at calving',
      ),
      DiseaseEntry(
        name: 'Ruminal Tympany',
        localName: 'पोटफुगी / अफरा',
        species: Species.cattle,
        symptoms: [
          'Distended left abdomen, discomfort, difficulty breathing',
          'Decreased appetite and productivity',
        ],
        prevention: [
          'Avoid sudden introduction to lush legumes; feed anti-foaming agents when needed',
          'Ensure access to roughage and monitor grazing management',
        ],
        keywords: 'bloat ruminal tympany distended abdomen colic',
      ),
      DiseaseEntry(
        name: 'Clostridial disease',
        localName: 'एंटरोटॉक्सिमिया',
        species: Species.cattle,
        symptoms: [
          'Sudden death; in some cases diarrhea and depression',
          'Rapid deterioration in exposed animals',
        ],
        prevention: [
          'Vaccination with clostridial vaccines',
          'Avoid overfeeding rich concentrates; maintain good hygiene',
        ],
        keywords: 'enterotoxemia clostridial sudden death off feed diarrhea',
      ),
      DiseaseEntry(
        name: 'Salmonellosis',
        localName: 'सल्मोनेलोसिस',
        species: Species.cattle,
        symptoms: [
          'Diarrhea (sometimes bloody), fever',
          'Abortions and weak neonates in pregnant animals',
        ],
        prevention: [
          'Good farm hygiene and rodent control',
          'Avoid contaminated feed/water; isolate sick animals',
        ],
        keywords: 'salmonellosis diarrhea fever abortion zoonotic',
      ),
      DiseaseEntry(
        name: 'Ringworm',
        localName: 'दाद / बुरशीजन्य त्वचारोग',
        species: Species.cattle,
        symptoms: [
          'Circular areas of hair loss with crusting',
          'Itchy patches; slow spreading lesions',
        ],
        prevention: [
          'Isolate affected animals, disinfect equipment and housing',
          'Maintain good hygiene; treat with topical antifungals under vet guidance',
        ],
        keywords: 'ringworm skin fungal circular lesion hair loss zoonotic',
      ),
      DiseaseEntry(
        name: 'Respiratory Infections',
        localName: 'निमोनिया / श्वसन संक्रमण',
        species: Species.cattle,
        symptoms: [
          'Coughing, nasal discharge, labored breathing',
          'Fever and reduced feed intake',
        ],
        prevention: [
          'Good ventilation, avoid overcrowding and sudden weather stress',
          'Appropriate vaccination programs and early veterinary treatment',
        ],
        keywords: 'respiratory pneumonia cough nasal discharge fever',
      ),
    ];
  }
}