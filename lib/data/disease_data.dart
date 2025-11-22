import '../models/disease_entry_model.dart';

final List<DiseaseEntry> allDiseaseData = [

  // 1. FMD
  DiseaseEntry(
    name: "Foot-and-Mouth Disease (FMD)",
    localName: "मुख-खुर रोग",
    species: Species.Both,
    image: "assets/diseases/fmd.png",
    symptoms: [
      "मुँह, जीभ और खुरों पर फफोले",
      "अत्यधिक लार गिरना",
      "लंगड़ापन",
      "दूध में भारी कमी",
      "भूख कम लगना",
    ],
    prevention: [
      "हर 6 महीने में FMD टीकाकरण",
      "नए पशु को 14 दिन अलग रखें",
      "गंदे पानी और कीचड़ से बचाएँ",
    ],
    firstAid: [
      "फिटकरी पानी से मुँह धोएँ",
      "खुर पर KMnO4 लगाएँ",
      "तरल नरम आहार दें",
      "डॉक्टर बुलाएँ",
    ],
    keywords: "fmd foot mouth blister virus fever",
  ),

  // 2. HS
  DiseaseEntry(
    name: "Haemorrhagic Septicaemia (HS)",
    localName: "गलघोटू",
    species: Species.Buffalo,
    image: "assets/diseases/hs.jpg",
    symptoms: [
      "तेज बुखार",
      "गर्दन और छाती में भारी सूजन",
      "सांस लेने में कठिनाई",
      "दूध अचानक कम",
      "अचानक मृत्यु (24 घंटे के भीतर)",
    ],
    prevention: [
      "मानसून से पहले HS टीका",
      "गंदे पानी से बचाएँ",
    ],
    firstAid: [
      "सूजन पर ठंडी पट्टी",
      "खुले स्थान पर रखें",
      "डॉक्टर तुरंत बुलाएँ",
    ],
    keywords: "hs galghotu buffalo fever swelling",
  ),

  // 3. BQ
  DiseaseEntry(
    name: "Black Quarter (BQ)",
    localName: "फड़क्या",
    species: Species.Cattle,
    image: "assets/diseases/bq.jpg",
    symptoms: [
      "अचानक तेज बुखार",
      "जांघ/कंधे में सूजन",
      "सूजन दबाने पर खड़क-खड़क आवाज",
      "लंगड़ापन",
    ],
    prevention: [
      "मानसून से पहले BQ टीका",
      "कीचड़ से दूर रखें",
    ],
    firstAid: [
      "ठंडी पट्टी लगाएँ",
      "पशु को आराम दें",
      "डॉक्टर तुरंत बुलाएँ",
    ],
    keywords: "bq black quarter swelling fever cow",
  ),

  // 4. LSD
  DiseaseEntry(
    name: "Lumpy Skin Disease (LSD)",
    localName: "लंपी रोग",
    species: Species.Both,
    image: "assets/diseases/lsd.jpeg",
    symptoms: [
      "पूरे शरीर पर गोल कठोर गांठें",
      "बुखार",
      "आँख-नाक से पानी",
      "दूध में भारी कमी",
    ],
    prevention: [
      "LSD वैक्सीन",
      "मक्खी-मच्छर नियंत्रण",
    ],
    firstAid: [
      "आयोडीन लेप",
      "बुखार में ठंडी पट्टी",
      "तरल आहार दें",
    ],
    keywords: "lsd lumpy skin virus",
  ),

  // 5. Theileriosis
  DiseaseEntry(
    name: "Theileriosis",
    localName: "गोचीड ताप",
    species: Species.Cattle,
    image: "assets/diseases/theileriosis.jpeg",
    symptoms: [
      "तेज बुखार",
      "लिम्फ नोड सूजन",
      "एनीमिया",
      "कमजोरी",
    ],
    prevention: [
      "टिक नियंत्रण 7–10 दिन में",
      "नई गाय अलग रखें",
    ],
    firstAid: [
      "टिक हटाएँ",
      "छाया में रखें",
      "डॉक्टर बुलाएँ",
    ],
    keywords: "theileriosis tick fever",
  ),

  // 6. Babesiosis
  DiseaseEntry(
    name: "Babesiosis (Red Water)",
    localName: "लाल पेशाब रोग",
    species: Species.Both,
    image: "assets/diseases/babesiosis.jpeg",
    symptoms: [
      "लाल/भूरे रंग का पेशाब",
      "बुखार",
      "एनीमिया",
      "कमजोरी",
    ],
    prevention: [
      "टिक नियंत्रण",
    ],
    firstAid: [
      "ORS दें",
      "छाया में रखें",
    ],
    keywords: "babesiosis urine red water tick",
  ),

  // 7. Anaplasmosis
  DiseaseEntry(
    name: "Anaplasmosis",
    localName: "रक्त परजीवी रोग",
    species: Species.Both,
    image: "assets/diseases/anaplasmosis.jpeg",
    symptoms: [
      "बुखार",
      "आँख-मसूड़े पीले होना",
      "कमजोरी",
    ],
    prevention: [
      "मच्छर-टिक नियंत्रण",
    ],
    firstAid: [
      "ORS दें",
      "आराम दें",
    ],
    keywords: "anaplasmosis blood parasite",
  ),

  // 8. Mastitis
  DiseaseEntry(
    name: "Mastitis",
    localName: "स्तनदाह",
    species: Species.Both,
    image: "assets/diseases/mastitis.jpg",
    symptoms: [
      "थन सूजना",
      "दूध में गांठें",
      "दर्द",
    ],
    prevention: [
      "दूध दुहने में स्वच्छता",
    ],
    firstAid: [
      "थन पर ठंडी पट्टी",
      "पहली दूध धार फेंकें",
    ],
    keywords: "mastitis udder infection",
  ),

  // 9. Brucellosis
  DiseaseEntry(
    name: "Brucellosis",
    localName: "घोंगरा रोग",
    species: Species.Both,
    image: "assets/diseases/brucellosis.jpeg",
    symptoms: [
      "बार-बार गर्भपात",
      "कमजोर बच्चे",
      "दूध कम",
    ],
    prevention: [
      "Brucella टीका",
      "गर्भपात सामग्री नष्ट करें",
    ],
    firstAid: [
      "बीमार पशु अलग रखें",
    ],
    keywords: "brucellosis abortion",
  ),

  // 10. TB
  DiseaseEntry(
    name: "Bovine Tuberculosis (TB)",
    localName: "क्षयरोग",
    species: Species.Cattle,
    image: "assets/diseases/tb.jpeg",
    symptoms: [
      "लंबी खांसी",
      "वजन घटना",
      "दूध कम",
    ],
    prevention: [
      "TB-free पशु खरीदें",
    ],
    firstAid: [
      "बीमार पशु अलग रखें",
    ],
    keywords: "tb tuberculosis",
  ),

  // 11. BVD
  DiseaseEntry(
    name: "Bovine Viral Diarrhea (BVD)",
    localName: "वायरल अतिसार",
    species: Species.Cattle,
    image: "assets/diseases/bvd.jpg",
    symptoms: [
      "दस्त",
      "नाक से पानी",
      "कमजोरी",
    ],
    prevention: [
      "बीमार पशु अलग रखें",
    ],
    firstAid: [
      "ORS दें",
    ],
    keywords: "bvd diarrhea",
  ),

  // 12. Pneumonia
  DiseaseEntry(
    name: "Pneumonia",
    localName: "फेफड़ों का संक्रमण",
    species: Species.Both,
    image: "assets/diseases/pneumonia.webp",
    symptoms: [
      "तेज सांस",
      "खांसी",
      "नाक बहना",
    ],
    prevention: [
      "ठंड से बचाएँ",
    ],
    firstAid: [
      "पशु को गर्म रखें",
    ],
    keywords: "pneumonia cough fever",
  ),

  // 13. Milk Fever
  DiseaseEntry(
    name: "Milk Fever",
    localName: "दूध ज्वर",
    species: Species.Cattle,
    image: "assets/diseases/milk_fever.png",
    symptoms: [
      "पैर कांपना",
      "लेट जाना",
    ],
    prevention: [
      "कैल्शियम संतुलित आहार",
    ],
    firstAid: [
      "IV कैल्शियम (डॉक्टर)",
    ],
    keywords: "milk fever calcium",
  ),

  // 14. Ketosis
  DiseaseEntry(
    name: "Ketosis",
    localName: "दुधखाटी",
    species: Species.Cattle,
    image: "assets/diseases/ketosis.jpeg",
    symptoms: [
      "भूख न लगना",
      "दूध कम",
      "मुँह से मीठी गंध",
    ],
    prevention: [
      "ऊर्जा-rich आहार",
    ],
    firstAid: [
      "गुड़ पानी",
    ],
    keywords: "ketosis milk drop",
  ),

  // 15. Bloat
  DiseaseEntry(
    name: "Bloat",
    localName: "पोटफुगी",
    species: Species.Both,
    image: "assets/diseases/bloat.jpg",
    symptoms: [
      "बाएँ पेट का फूलना",
      "सांस फूलना",
      "बेचैनी",
    ],
    prevention: [
      "हरी चराई धीरे-धीरे दें",
    ],
    firstAid: [
      "चलाएँ",
      "एंटी-ब्लोट तेल",
    ],
    keywords: "bloat gas stomach",
  ),

  // 16. Indigestion
  DiseaseEntry(
    name: "Indigestion",
    localName: "अजीर्ण",
    species: Species.Both,
    image: "assets/diseases/indigestion.jpeg",
    symptoms: [
      "भूख कम",
      "पेट भारी",
    ],
    prevention: [
      "संतुलित आहार",
    ],
    firstAid: [
      "जीरा-गुड़ पानी",
    ],
    keywords: "indigestion stomach",
  ),

  // 17. Worm Infestation
  DiseaseEntry(
    name: "Worm Infestation",
    localName: "कृमि रोग",
    species: Species.Both,
    image: "assets/diseases/worms.webp",
    symptoms: [
      "पतलापन",
      "दस्त",
      "भूख कम",
    ],
    prevention: [
      "हर 3 महीने deworming",
    ],
    firstAid: [
      "ORS दें",
    ],
    keywords: "worm deworm",
  ),

  // 18. Foot Rot
  DiseaseEntry(
    name: "Foot Rot",
    localName: "खुर सड़ना",
    species: Species.Both,
    image: "assets/diseases/footrot.jpg",
    symptoms: [
      "खुर में सड़न की बदबू",
      "लंगड़ापन",
    ],
    prevention: [
      "शेड सूखा रखें",
    ],
    firstAid: [
      "पोटाश पानी से खुर धोएँ",
    ],
    keywords: "footrot khur infection",
  ),

  // 19. Pink Eye
  DiseaseEntry(
    name: "Pink Eye",
    localName: "कुरआँख",
    species: Species.Both,
    image: "assets/diseases/pinkeye.jpeg",
    symptoms: [
      "आँख से पानी",
      "लालपन",
      "धूप से डरना",
    ],
    prevention: [
      "मक्खी नियंत्रण",
    ],
    firstAid: [
      "आँख धोएँ",
    ],
    keywords: "pinkeye infection",
  ),

  // 20. Diarrhea
  DiseaseEntry(
    name: "Diarrhea",
    localName: "दस्त",
    species: Species.Both,
    image: "assets/diseases/diarrhea.jpeg",
    symptoms: [
      "पतला दस्त",
      "कमजोरी",
    ],
    prevention: [
      "स्वच्छ पानी दें",
    ],
    firstAid: [
      "ORS दें",
    ],
    keywords: "diarrhea loose motion",
  ),

  // 21. Anthrax
  DiseaseEntry(
    name: "Anthrax",
    localName: "फाशी रोग",
    species: Species.Both,
    image: "assets/diseases/anthrax.jpg",
    symptoms: [
      "अचानक मृत्यु",
      "नाक से काला खून",
    ],
    prevention: [
      "वार्षिक टीकाकरण",
    ],
    firstAid: [
      "शव न खोलें",
    ],
    keywords: "anthrax sudden death",
  ),

  // 22. Ringworm
  DiseaseEntry(
    name: "Ringworm",
    localName: "दाद / फंगल संक्रमण",
    species: Species.Both,
    image: "assets/diseases/ringworm.png",
    symptoms: [
      "गोल सफेद दाग",
      "बाल झड़ना",
    ],
    prevention: [
      "स्वच्छता",
    ],
    firstAid: [
      "एंटी-फंगल क्रीम",
    ],
    keywords: "ringworm fungus skin",
  ),

  // 23. Fly Bite Allergy
  DiseaseEntry(
    name: "Fly Bite Allergy",
    localName: "मक्खी काटने की एलर्जी",
    species: Species.Both,
    image: "assets/diseases/fly_bite.jpeg",
    symptoms: [
      "सूजन",
      "खुजली",
    ],
    prevention: [
      "फ्लाई रिपेलेंट",
    ],
    firstAid: [
      "ठंडी पट्टी",
    ],
    keywords: "fly bite allergy",
  ),

  // 24. Tick Infestation
  DiseaseEntry(
    name: "Tick Infestation",
    localName: "गोचीड (Tick)",
    species: Species.Both,
    image: "assets/diseases/ticks.jpeg",
    symptoms: [
      "टिक चिपके मिलना",
      "खून की कमी",
    ],
    prevention: [
      "साप्ताहिक डिपिंग",
    ],
    firstAid: [
      "टिक हटाएँ",
    ],
    keywords: "tick infestation",
  ),

  // 25. Heat Stress
  DiseaseEntry(
    name: "Heat Stress",
    localName: "गर्मी तनाव",
    species: Species.Both,
    image: "assets/diseases/heatstress.png",
    symptoms: [
      "तेज सांस",
      "ज्यादा लार",
    ],
    prevention: [
      "छाया + पानी",
    ],
    firstAid: [
      "ठंडा पानी दें",
      "पंखा / फॉगिंग",
    ],
    keywords: "heat stress hot temperature",
  ),

];
