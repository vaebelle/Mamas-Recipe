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

  String?
  _selectedImageUrl; // Changed from _selectedImagePath to _selectedImageUrl
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
      child: Container(
        // CORRECTED GRADIENT TO MATCH HOME PAGE EXACTLY
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1C1C1E),
                    const Color(0xFF3D2914), // Darker orange - SAME AS HOME
                    const Color(0xFF2C1810), // Medium orange - SAME AS HOME
                    const Color(0xFF1C1C1E),
                  ]
                : [
                    const Color(0xFFFFF8F0), // Light cream - SAME AS HOME
                    const Color(0xFFFFE5CC), // Light orange - SAME AS HOME
                    const Color(0xFFFFF0E6), // Very light orange - SAME AS HOME
                    CupertinoColors.white, // SAME AS HOME
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0], // SAME STOPS AS HOME
          ),
        ),
        child: CupertinoPageScaffold(
          backgroundColor: const Color(0x00000000), // Transparent
          navigationBar: CupertinoNavigationBar(
            backgroundColor: const Color(0x00000000), // Transparent
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
                          : const Color(
                              0xFF2C1810,
                            )), // Darker for better contrast
                size: 24,
              ),
            ),
            middle: Text(
              'Create New Recipe',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.white
                    : const Color(
                        0xFF2C1810,
                      ), // Darker text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _saveRecipe,
              child: Icon(
                CupertinoIcons.checkmark,
                color: CupertinoColors.systemOrange, // Orange color
                size: 24,
              ),
            ),
          ),
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping on background
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
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
                            : const Color(
                                0xFF8B4513,
                              ), // Darker for better contrast
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
                    hintText:
                        'Enter each ingredient on a new line\n\nExample:\n2 cups flour\n1 cup butter\n1/2 cup sugar',
                    minLines: 6,
                  ),
                  const SizedBox(height: 24),

                  // Cooking Method
                  _buildSectionLabel('Cooking Method'),
                  const SizedBox(height: 8),
                  _buildExpandableTextArea(
                    controller: _methodController,
                    hintText:
                        'Describe the cooking steps\n\nExample:\n1. Preheat oven to 350°F\n2. Mix dry ingredients\n3. Add wet ingredients',
                    minLines: 6,
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  _buildSectionLabel('Tags'),
                  const SizedBox(height: 8),
                  _buildSingleLineTextArea(
                    controller: _tagsController,
                    hintText:
                        'Enter tags separated by commas (e.g., dessert, easy, quick)',
                  ),
                  const SizedBox(height: 24),

                  // Recipe Image
                  _buildSectionLabel('Recipe Image'),
                  const SizedBox(height: 12),
                  RecipeImagePicker(
                    onImageChanged: (imageUrl) {
                      setState(() {
                        _selectedImageUrl = imageUrl;
                      });
                    },
                    isDarkMode: isDarkMode,
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
          // CHANGED TO BLACK FOR BOTH MODES
          color: isDarkMode
              ? CupertinoColors
                    .white // White for dark mode
              : CupertinoColors.black, // Black for light mode
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
              ? const Color(0xFF2C2C2E).withOpacity(0.95)
              : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? CupertinoColors.systemOrange.withOpacity(0.3)
                : const Color(0xFFD2691E).withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? CupertinoColors.black.withOpacity(0.3)
                  : CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          // FIXED PLACEHOLDER STYLING FOR BALANCED ALIGNMENT
          placeholderStyle: TextStyle(
            fontSize: 16, // SAME SIZE AS INPUT TEXT
            color: isDarkMode
                ? const Color(0xFF8E8E93)
                : CupertinoColors.systemGrey2,
            height: 1.0, // NORMALIZED LINE HEIGHT
          ),
          style: TextStyle(
            fontSize: 16, // MATCHING TEXT SIZE
            color: isDarkMode ? const Color(0xFFE5E5E7) : CupertinoColors.black,
            height: 1.0, // MATCHING LINE HEIGHT FOR PERFECT ALIGNMENT
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: null,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
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
              ? const Color(0xFF2C2C2E).withOpacity(0.95)
              : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? CupertinoColors.systemOrange.withOpacity(0.3)
                : const Color(0xFFD2691E).withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? CupertinoColors.black.withOpacity(0.3)
                  : CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          // FIXED PLACEHOLDER STYLING FOR PERFECT ALIGNMENT WITH USER INPUT
          placeholderStyle: TextStyle(
            fontSize: 16, // SAME SIZE AS INPUT TEXT
            color: isDarkMode
                ? const Color(0xFF8E8E93)
                : CupertinoColors.systemGrey2,
            height: 1.2, // EXACT SAME LINE HEIGHT AS INPUT
            leadingDistribution: TextLeadingDistribution.even,
          ),
          style: TextStyle(
            fontSize: 16, // MATCHING TEXT SIZE
            color: isDarkMode ? const Color(0xFFE5E5E7) : CupertinoColors.black,
            height: 1.2, // EXACT SAME LINE HEIGHT AS PLACEHOLDER
            leadingDistribution: TextLeadingDistribution.even,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: null,
          minLines: minLines,
          maxLines: null,
          expands: false,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          // FORCE CONSISTENT TEXT BASELINE
          strutStyle: const StrutStyle(
            height: 1.2,
            leading: 0.0,
            forceStrutHeight: true,
          ),
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
