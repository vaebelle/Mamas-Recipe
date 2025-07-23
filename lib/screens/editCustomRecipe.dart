import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/services/custom_recipes_service.dart';
import 'package:mama_recipe/models/custom_recipes.dart';
import 'package:mama_recipe/widgets/recipe_image_picker.dart';

class EditCustomRecipe extends StatefulWidget {
  final CustomRecipes recipe;

  const EditCustomRecipe({
    super.key,
    required this.recipe,
  });

  @override
  State<EditCustomRecipe> createState() => _EditCustomRecipeState();
}

class _EditCustomRecipeState extends State<EditCustomRecipe> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _currentImageUrl;
  final CustomRecipesService _customRecipesService = CustomRecipesService();
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
    
    // Add listeners to detect changes
    _titleController.addListener(_onDataChanged);
    _ingredientsController.addListener(_onDataChanged);
    _methodController.addListener(_onDataChanged);
    _tagsController.addListener(_onDataChanged);
  }

  void _loadRecipeData() {
    _titleController.text = widget.recipe.cRecipeName;
    _ingredientsController.text = widget.recipe.cRecipeIngredients;
    _methodController.text = widget.recipe.cRecipeInstructions;
    _tagsController.text = widget.recipe.tags;
    _currentImageUrl = widget.recipe.cRecipeImage.isNotEmpty ? widget.recipe.cRecipeImage : null;
  }

  void _onDataChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

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
        // GRADIENT TO MATCH HOME PAGE EXACTLY
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
            backgroundColor: CupertinoColors.white.withOpacity(
              0.0,
            ), // Make navigation bar transparent - SAME AS HOME
            border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : _handleCancel,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isLoading 
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemBlue,
                fontSize: 17,
              ),
            ),
          ),
          middle: Column(
            children: [
              Text(
                'Edit Recipe',
                style: TextStyle(
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Update your recipe details',
                style: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFAEAEB2)
                      : CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: (_hasChanges && !_isLoading) ? _updateRecipe : null,
            child: Text(
              'Update Recipe',
              style: TextStyle(
                color: (_hasChanges && !_isLoading)
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.systemGrey,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
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
                  hintText: 'Enter ingredients (separate each with a new line)',
                  minLines: 4,
                  maxLines: 10,
                ),
                const SizedBox(height: 24),

                // Instructions
                _buildSectionLabel('Instructions'),
                const SizedBox(height: 8),
                _buildExpandableTextArea(
                  controller: _methodController,
                  hintText: 'Enter cooking instructions',
                  minLines: 4,
                  maxLines: 10,
                ),
                const SizedBox(height: 24),

                // Tags
                _buildSectionLabel('Tags (Optional)'),
                const SizedBox(height: 8),
                _buildSingleLineTextArea(
                  controller: _tagsController,
                  hintText: 'Enter tags separated by commas (e.g., dinner, vegetarian)',
                ),
                const SizedBox(height: 24),

                // Recipe Image
                _buildSectionLabel('Recipe Image'),
                const SizedBox(height: 12),

                // Use RecipeImagePicker widget for consistent image handling
                RecipeImagePicker(
                  initialImageUrl: _currentImageUrl,
                  isDarkMode: isDarkMode,
                  onImageChanged: (imageUrl) {
                    setState(() {
                      if (imageUrl != null) {
                        // New image uploaded to Supabase
                        _currentImageUrl = imageUrl;
                      } else {
                        // Image removed
                        _currentImageUrl = null;
                      }
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 40),

                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: _isLoading 
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemOrange,
                      onPressed: _isLoading || !_hasChanges ? null : _updateRecipe,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text(
                              'Update Recipe',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 17,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode 
                ? const Color(0xFF38383A) 
                : CupertinoColors.systemGrey4,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: TextStyle(
            color: isDarkMode 
                ? const Color(0xFFAEAEB2) 
                : CupertinoColors.systemGrey,
            fontSize: 16,
          ),
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            fontSize: 16,
          ),
          decoration: null,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildExpandableTextArea({
    required TextEditingController controller,
    required String hintText,
    int minLines = 3,
    int maxLines = 8,
  }) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode 
                ? const Color(0xFF38383A) 
                : CupertinoColors.systemGrey4,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          placeholderStyle: TextStyle(
            color: isDarkMode 
                ? const Color(0xFFAEAEB2) 
                : CupertinoColors.systemGrey,
            fontSize: 16,
          ),
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            fontSize: 16,
          ),
          decoration: null,
          maxLines: maxLines,
          minLines: minLines,
        ),
      ),
    );
  }

  Future<void> _handleCancel() async {
    if (_hasChanges) {
      final shouldDiscard = await _showDiscardChangesDialog();
      if (shouldDiscard && mounted) {
        Navigator.pop(context, false);
      }
    } else {
      Navigator.pop(context, false);
    }
  }

  Future<bool> _showDiscardChangesDialog() async {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
    
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Your changes will be lost if you leave this page.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Keep Editing'),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Discard'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  Future<void> _updateRecipe() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input
      if (_titleController.text.trim().isEmpty) {
        _showErrorDialog('Please enter a recipe title');
        return;
      }

      if (_ingredientsController.text.trim().isEmpty) {
        _showErrorDialog('Please enter ingredients');
        return;
      }

      if (_methodController.text.trim().isEmpty) {
        _showErrorDialog('Please enter cooking instructions');
        return;
      }

      // Process ingredients and instructions
      final ingredients = _ingredientsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      final instructions = _methodController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .join(',');

      // Use the current image URL (RecipeImagePicker handles Supabase upload)
      final imageUrl = _currentImageUrl ?? '';

      // Update recipe using Firebase service
      final success = await _customRecipesService.updateCustomRecipe(
        recipeId: widget.recipe.cRecipeId,
        recipeName: _titleController.text.trim(),
        ingredients: ingredients,
        instructions: instructions,
        tags: tags,
        imageUrl: imageUrl,
      );

      if (success) {
        // Success - show dialog and return
        final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
        
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: CupertinoAlertDialog(
              title: const Text('Recipe Updated'),
              content: const Text('Your recipe has been updated successfully!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to previous screen with success flag
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      print('Error updating recipe: $e');
      _showErrorDialog('Failed to update recipe. Please try again.');
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
