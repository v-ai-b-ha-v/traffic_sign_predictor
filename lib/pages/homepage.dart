import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterui/bloc/theme_bloc.dart';
import 'package:flutterui/components/PrettyFuzzyButton.dart';
import 'package:flutterui/components/myDrawer.dart';
import 'package:flutterui/configs/utils/image_picker_helper.dart';
import 'package:flutterui/tflite/ml_logic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();
  final TFlite _tflite = TFlite(); // Create an instance of TFlite
  String _prediction = '';

  XFile? _image; // To hold the picked image

  @override
  void initState() {
    super.initState();
    // Request permissions when the page is loaded
    _requestPermissions();
    _tflite.loadModel();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus photos = await Permission.photos.request();

    // Handling permission results
    if (!mounted) return; // Check if widget is still mounted

    if (photos.isGranted || photos.isLimited || photos.isRestricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photos permission granted"),
          duration: Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please grant photos permission"),
          duration: Duration(milliseconds: 2000),
        ),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {

        String backgroundImage ="";

        if(state is DarkTheme){
          backgroundImage = "assets/darkbg.jpg";
        }else{
          backgroundImage = "assets/lightbg.jpg";
        }

        return Scaffold(
          
          appBar: AppBar(),
          drawer: const MyDrawer(),
          body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(backgroundImage),
                  fit: BoxFit.fill,
                  opacity: (state is DarkTheme)?1:0.6),
                  
                ),
               child : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: MediaQuery.of(context).size.height*0.1,
                      width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 238, 65, 7),
                      ),
                      child: const Center(
                        child: Text(
                          "Traffic Sign Detection",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Center(
                      child: Center(
                        child: PrettyFuzzyButton(
                          foregroundColor: Colors.orange,
                          originalColor: const Color.fromARGB(255, 228, 234, 42),
                          secondaryColor: const Color.fromARGB(255, 93, 252, 8),
                          label: "Upload Image 🌄",
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 50),
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        height: MediaQuery.of(context).size.height*0.07,
                        decoration : BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 2),
                          color: Colors.green
                        ),
                        child: Center(
                          child: Text(
                            "You chose 👇🏻",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Theme.of(context).colorScheme.inversePrimary
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_image != null)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                File(_image!.path),
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.07,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 2),
                              color: const Color.fromARGB(255, 145, 145, 145)
                            ),
                            child: Center(
                              child: Text(
                                "Prediction: $_prediction",
                                style: TextStyle(fontSize: 20,
                                wordSpacing: 1),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                  ],
                ),
              ),
          ),
        );
      },
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePickerHelper.pickImageFromGallery();

      if (!mounted) return; // Ensure widget is mounted before updating UI

      if (image != null && image.path.isNotEmpty) {
        setState(() {
          _image = image;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image picked successfully"),
            duration: const Duration(milliseconds: 100),
          ),
        );

        // Call TFlite to make a prediction
        List<String> pair = await _tflite.predict(File(image.path));
        setState(() {
          _prediction = pair[0];
          
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No image selected"),
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error picking image"),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }
}
