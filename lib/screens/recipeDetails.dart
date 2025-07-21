import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/services/favorites_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isDarkMode;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.isDarkMode,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _isFavorite = false;
  bool _isDarkMode = false;
  bool _isUpdatingFavorite = false;
  bool _favoriteChanged = false;
  
  // BUG FIX: Use lightweight favorites service for faster operations
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe['isFavorite'] ?? false;
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: _isDarkMode
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.recipe['name'] ?? 'Recipe Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // BUG FIX: Only return data if favorite actually changed
              if (_favoriteChanged) {
                Navigator.pop(context, {
                  'favoriteChanged': true,
                  'isFavorite': _isFavorite,
                  'recipeId': widget.recipe['id'],
                  'recipeType': widget.recipe['isMyRecipe'] == true ? 'custom' : 'global',
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              CupertinoIcons.back,
              color: _isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
            ),
          ),
          trailing: _isUpdatingFavorite
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CupertinoActivityIndicator(),
                )
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _toggleFavorite,
                  child: Icon(
                    _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: _isFavorite
                        ? CupertinoColors.systemRed
                        : (_isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black),
                    size: 24,
                  ),
                ),
          backgroundColor: _isDarkMode
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.white,
          border: null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image
                _buildRecipeImage(),
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title
                      Text(
                        widget.recipe['name'] ?? 'Recipe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tags
                      if (widget.recipe['tags'] != null && (widget.recipe['tags'] as List).isNotEmpty) ...[
                        _buildTags(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Ingredients Section
                      _buildSection(
                        title: 'Ingredients',
                        child: _buildIngredientsList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Instructions Section
                      _buildSection(
                        title: 'Instructions',
                        child: _buildMethodText(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BUG FIX: Ultra-fast favorite toggle with correct service method names
  Future<void> _toggleFavorite() async {
    if (_isUpdatingFavorite) return;
    
    final originalStatus = _isFavorite;
    final newStatus = !originalStatus;
    final recipeId = widget.recipe['id'] as String? ?? '';
    final recipeType = widget.recipe['isMyRecipe'] == true ? 'custom' : 'global';
    
    print('⚡ Starting fast favorite toggle for $recipeId: $originalStatus -> $newStatus');
    
    // Immediate UI feedback
    setState(() {
      _isUpdatingFavorite = true;
      _isFavorite = newStatus;
    });

    try {
      bool success;
      
      if (newStatus) {
        // Adding to favorites - use correct method name
        success = await _favoritesService.addToFavorites(
          recipeId: recipeId,
          recipeType: recipeType,
        );
      } else {
        // Removing from favorites - use correct method name
        success = await _favoritesService.removeFromFavorites(
          recipeId: recipeId,
          recipeType: recipeType,
        );
      }

      if (success) {
        print('✅ Fast favorite toggle successful');
        _favoriteChanged = true;
      } else {
        print('❌ Fast favorite toggle failed');
        // Revert UI
        setState(() {
          _isFavorite = originalStatus;
        });
        _showErrorDialog('Failed to update favorite status. Please try again.');
      }
    } catch (e) {
      print('❌ Error in fast favorite toggle: $e');
      // Revert UI
      setState(() {
        _isFavorite = originalStatus;
      });
      _showErrorDialog('Failed to update favorite status. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFavorite = false;
        });
      }
    }
  }

  Widget _buildRecipeImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isDarkMode
            ? const Color(0xFF2C2C2E)
            : CupertinoColors.systemGrey6,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: widget.recipe['imagePath'] != null && widget.recipe['imagePath'].toString().isNotEmpty
            ? _buildImage(widget.recipe['imagePath'])
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    // Check if it's a network URL (Supabase) or local asset
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image (Supabase URL)
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: _isDarkMode
                ? const Color(0xFF2C2C2E)
                : CupertinoColors.systemGrey6,
            child: Center(
              child: CupertinoActivityIndicator(
                color: _isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading image: $error');
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Local asset image
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: _isDarkMode
          ? const Color(0xFF2C2C2E)
          : CupertinoColors.systemGrey6,
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 64,
          color: _isDarkMode
              ? const Color(0xFF8E8E93)
              : CupertinoColors.systemGrey3,
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = widget.recipe['tags'] as List<String>? ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? const Color(0xFF3A3A3C)
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode
                  ? const Color(0xFFAEAEB2)
                  : CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = widget.recipe['ingredients'] as List<String>? ?? [];
    if (ingredients.isEmpty) {
      return Text(
        'No ingredients listed',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode
              ? const Color(0xFFAEAEB2)
              : CupertinoColors.systemGrey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemOrange,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMethodText() {
    final method = widget.recipe['method'] as String? ?? '';
    if (method.isEmpty) {
      return Text(
        'No instructions provided',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode
              ? const Color(0xFFAEAEB2)
              : CupertinoColors.systemGrey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Simplified method parsing for better performance
    if (method.contains(RegExp(r'\d+\.'))) {
      return Text(
        method,
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          height: 1.5,
        ),
      );
    }

    final steps = method.split('.').where((s) => s.trim().isNotEmpty).toList();

    if (steps.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value.trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    step.endsWith('.') ? step : '$step.',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Text(
        method,
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          height: 1.5,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
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