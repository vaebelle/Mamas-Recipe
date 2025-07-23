import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/image_upload_service.dart';

class RecipeImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageChanged;
  final bool isDarkMode;

  const RecipeImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
    this.isDarkMode = false,
  });

  @override
  State<RecipeImagePicker> createState() => _RecipeImagePickerState();
}

class _RecipeImagePickerState extends State<RecipeImagePicker> {
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _showImageSourceDialog() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose how you want to add an image for this recipe.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageUrl != null || _selectedImage != null)
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Remove Image'),
                onPressed: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImageUploadService.pickImage(source: source);
      
      if (image != null) {
        // Store the old image URL before replacing it
        final oldImageUrl = _imageUrl;
        
        setState(() {
          _selectedImage = image;
          _imageUrl = null; // Clear URL when selecting new image
          _isUploading = true;
        });
        
        // Upload image to Supabase
        try {
          final tempRecipeId = DateTime.now().millisecondsSinceEpoch.toString();
          final uploadedUrl = await ImageUploadService.uploadImage(
            imageFile: image,
            recipeId: tempRecipeId,
          );
          
          // Delete old image if it exists
          if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
            try {
              await ImageUploadService.deleteImage(oldImageUrl);
            } catch (e) {
              print('Warning: Failed to delete old image: $e');
              // Continue anyway - new image was uploaded successfully
            }
          }
          
          setState(() {
            _imageUrl = uploadedUrl;
            _selectedImage = null; // Clear local image after successful upload
            _isUploading = false;
          });
          
          // Pass the Supabase URL to parent
          widget.onImageChanged(uploadedUrl);
        } catch (e) {
          setState(() {
            _isUploading = false;
            _selectedImage = null;
            _imageUrl = oldImageUrl; // Restore old image URL on upload failure
          });
          
          if (mounted) {
            _showErrorDialog('Failed to upload image: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to pick image: ${e.toString()}');
      }
    }
  }

  void _removeImage() async {
    // Store the current image URL before removing
    final imageUrlToDelete = _imageUrl;
    
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
    
    // Delete from Supabase if it exists
    if (imageUrlToDelete != null && imageUrlToDelete.isNotEmpty) {
      try {
        await ImageUploadService.deleteImage(imageUrlToDelete);
      } catch (e) {
        print('Warning: Failed to delete image from Supabase: $e');
        // Continue anyway - image was removed from UI
      }
    }
    
    widget.onImageChanged(null);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    Widget imageWidget;
    
    if (_selectedImage != null) {
      // Show selected local image (during upload process)
      imageWidget = Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Show existing network image from Supabase
      imageWidget = Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            CupertinoIcons.photo_on_rectangle,
            size: 50,
            color: widget.isDarkMode
                ? const Color(0xFF8E8E93)
                : CupertinoColors.systemGrey3,
          );
        },
      );
    } else {
      // Show placeholder
      imageWidget = Icon(
        CupertinoIcons.camera,
        size: 50,
        color: widget.isDarkMode
            ? const Color(0xFF8E8E93)
            : CupertinoColors.systemGrey3,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF2C2C2E).withOpacity(0.95)
              : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: widget.isDarkMode
                ? CupertinoColors.systemOrange.withOpacity(0.3)
                : const Color(0xFFD2691E).withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode
                  ? CupertinoColors.black.withOpacity(0.3)
                  : CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              // Image or placeholder
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: (_selectedImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                    ? imageWidget
                    : Center(child: imageWidget),
              ),
              
              // Upload indicator overlay
              if (_isUploading)
                Container(
                  color: CupertinoColors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(color: CupertinoColors.white),
                        SizedBox(height: 8),
                        Text(
                          'Uploading...',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: _buildImageDisplay(),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(
            'Tap to add or change recipe image',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode
                  ? const Color(0xFFAEAEB2)
                  : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }
}
