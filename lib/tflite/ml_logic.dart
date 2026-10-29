import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PredictionResult {
  final String label;
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.confidence,
  });
}

class TFlite {
  Interpreter? _interpreter;
  int _inputHeight = 128;
  int _inputWidth = 128;

  late final List<String> _labels = [
    'Speed limit (20km/h)',
    'Speed limit (30km/h)',
    'Speed limit (50km/h)',
    'Speed limit (60km/h)',
    'Speed limit (70km/h)',
    'Speed limit (80km/h)',
    'End of speed limit (80km/h)',
    'Speed limit (100km/h)',
    'Speed limit (120km/h)',
    'No passing',
    'No passing for vehicles over 3.5 metric tons',
    'Right-of-way at the next intersection',
    'Priority road',
    'Yield',
    'Stop',
    'No vehicles',
    'Vehicles over 3.5 metric tons prohibited',
    'No entry',
    'General caution',
    'Dangerous curve to the left',
    'Dangerous curve to the right',
    'Double curve',
    'Bumpy road',
    'Slippery road',
    'Road narrows on the right',
    'Road work',
    'Traffic signals',
    'Pedestrians',
    'Children crossing',
    'Bicycles crossing',
    'Beware of ice/snow',
    'Wild animals crossing',
    'End of all speed and passing limits',
    'Turn right ahead',
    'Turn left ahead',
    'Ahead only',
    'Go straight or right',
    'Go straight or left',
    'Keep right',
    'Keep left',
    'Roundabout mandatory',
    'End of no passing',
    'End of no passing by vehicles over 3.5 metric tons'
  ];

  Future<void> loadModel() async {
    final options = InterpreterOptions()..threads = 4;
    _interpreter = await Interpreter.fromAsset(
      'assets/traffic_sign_model.tflite',
      options: options,
    );
    final shape = _interpreter!.getInputTensor(0).shape;
    if (shape.length >= 3) {
      _inputHeight = shape[1];
      _inputWidth = shape[2];
    }
  }

  Future<PredictionResult> predict(File image) async {
    if (_interpreter == null) {
      await loadModel();
    }

    // Load and decode the image
    final imageBytes = await image.readAsBytes();
    img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

    if (decodedImage == null) {
      throw Exception("Image decoding failed");
    }

    // Resize the image to match model input shape
    img.Image resizedImage = img.copyResize(
      decodedImage,
      width: _inputWidth,
      height: _inputHeight,
    );

    // Normalize pixel values to 0.0 - 1.0 (RGB)
    List<List<List<double>>> input = List.generate(
      _inputHeight,
      (y) => List.generate(
        _inputWidth,
        (x) {
          img.Pixel pixel = resizedImage.getPixel(x, y);
          double r = pixel.r.toDouble() / 255.0;
          double g = pixel.g.toDouble() / 255.0;
          double b = pixel.b.toDouble() / 255.0;
          return [r, g, b];
        },
      ),
    );

    var inputArray = [input];
    List<List<double>> output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter!.run(inputArray, output);

    int predictedIndex = 0;
    double maxConfidence = output[0][0];

    for (int i = 1; i < output[0].length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        predictedIndex = i;
      }
    }

    return PredictionResult(
      label: _labels[predictedIndex],
      confidence: maxConfidence,
    );
  }
}

