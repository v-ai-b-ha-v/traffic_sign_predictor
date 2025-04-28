import 'package:image_picker/image_picker.dart';
import 'dart:io';  // For using the File class

class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  
}
