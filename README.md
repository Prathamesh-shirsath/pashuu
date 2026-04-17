# 🐄 𝗔𝗜-𝗯𝗮𝘀𝗲𝗱 𝗖𝗮𝘁𝘁𝗹𝗲 𝗕𝗿𝗲𝗲𝗱 𝗗𝗲𝘁𝗲𝗰𝘁𝗶𝗼𝗻(Pashu Parakh)
Pashu Parakh is an AI-powered mobile application designed to help farmers and field workers accurately identify cattle breeds using Computer Vision and Deep Learning. The app brings efficiency, accessibility, and precision to livestock management and valuation.

---

## 📌 Table of Contents

* [Overview](#-overview)
* [Features](#-features)
* [Tech Stack](#️-tech-stack)
* [System Architecture](#️-system-architecture)
* [Installation & Setup](#️-installation--setup)
* [Usage](#-usage)
* [Future Improvements](#-future-improvements)
* [Contributors](#-contributors)


---

## 🚀 Overview

In agriculture, identifying cattle breeds is essential for:

* Proper nutrition planning
* Disease prevention and treatment
* Fair pricing in livestock markets

**Pashu Parakh** automates breed identification using AI, making it faster, more accurate, and accessible via a mobile device.

---

## ✨ Features

* 🔍 **Breed Identification**
  Detect cow and buffalo breeds in real time using CNN models.

* 📚 **Information Hub**
  Access detailed information about breeds, including origin and characteristics.

* 💰 **Milk Profit Calculator**
  Estimate potential earnings based on milk production.

* 🌐 **Multilingual Support**
  Designed for diverse regional users.

* ⚡ **Lightweight AI Model**
  Uses MobileNetV2 and TensorFlow Lite for fast on-device inference.

---

## 🛠️ Tech Stack

| Category           | Technology             |
| ------------------ | ---------------------- |
| Mobile App         | Flutter                |
| Machine Learning   | TensorFlow Lite, Keras |
| Model Architecture | CNN (MobileNetV2)      |
| Frontend           | Dart                   |
| Model Training     | Python                 |

---

## 🏗️ System Architecture

The app follows an efficient pipeline:

1. **Image Acquisition**
   Capture or upload a cattle image.

2. **Preprocessing**
   Resize and normalize the image.

3. **Inference (Edge AI)**
   Run TensorFlow Lite model on-device.

4. **Result Display**
   Show:

   * Breed name
   * Confidence score
   * Breed details

---

## ⚙️ Installation & Setup

### Clone the Repository

```bash
git clone https://github.com/Prathamesh-shirsath/pashuu.git
cd pashuu
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

---

## 📱 Usage

1. Launch the app
2. Capture or upload an image of cattle
3. View predicted breed and confidence
4. Explore breed details
5. Use the milk calculator for profit estimation

---

## 🔮 Future Improvements

* Improve model accuracy with larger datasets
* Add support for more livestock types
* Cloud-based updates for AI model
* Voice interaction for ease of use
* Advanced analytics dashboard

---

## 👥 Contributors

* **Prathamesh Shirsath** – @Prathamesh-shirsath
* **Sakshi Khedkar** – @Sakshi17-13
* **Pratiksha Sonawane** 

---


