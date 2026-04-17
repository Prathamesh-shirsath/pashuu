# 🐄 **𝗔𝗜-𝗯𝗮𝘀𝗲𝗱 𝗖𝗮𝘁𝘁𝗹𝗲 𝗕𝗿𝗲𝗲𝗱 𝗗𝗲𝘁𝗲𝗰𝘁𝗶𝗼𝗻(Pashu Parakh)**

**Pashu Parakh** is an AI-powered mobile solution designed to assist farmers and field workers in identifying cattle breeds accurately using Computer Vision. By leveraging Deep Learning, this project aims to bring precision to livestock management and valuation.

---

## 🚀 Overview

In the agricultural sector, identifying the exact breed of cattle is essential for proper nutrition, medical care, and fair market pricing. **Pashu Parakh** automates this process through a user-friendly interface.

### ✨ Key Features
* **Breed Identification:** Real-time detection of cow and buffalo breeds using CNN.
* **Information Hub:** Detailed insights into different breeds, their characteristics, and origins.
* **Milk Profit Calculator:** A utility tool to help farmers estimate earnings based on milk yield.
* **Multilingual Support:** Designed to be accessible to users in different regions.
* **Lightweight Model:** Optimized for mobile deployment using Transfer Learning.

---

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Mobile Framework** | [Flutter](https://flutter.dev/) |
| **Machine Learning** | TensorFlow Lite / Keras |
| **Architecture** | CNN (MobileNetV2) |
| **Languages** | Dart, Python |

---

## 🏗️ System Architecture

The project follows a streamlined pipeline to ensure high accuracy on mobile devices:

1. **Image Acquisition:** User captures or uploads a cattle image.
2. **Preprocessing:** Image resizing and normalization ($224 \times 224$ pixels).
3. **Inference:** The TFLite model processes the image on the device (Edge AI).
4. **Result Display:** Breed name and confidence score are displayed instantly.

---


## ⚙️ Installation & Setup

To get a local copy up and running, follow these simple steps.

### Prerequisites
* **Flutter SDK:** [Install Flutter](https://docs.flutter.dev/get-started/install) (Stable Channel)
* **Dart SDK:** Included with Flutter
* **Android Studio / VS Code:** With Flutter and Dart plugins installed
* **Git:** [Install Git](https://git-scm.com/downloads)

### 1. Clone the Project

```bash
git clone [https://github.com/Prathamesh-shirsath/pashuu.git](https://github.com/Prathamesh-shirsath/pashuu.git)
cd pashuu
```

### 2. Install Dependencies
This command will fetch all the necessary Flutter packages (like TensorFlow Lite, Image Picker, etc.) listed in pubspec.yaml.
```
flutter pub get
```

### 3. Setup the TFLite Model
Ensure your .tflite model and labels file are placed in the correct directory (usually assets/):
```bash
assets/model.tflite
```

```bash
assets/labels.txt
```

Check pubspec.yaml to ensure these assets are declared under the assets: section.

### 4. Connect Device & Run
Connect your Android/iOS device via USB or start an emulator, then run:

```Bash
flutter run
```

👥 Contributors
Prathamesh Shirsath - @Prathamesh-shirsath

[Sakshi Khedkar] - [@Sakshi17-13]

[Pratiksha Sonawane] - 
