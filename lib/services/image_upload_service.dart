import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../config/supabase_config.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  static Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Validate file size
        final File file = File(image.path);
        final int fileSizeBytes = await file.length();
        
        if (fileSizeBytes > SupabaseConfig.maxFileSizeBytes) {
          throw Exception('Image size must be less than 5MB');
        }
        
        // Validate file extension
        final String extension = path.extension(image.path).toLowerCase().replaceAll('.', '');
        if (!SupabaseConfig.allowedExtensions.contains(extension)) {
          throw Exception('Only JPG, JPEG, PNG, and WebP images are allowed');
        }
      }
      
      return image;
    } catch (e) {
      print('❌ Error picking image: $e');
      rethrow;
    }
  }

  /// Upload image to Supabase Storage
  static Future<String> uploadImage({
    required XFile imageFile,
    required String recipeId,
    String? userId,
  }) async {
    try {
      final File file = File(imageFile.path);
      final Uint8List bytes = await file.readAsBytes();
      
      // Create unique filename
      final String extension = path.extension(imageFile.path).toLowerCase();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId ?? 'anonymous'}/${recipeId}_$timestamp$extension';
      
      print('📤 Uploading image: $fileName');
      
      // Upload to Supabase Storage
      await _supabase.storage
          .from(SupabaseConfig.recipeImagesBucket)
          .uploadBinary(fileName, bytes);
      
      // Get public URL
      final String publicUrl = _supabase.storage
          .from(SupabaseConfig.recipeImagesBucket)
          .getPublicUrl(fileName);
      
      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
      
    } catch (e) {
      print('❌ Error uploading image: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Delete image from Supabase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract filename from URL
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = uri.pathSegments.last;
      
      print('🗑️ Deleting image: $fileName');
      
      await _supabase.storage
          .from(SupabaseConfig.recipeImagesBucket)
          .remove([fileName]);
      
      print('✅ Image deleted successfully');
      return true;
      
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Update image (delete old and upload new)
  static Future<String> updateImage({
    required XFile newImageFile,
    required String recipeId,
    String? oldImageUrl,
    String? userId,
  }) async {
    try {
      // Upload new image first
      final String newImageUrl = await uploadImage(
        imageFile: newImageFile,
        recipeId: recipeId,
        userId: userId,
      );
      
      // Delete old image if it exists and is from Supabase
      if (oldImageUrl != null && oldImageUrl.contains(SupabaseConfig.supabaseUrl)) {
        await deleteImage(oldImageUrl);
      }
      
      return newImageUrl;
      
    } catch (e) {
      print('❌ Error updating image: $e');
      rethrow;
    }
  }

  /// Show image picker dialog
  static Future<XFile?> showImagePickerDialog() async {
    // This would typically be called from your UI layer
    // You can customize this based on your app's design
    try {
      // For now, default to gallery. You can modify this to show a dialog
      return await pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('❌ Error in image picker dialog: $e');
      return null;
    }
  }
}
