import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:csv/csv.dart';
import 'package:image/image.dart' as img;

class TFlite {
  late Interpreter _interpreter;
  late final List<String> _labels = ['Speed limit (20km/h)',
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
  'End of no passing by vehicles over 3.5 metric'];

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/traffic_sign_model.tflite');;
  }

 Future<List<String>> predict(File image) async {
  // Load and decode the image
  final imageBytes = await image.readAsBytes();
  img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

  if (decodedImage == null) {
    throw Exception("Image decoding failed");
  }

  

  // Resize the image to match the input shape of the model (32x32)
  img.Image resizedImage = img.copyResize(decodedImage, width: 32, height: 32);

  // Normalize pixel values to the range of 0-1 and prepare input as a list of floats
  List<List<List<double>>> input = List.generate(
    32,
    (i) => List.generate(
      32,
      (j) {
        // Extract pixel values and normalize (from 0-255 to 0-1)
        img.Pixel pixel = resizedImage.getPixel(i, j);
        double r = pixel.r.toDouble() / 255.0;  // Red channel
        double g = pixel.g.toDouble() / 255.0;  // Green channel
        double b = pixel.b.toDouble() / 255.0;  // Blue channel

    

        return [r, g, b];
      },
    ),
  );

  // Prepare the input in the shape expected by the model: [1, 32, 32, 3]
  var inputArray = input.reshape([1, 32, 32, 3]);


  // Prepare output array with the correct shape: [1, 43] (for 43 classes)
  List<List<double>> output = List.generate(1, (_) => List.filled(43, 0.0));



  // Run inference using the model
  _interpreter.run(inputArray, output);

  // Find the index with the highest confidence
  int predictedIndex = -1;
  double confidence = -1;

  for(int i = 0;i < output[0].length;i++){

      if(confidence < output[0][i]){
          predictedIndex = i;
          confidence = output[0][i];
      }

  }
  // Return the predicted label
  return [_labels[predictedIndex],confidence.toString()];
}


}
