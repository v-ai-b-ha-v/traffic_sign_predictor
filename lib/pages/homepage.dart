import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterui/bloc/theme_bloc.dart';
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
  final ImagePickerHelper _pickerHelper = ImagePickerHelper();
  final TFlite _tflite = TFlite();

  XFile? _image;
  PredictionResult? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tflite.loadModel();
  }

  Future<bool> _checkPermission(ImageSource source) async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        return status.isGranted;
      } else {
        var status = await Permission.photos.request();
        if (status.isGranted || status.isLimited) return true;
        // Fallback for Android 13+ or older
        var storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return true;
  }

  Future<void> _processImage(XFile? pickedFile) async {
    if (pickedFile == null || pickedFile.path.isEmpty) return;

    setState(() {
      _image = pickedFile;
      _isLoading = true;
      _result = null;
    });

    try {
      final res = await _tflite.predict(File(pickedFile.path));
      if (!mounted) return;
      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Prediction failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    await _checkPermission(ImageSource.gallery);
    final file = await _pickerHelper.pickImageFromGallery();
    _processImage(file);
  }

  Future<void> _pickFromCamera() async {
    await _checkPermission(ImageSource.camera);
    final file = await _pickerHelper.pickImageFromCamera();
    _processImage(file);
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _result = null;
      _isLoading = false;
    });
  }

  String _getSignCategory(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('speed limit')) return 'Speed Limit';
    if (lower.contains('curve') || lower.contains('road') || lower.contains('children') ||
        lower.contains('danger') || lower.contains('caution') || lower.contains('bicycles')) {
      return 'Warning';
    }
    if (lower.contains('no ') || lower.contains('prohibited') || lower.contains('stop') ||
        lower.contains('yield')) {
      return 'Prohibitory / Priority';
    }
    if (lower.contains('turn') || lower.contains('ahead') || lower.contains('keep') ||
        lower.contains('roundabout') || lower.contains('straight')) {
      return 'Mandatory';
    }
    return 'Information';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.traffic_rounded, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Traffic Vision",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  "AI Traffic Sign Classifier",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Toggle Theme",
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: primaryColor,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MyDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero / Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome, color: primaryColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "High-Accuracy Recognition",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Identifies 43 German Traffic Sign categories with 99%+ accuracy.",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Image Preview or Empty State Card
              if (_image == null)
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.35),
                        width: 1.8,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_a_photo_outlined, size: 40, color: primaryColor),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Select a Traffic Sign",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Snap with Camera or choose from Gallery",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                            child: Image.file(
                              File(_image!.path),
                              height: 260,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: _clearImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text("Analyzing sign with AI model..."),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Action Buttons (Camera & Gallery)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded, size: 20),
                      label: const Text(
                        "Camera",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.photo_library_rounded, size: 20, color: primaryColor),
                      label: Text(
                        "Gallery",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _pickFromGallery,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Prediction Result Card
              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getSignCategory(_result!.label),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_result!.confidence >= 0.8)
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${(_result!.confidence * 100).toStringAsFixed(1)}% Confidence",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: (_result!.confidence >= 0.8) ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _result!.label,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _result!.confidence.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            (_result!.confidence >= 0.8) ? Colors.green : primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

