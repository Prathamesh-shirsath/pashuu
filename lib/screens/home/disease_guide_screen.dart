import 'package:flutter/material.dart';class DiseaseGuideScreen extends StatelessWidget {
  const DiseaseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Guide'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildDiseaseExpansionTile(
                  'Foot and Mouth Disease (FMD)',
                  symptoms: [
                    'High fever and blisters on mouth and feet.',
                    'Loss of appetite and depression.',
                    'Reduced milk production.',
                  ],
                  prevention: [
                    'Regular vaccination on schedule.',
                    'Maintain a clean and hygienic environment.',
                  ],
                  freeTip: 'Isolate the sick animal immediately to prevent spread and contact a veterinarian for confirmation.',
                ),
                const Divider(height: 30),
                _buildDiseaseExpansionTile(
                  'Peste des Petits Ruminants (PPR)',
                  symptoms: ['Symptom A', 'Symptom B'],
                  prevention: ['Prevention A', 'Prevention B'],
                ),
                const Divider(height: 30),
                _buildDiseaseExpansionTile(
                  'Haemorrhagic Septicaemia (HS)',
                  symptoms: [], // Placeholder for more content
                  prevention: [],
                ),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by disease name or symptom',
        prefixIcon: const Icon(Icons.search),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDiseaseExpansionTile(String title, {required List<String> symptoms, required List<String> prevention, String? freeTip}) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (symptoms.isNotEmpty) ...[
          const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...symptoms.map((s) => Text('• $s')).toList(),
          const SizedBox(height: 16),
        ],
        if (prevention.isNotEmpty) ...[
          const Text('Prevention:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...prevention.map((p) => Text('• $p')).toList(),
        ],
        if (freeTip != null && freeTip.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Free Tip:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 4),
                Text(freeTip, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: const Text('Report a Sickness'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
