import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _selectedImagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _methodController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.xmark,
            color: CupertinoColors.systemGrey,
            size: 24,
          ),
        ),
        middle: const Text(
          'Create New Recipe',
          style: TextStyle(
            color: CupertinoColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveRecipe,
          child: const Icon(
            CupertinoIcons.checkmark,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'Add a new recipe to your collection',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recipe Title
              _buildSectionLabel('Recipe Title'),
              const SizedBox(height: 8),
              _buildSingleLineTextArea(
                controller: _titleController,
                hintText: 'Enter recipe title',
              ),
              const SizedBox(height: 24),

              // Ingredients
              _buildSectionLabel('Ingredients'),
              const SizedBox(height: 8),
              _buildExpandableTextArea(
                controller: _ingredientsController,
                hintText: 'Enter each ingredient on a new line',
                minLines: 5,
              ),
              const SizedBox(height: 24),

              // Cooking Method
              _buildSectionLabel('Cooking Method'),
              const SizedBox(height: 8),
              _buildExpandableTextArea(
                controller: _methodController,
                hintText: 'Describe the cooking steps',
                minLines: 6,
              ),
              const SizedBox(height: 24),

              // Tags
              _buildSectionLabel('Tags'),
              const SizedBox(height: 8),
              _buildSingleLineTextArea(
                controller: _tagsController,
                hintText: 'Enter tags separated by commas',
              ),
              const SizedBox(height: 24),

              // Recipe Image
              _buildSectionLabel('Recipe Image'),
              const SizedBox(height: 12),
              _buildImageSelector(),
              const SizedBox(height: 40),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _saveRecipe,
                    child: const Text(
                      'Save Recipe',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black,
        ),
      ),
    );
  }

  Widget _buildSingleLineTextArea({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 1.0),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey2),
          style: const TextStyle(color: CupertinoColors.black),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: null,
        ),
      ),
    );
  }

  Widget _buildExpandableTextArea({
    required TextEditingController controller,
    required String hintText,
    required int minLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 1.0),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey2),
          style: const TextStyle(color: CupertinoColors.black),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: null,
          minLines: minLines,
          maxLines: null,
          expands: false,
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: _buildImageOption(
              icon: CupertinoIcons.camera,
              label: 'Camera',
              onTap: _selectFromCamera,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildImageOption(
              icon: CupertinoIcons.photo,
              label: 'Gallery',
              onTap: _selectFromGallery,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 1.0),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: CupertinoColors.systemGrey),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromCamera() {
    // Implement camera selection
    print('Select from camera');
    setState(() {
      _selectedImagePath = 'camera_image.jpg';
    });

    // Show confirmation
    _showImageSelectedDialog('Camera');
  }

  void _selectFromGallery() {
    // Implement gallery selection
    print('Select from gallery');
    setState(() {
      _selectedImagePath = 'gallery_image.jpg';
    });

    // Show confirmation
    _showImageSelectedDialog('Gallery');
  }

  void _showImageSelectedDialog(String source) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Image Selected'),
        content: Text('Image selected from $source'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _saveRecipe() {
    // Validate form
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a recipe title');
      return;
    }

    if (_ingredientsController.text.trim().isEmpty) {
      _showErrorDialog('Please enter ingredients');
      return;
    }

    if (_methodController.text.trim().isEmpty) {
      _showErrorDialog('Please enter cooking method');
      return;
    }

    // Process ingredients (split by new lines)
    List<String> ingredients = _ingredientsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Process tags (split by commas)
    List<String> tags = _tagsController.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    // Create recipe object
    Map<String, dynamic> newRecipe = {
      'id': DateTime.now().millisecondsSinceEpoch, // Simple ID generation
      'name': _titleController.text.trim(),
      'ingredients': ingredients,
      'method': _methodController.text.trim(),
      'tags': tags,
      'imagePath': _selectedImagePath ?? 'assets/images/placeholder.jpg',
      'isFavorite': false,
      'isMyRecipe': true,
    };

    // TODO: Save to your data source (database, API, etc.)
    print('Saving recipe: $newRecipe');

    // Show success and navigate back
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Recipe Saved'),
        content: const Text('Your recipe has been saved successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(
                context,
                newRecipe,
              ); // Return to previous screen with recipe data
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
