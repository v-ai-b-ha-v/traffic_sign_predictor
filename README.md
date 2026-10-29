# 🚦 Traffic Vision — AI Traffic Sign Classifier

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-2.10+-FF6F00?logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://www.android.com)
[![Accuracy](https://img.shields.io/badge/Accuracy-99%25-brightgreen)](#machine-learning-architecture)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An intelligent, real-time traffic sign recognition mobile application built with **Flutter** and on-device **TensorFlow Lite (TFLite)**. Powered by a fine-tuned **EfficientNetB0** deep neural network, it recognizes **43 distinct categories** of traffic signs from the German Traffic Sign Recognition Benchmark (GTSRB) with **99%+ accuracy** — fully offline, with zero server dependencies.

---

## ✨ Features

- **⚡ 100% On-Device Inference:** Complete offline prediction using TensorFlow Lite without sending sensitive camera or image data to external servers.
- **🎯 High Accuracy (99%+):** Powered by transfer learning on EfficientNetB0 with custom regularization, reaching ~98-99% top-1 accuracy on GTSRB test sets.
- **📸 Dual Input Sources:** Select images directly from your device's **Photo Gallery** or capture signs on the go using the **Camera**.
- **🎨 Modern Glassmorphic UI:** Clean, responsive interface featuring dynamic category badges, animated confidence bars, and card previews.
- **🌓 Adaptive Theme:** Seamless switching between **Light** and **Dark** modes with animated background transitions.
- **🚀 Pure TFLite Built-ins:** Re-architected inference graph using strictly native TFLite kernels (`TFLITE_BUILTINS`), ensuring ultra-fast execution on standard mobile CPUs and GPUs without bulky Flex delegates.

---

## 🧠 Machine Learning Architecture

| Property | Specification |
| :--- | :--- |
| **Backbone** | EfficientNetB0 (Transfer Learning from ImageNet) |
| **Head Architecture** | `GlobalAveragePooling2D` → `BatchNorm` → `Dropout(0.4)` → `Dense(512, ReLU)` → `BatchNorm` → `Dropout(0.3)` → `Dense(256, ReLU)` → `BatchNorm` → `Dropout(0.2)` → `Dense(43, Softmax)` |
| **Input Shape** | `128 × 128 × 3` (RGB, float32 normalized to `[0.0, 1.0]`) |
| **Output Shape** | `1 × 43` (Softmax probability distribution) |
| **Dataset** | German Traffic Sign Recognition Benchmark ([GTSRB](https://benchmark.ini.rub.de/)) |
| **Quantization / Format**| Pure Float32 TensorFlow Lite (`.tflite`) |
| **Inference Threading** | Multi-threaded execution (`threads = 4`) |

> **Note on Datasets & Fonts:** The model is trained on German standard road signs using the **DIN 1451** typeface. International or UK signs that use alternative typefaces (such as the UK Transport font with curved numerals) may vary in prediction confidence.

---

## 📋 Supported Traffic Sign Classes (43 GTSRB Categories)

<details open>
<summary><b>Click to expand/collapse full list of 43 classes</b></summary>

### 🔴 Speed Limit Signs
| ID | Sign Name | ID | Sign Name |
| :---: | :--- | :---: | :--- |
| `0` | Speed limit (20km/h) | `5` | Speed limit (80km/h) |
| `1` | Speed limit (30km/h) | `6` | End of speed limit (80km/h) |
| `2` | Speed limit (50km/h) | `7` | Speed limit (100km/h) |
| `3` | Speed limit (60km/h) | `8` | Speed limit (120km/h) |
| `4` | Speed limit (70km/h) | `32` | End of all speed and passing limits |

### 🚫 Prohibitory & Restriction Signs
| ID | Sign Name | ID | Sign Name |
| :---: | :--- | :---: | :--- |
| `9` | No passing | `16` | Vehicles over 3.5 metric tons prohibited |
| `10` | No passing for vehicles over 3.5t | `17` | No entry |
| `15` | No vehicles | `41` | End of no passing |
| `42` | End of no passing by vehicles over 3.5t | | |

### 🛑 Priority & Regulatory Signs
| ID | Sign Name | ID | Sign Name |
| :---: | :--- | :---: | :--- |
| `11` | Right-of-way at next intersection | `13` | Yield |
| `12` | Priority road | `14` | Stop |

### ⚠️ Danger & Warning Signs
| ID | Sign Name | ID | Sign Name |
| :---: | :--- | :---: | :--- |
| `18` | General caution | `25` | Road work |
| `19` | Dangerous curve to the left | `26` | Traffic signals |
| `20` | Dangerous curve to the right | `27` | Pedestrians |
| `21` | Double curve | `28` | Children crossing |
| `22` | Bumpy road | `29` | Bicycles crossing |
| `23` | Slippery road | `30` | Beware of ice/snow |
| `24` | Road narrows on the right | `31` | Wild animals crossing |

### 🔵 Mandatory Direction Signs
| ID | Sign Name | ID | Sign Name |
| :---: | :--- | :---: | :--- |
| `33` | Turn right ahead | `37` | Go straight or left |
| `34` | Turn left ahead | `38` | Keep right |
| `35` | Ahead only | `39` | Keep left |
| `36` | Go straight or right | `40` | Roundabout mandatory |

</details>

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.7.0`)
- **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Machine Learning Runtime:** [tflite_flutter](https://pub.dev/packages/tflite_flutter) (`^0.11.0`)
- **Image Processing:** [image](https://pub.dev/packages/image) (`^4.5.4`) & [image_picker](https://pub.dev/packages/image_picker) (`^1.1.2`)
- **Permissions:** [permission_handler](https://pub.dev/packages/permission_handler) (`^12.0.0+1`)
- **Build System:** Gradle 8.11+, Android Gradle Plugin 8.9+, Built-in Kotlin (KGP decoupled)

---

## 📂 Project Structure

```text
Flutter/
├── android/                   # Native Android configuration (AGP 8.9+, ProGuard rules)
├── assets/                    # App assets
│   ├── traffic_sign_model.tflite # Converted EfficientNetB0 TFLite model (~19 MB)
│   ├── signname.csv           # Class ID to name mappings
│   ├── logo.png               # Launcher & brand icons
│   └── ...                    # Theme backgrounds (light/dark)
├── lib/
│   ├── bloc/ & cubit/         # ThemeBloc & ThemeCubit state handling
│   ├── components/            # Reusable UI widgets & custom buttons
│   ├── configs/utils/         # Image picker and permission helpers
│   ├── pages/
│   │   └── homepage.dart      # Main dashboard, prediction cards & category display
│   ├── tflite/
│   │   └── ml_logic.dart      # TFLite interpreter loading, resizing & normalization
│   ├── themes/                # Light and Dark theme palettes
│   └── main.dart              # App entry point
└── pubspec.yaml               # Flutter package configuration
```

---

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK:** Version `3.27.0` or later (`flutter doctor` should be clean).
2. **Android SDK:** Platform API 34+ / 36 with Java 17+.
3. **Physical Device or Android Emulator**.

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/v-ai-b-ha-v/traffic_sign_predictor.git
   cd traffic_sign_predictor
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run on a connected device:**
   ```bash
   flutter run
   ```

---

## 📦 Building APK

### Release APK (Universal)
```bash
flutter build apk --release
```
The output file is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Split Per-ABI APK (Optimized file size)
```bash
flutter build apk --release --split-per-abi
```
Generates tailored APKs for specific CPU architectures (`arm64-v8a`, `armeabi-v7a`, `x86_64`), reducing the installed app size significantly.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Acknowledgments

- **Dataset:** [German Traffic Sign Recognition Benchmark (GTSRB)](https://benchmark.ini.rub.de/)
- **TensorFlow Lite:** [TensorFlow Mobile Team](https://www.tensorflow.org/lite)
- **Flutter Community:** For plugins including `tflite_flutter`, `image`, and `flutter_bloc`.
