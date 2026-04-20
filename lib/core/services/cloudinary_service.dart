import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static Future<String?> uploadImage(File imageFile) async {
    // Load Cloudinary credentials from .env file
    // These values are loaded at app startup via: await dotenv.load(fileName: ".env");
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      debugPrint("❌ Cloudinary ENV chưa load hoặc thiếu key");
      debugPrint("   - CLOUDINARY_CLOUD_NAME: $cloudName");
      debugPrint("   - CLOUDINARY_UPLOAD_PRESET: $uploadPreset");
      return null;
    }

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final jsonData = json.decode(resData);

      debugPrint("UPLOAD SUCCESS: ${jsonData['secure_url']}");

      return jsonData['secure_url'];
    } else {
      debugPrint("UPLOAD FAILED: ${response.statusCode}");
      return null;
    }
  }
}
