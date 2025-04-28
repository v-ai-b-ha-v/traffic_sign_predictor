**#Traffic Sign Prediction App (Flutter + TensorFlow Lite)**
This Flutter application predicts traffic signs from images using a TensorFlow Lite (TFLite) model.
It helps demonstrate how machine learning can be integrated into mobile apps for autonomous driving assistance and educational purposes.

**Features**
Import an image from the device gallery

Classify traffic signs into multiple categories (43 classes from GTSRB dataset)

Smooth integration of TFLite model for on-device predictions

Theme switching (Day/Night mode) with a dynamic background

Lightweight and fast inference without sending data to any server

**Dataset and Model**
Dataset: German Traffic Sign Recognition Benchmark (GTSRB)

Model: Custom-trained deep learning model converted to TensorFlow Lite format

Input size: 32x32 RGB images

**Tech Stack**
Flutter (Dart)

TensorFlow Lite (TFLite)

BLoC for state management (optional: if you used it)

Image Picker (for gallery access)

**How to Use**
Pick an image from the gallery.

The app preprocesses and sends the image to the TFLite model.

The app displays the predicted traffic sign class.
