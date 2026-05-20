import 'dart:async';
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

    debugPrint("🔍 [Cloudinary] Uploading image: ${imageFile.path}");
    debugPrint("   - CLOUDINARY_CLOUD_NAME: ${cloudName ?? 'NULL'}");
    debugPrint("   - CLOUDINARY_UPLOAD_PRESET: ${uploadPreset ?? 'NULL'}");

    if (cloudName == null || uploadPreset == null) {
      debugPrint("❌ [Cloudinary] ENV chưa load hoặc thiếu key");
      return null;
    }

    if (!imageFile.existsSync()) {
      debugPrint("❌ [Cloudinary] File không tồn tại: ${imageFile.path}");
      return null;
    }

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    try {
      debugPrint("📤 [Cloudinary] POST $url");

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Cloudinary upload timeout');
        },
      );

      debugPrint("📥 [Cloudinary] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final jsonData = json.decode(resData);
        final secureUrl = jsonData['secure_url'];

        debugPrint("✅ [Cloudinary] Upload SUCCESS: $secureUrl");
        return secureUrl;
      } else {
        final errBody = await response.stream.bytesToString();
        debugPrint("❌ [Cloudinary] Upload FAILED");
        debugPrint("   Status: ${response.statusCode}");
        debugPrint("   Response: $errBody");
        return null;
      }
    } on TimeoutException catch (e) {
      debugPrint("❌ [Cloudinary] Timeout: ${e.message}");
      return null;
    } on SocketException catch (e) {
      debugPrint("❌ [Cloudinary] Network error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ [Cloudinary] Unexpected error: $e");
      return null;
    }
  }
}
