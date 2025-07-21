import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/services/custom_recipes_service.dart';
import 'package:mama_recipe/widgets/recipe_image_picker.dart';

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

  String? _selectedImageUrl; // Changed from _selectedImagePath to _selectedImageUrl
  final CustomRecipesService _customRecipesService = CustomRecipesService();
  
  bool _isLoading = false;

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
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDarkMode
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.white,
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.xmark,
              color: _isLoading 
                  ? CupertinoColors.systemGrey
                  : (isDarkMode
                      ? const Color(0xFFAEAEB2)
                      : CupertinoColors.systemGrey),
              size: 24,
            ),
          ),
          middle: Text(
            'Create New Recipe',
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : _saveRecipe,
            child: Icon(
              CupertinoIcons.checkmark,
              color: _isLoading 
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemBlue,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    'Add a new recipe to your collection',
                    style: TextStyle(
                      color: isDarkMode
                          ? const Color(0xFFAEAEB2)
                          : CupertinoColors.systemGrey,
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
                  hintText: 'Enter each ingredient on a new line\n\nExample:\n2 cups flour\n1 cup butter\n1/2 cup sugar',
                  minLines: 5,
                ),
                const SizedBox(height: 24),

                // Cooking Method
                _buildSectionLabel('Cooking Method'),
                const SizedBox(height: 8),
                _buildExpandableTextArea(
                  controller: _methodController,
                  hintText: 'Describe the cooking steps\n\nExample:\n1. Preheat oven to 350°F\n2. Mix dry ingredients\n3. Add wet ingredients',
                  minLines: 6,
                ),
                const SizedBox(height: 24),

                // Tags
                _buildSectionLabel('Tags'),
                const SizedBox(height: 8),
                _buildSingleLineTextArea(
                  controller: _tagsController,
                  hintText: 'Enter tags separated by commas (e.g., dessert, easy, quick)',
                ),
                const SizedBox(height: 24),

                // Recipe Image
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: RecipeImagePicker(
                    onImageChanged: (imageUrl) {
                      setState(() {
                        _selectedImageUrl = imageUrl;
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: _isLoading 
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemOrange,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _saveRecipe,
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 12),
                                Text(
                                  'Creating Recipe...',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
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
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );
  }

  Widget _buildSingleLineTextArea({
    required TextEditingController controller,
    required String hintText,
  }) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2C2C2E)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey4,
            width: 1.0,
          ),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? const Color(0xFFAEAEB2)
                : CupertinoColors.systemGrey2,
          ),
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
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
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2C2C2E)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey4,
            width: 1.0,
          ),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? const Color(0xFFAEAEB2)
                : CupertinoColors.systemGrey2,
          ),
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: null,
          minLines: minLines,
          maxLines: null,
          expands: false,
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Future<void> _saveRecipe() async {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Clean and format ingredients
      final ingredients = _ingredientsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      // Clean and format instructions
      final instructions = _methodController.text.trim();

      // Clean and format tags
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .join(',');

      // Use image URL directly from RecipeImagePicker (it handles Supabase upload)
      String? imageUrl = _selectedImageUrl;

      // Create recipe using Firebase service
      final recipeId = await _customRecipesService.createCustomRecipe(
        recipeName: _titleController.text.trim(),
        ingredients: ingredients,
        instructions: instructions,
        tags: tags,
        imageUrl: imageUrl,
      );

      if (recipeId != null) {
        // Success - show dialog and return data
        final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
        
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: CupertinoAlertDialog(
              title: const Text('Recipe Saved'),
              content: const Text('Your recipe has been saved successfully!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, {
                      'success': true,
                      'recipeId': recipeId,
                    }); // Return success flag only, don't return recipe data
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        throw Exception('Failed to create recipe');
      }
    } catch (e) {
      print('Error saving recipe: $e');
      _showErrorDialog('Failed to save recipe. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
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
}