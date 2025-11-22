// lib/models/disease_entry_model.dart

enum Species {
  All,
  Cattle,
  Buffalo,
  Both,
}

extension SpeciesName on Species {
  String get displayName {
    switch (this) {
      case Species.All:
        return "All (सभी)";
      case Species.Cattle:
        return "Cow (गाय)";
      case Species.Buffalo:
        return "Buffalo (भैंस)";
      case Species.Both:
        return "Cow + Buffalo (गाय + भैंस)";
    }
  }
}

class DiseaseEntry {
  final String name;            // English Name
  final String localName;       // Hindi Local Name
  final Species species;        // Species
  final String image;           // Image filename
  final List<String> symptoms;  // Symptoms (Hindi)
  final List<String> prevention; // Prevention (Hindi)
  final List<String> firstAid;   // First Aid (Hindi)
  final String keywords;        // Search Keywords

  const DiseaseEntry({
    required this.name,
    required this.localName,
    required this.species,
    required this.image,
    required this.symptoms,
    required this.prevention,
    required this.firstAid,
    required this.keywords,
  });

  /// SEARCH + FILTER LOGIC
  bool matches(String query, Species filterSpecies) {
    final q = query.toLowerCase();
    final matchText =
    "$name $localName $keywords".toLowerCase();

    final nameMatch = q.isEmpty || matchText.contains(q);
    final speciesMatch =
        filterSpecies == Species.All ||
            filterSpecies == species ||
            species == Species.Both;

    return nameMatch && speciesMatch;
  }
}
