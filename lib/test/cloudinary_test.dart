import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

class CloudinaryTestScreen extends StatefulWidget {
  const CloudinaryTestScreen({super.key});

  @override
  State<CloudinaryTestScreen> createState() => _CloudinaryTestScreenState();
}

class _CloudinaryTestScreenState extends State<CloudinaryTestScreen> {
  File? _image;
  String? _imageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _imageUrl = null;
        _errorMessage = null;
      });
      debugPrint('✓ Image picked: ${picked.path}');
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) {
      setState(() {
        _errorMessage = '❌ Please pick an image first';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Load Cloudinary credentials from .env file
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      debugPrint('🔍 Checking Cloudinary credentials...');
      debugPrint('   - Cloud Name: ${cloudName ?? "NOT SET"}');
      debugPrint('   - Upload Preset: ${preset ?? "NOT SET"}');

      if (cloudName == null || preset == null) {
        setState(() {
          _errorMessage =
              '❌ Missing Cloudinary credentials in .env\n- CLOUDINARY_CLOUD_NAME: ${cloudName ?? "NOT SET"}\n- CLOUDINARY_UPLOAD_PRESET: ${preset ?? "NOT SET"}';
          _isUploading = false;
        });
        return;
      }

      final uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      debugPrint('📤 Uploading to: $uri');

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();

      debugPrint('✓ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);

        setState(() {
          _imageUrl = data['secure_url'];
          _isUploading = false;
        });

        debugPrint('✅ Upload SUCCESS: ${data['secure_url']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Upload successful!'),
              backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          _errorMessage = '❌ Upload failed (HTTP ${response.statusCode})';
          _isUploading = false;
        });
        debugPrint('⚠️ Upload FAILED: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Error: $e';
        _isUploading = false;
      });
      debugPrint('⚠️ Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Cloudinary Upload Test'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Image Upload Test',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Test Cloudinary integration with .env credentials',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Image preview
            if (_image != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_image!, height: 250, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 64, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            // Buttons
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : uploadImage,
              icon: const Icon(Icons.cloud_upload),
              label: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Upload to Cloudinary'),
            ),
            const SizedBox(height: 24),
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            // Success message with URL
            if (_imageUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Upload Successful!',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Image URL:',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onLongPress: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('URL copied to clipboard')),
                        );
                      },
                      child: SelectableText(
                        _imageUrl!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.network(_imageUrl!, height: 200, fit: BoxFit.cover),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Back button
            OutlinedButton(
              onPressed: () {
                debugPrint('👈 Back to Home');
                context.go('/home');
              },
              child: const Text('← Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
