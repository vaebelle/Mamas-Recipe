import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/widgets/slidingSegment.dart';
import 'package:mama_recipe/widgets/card.dart';
import 'package:mama_recipe/screens/newRecipe.dart';
import 'package:mama_recipe/screens/settings.dart';
import 'package:mama_recipe/screens/recipeDetails.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/services/recipe_service.dart';
import 'package:mama_recipe/services/favorites_service.dart';
import 'package:mama_recipe/models/recipe_models.dart';

final searchController = TextEditingController();

// Define the recipe categories enum
enum RecipeCategory { allRecipes, favorites, myRecipes }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  RecipeCategory _selectedCategory = RecipeCategory.allRecipes;
  bool _isDarkMode = false;
  
  // Firebase services
  final RecipeService _recipeService = RecipeService();
  final FavoritesService _favoritesService = FavoritesService();
  
  // Data lists
  List<Recipe> _allRecipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _myRecipes = [];
  List<Recipe> _displayedRecipes = [];
  
  // Loading states
  bool _isLoading = true;
  String _searchQuery = '';

  // Cache for favorite status to avoid constant rebuilding
  Map<String, bool> _favoriteStatusCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
    _loadData();
    
    // Listen to search changes
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
        _filterRecipes();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.removeListener(() {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadThemePreference();
    }
  }

  Future<void> _loadThemePreference() async {
    final isDark = SharedPreferencesHelper.instance.isDarkMode;
    if (mounted && isDark != _isDarkMode) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📊 Loading data...');
      
      // Load each type of data separately for better error handling
      List<Recipe> allRecipes = [];
      List<Recipe> favoriteRecipes = [];
      List<Recipe> myRecipes = [];

      // Load global recipes first
      try {
        final globalRecipes = await _recipeService.getGlobalRecipes();
        print('✅ Loaded ${globalRecipes.length} global recipes');
        allRecipes.addAll(globalRecipes);
      } catch (e) {
        print('❌ Error loading global recipes: $e');
      }

      // Load custom recipes
      try {
        final customRecipes = await _recipeService.getCustomRecipes();
        print('✅ Loaded ${customRecipes.length} custom recipes');
        allRecipes.addAll(customRecipes);
        myRecipes = customRecipes;
      } catch (e) {
        print('❌ Error loading custom recipes: $e');
      }

      // Load favorites
      try {
        favoriteRecipes = await _favoritesService.getFavoriteRecipesWithData();
        print('✅ Loaded ${favoriteRecipes.length} favorite recipes');
      } catch (e) {
        print('❌ Error loading favorites: $e');
      }

      // Load favorite status cache
      await _loadFavoriteStatusCache(allRecipes);

      // Sort all recipes by creation date
      allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _allRecipes = allRecipes;
          _favoriteRecipes = favoriteRecipes;
          _myRecipes = myRecipes;
          _isLoading = false;
          
          print('📈 Final counts - All: ${_allRecipes.length}, Favorites: ${_favoriteRecipes.length}, My: ${_myRecipes.length}');
          
          _filterRecipes();
        });
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load recipes. Please try again.');
      }
    }
  }

  Future<void> _loadFavoriteStatusCache(List<Recipe> recipes) async {
    _favoriteStatusCache.clear();
    
    for (Recipe recipe in recipes) {
      try {
        final isFavorite = await _favoritesService.isRecipeFavorited(
          recipeId: recipe.id,
          recipeType: recipe.isGlobal ? 'global' : 'custom',
        );
        _favoriteStatusCache['${recipe.id}_${recipe.type.name}'] = isFavorite;
      } catch (e) {
        print('❌ Error loading favorite status for ${recipe.id}: $e');
        _favoriteStatusCache['${recipe.id}_${recipe.type.name}'] = false;
      }
    }
    
    print('💾 Loaded favorite status for ${_favoriteStatusCache.length} recipes');
  }

  void _filterRecipes() {
    List<Recipe> baseRecipes;
    
    switch (_selectedCategory) {
      case RecipeCategory.allRecipes:
        baseRecipes = _allRecipes;
        break;
      case RecipeCategory.favorites:
        baseRecipes = _favoriteRecipes;
        break;
      case RecipeCategory.myRecipes:
        baseRecipes = _myRecipes;
        break;
    }

    if (_searchQuery.isEmpty) {
      _displayedRecipes = baseRecipes;
    } else {
      _displayedRecipes = baseRecipes
          .where((recipe) => recipe.containsSearchTerms(_searchQuery))
          .toList();
    }
    
    print('🔍 Filtered to ${_displayedRecipes.length} recipes for category ${_selectedCategory.name}');
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
        navigationBar: navigationBar(),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: _loadData,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Category title and Add Recipe button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getCategoryDisplayName(_selectedCategory),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _handleAddRecipe,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.add,
                                    color: CupertinoColors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add Recipe',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextField(
                      controller: searchController,
                      hintText: "Search recipe",
                      obscureText: false,
                      borderRadius: 13.0,
                      pathName: "assets/icons/search.svg",
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: CustomSegmentedControl<RecipeCategory>(
                        groupValue: _selectedCategory,
                        backgroundColor: _isDarkMode
                            ? const Color(0xFF2C2C2E)
                            : CupertinoColors.systemGrey6,
                        thumbColor: _isDarkMode
                            ? const Color(0xFF3A3A3C)
                            : CupertinoColors.white,
                        onValueChanged: (RecipeCategory? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                              _filterRecipes();
                            });
                          }
                        },
                        children: <RecipeCategory, Widget>{
                          RecipeCategory.allRecipes: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'All',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          RecipeCategory.favorites: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Favorites',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          RecipeCategory.myRecipes: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Personal',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              // Recipe cards as a sliver
              _buildRecipeSliver(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSliver() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 20),
              SizedBox(height: 16),
              Text('Loading recipes...'),
            ],
          ),
        ),
      );
    }

    if (_displayedRecipes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedCategory == RecipeCategory.favorites
                    ? CupertinoIcons.heart
                    : _selectedCategory == RecipeCategory.myRecipes
                    ? CupertinoIcons.book
                    : CupertinoIcons.search,
                size: 64,
                color: _isDarkMode
                    ? const Color(0xFFAEAEB2)
                    : CupertinoColors.systemGrey3,
              ),
              const SizedBox(height: 16),
              Text(
                _getEmptyStateMessage(_selectedCategory),
                style: TextStyle(
                  color: _isDarkMode
                      ? const Color(0xFFAEAEB2)
                      : CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _loadData,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final recipe = _displayedRecipes[index];
        final favoriteKey = '${recipe.id}_${recipe.type.name}';
        final isFavorite = _favoriteStatusCache[favoriteKey] ?? false;
        
        return RecipeCard(
          imagePath: recipe.imageUrl,
          cardName: recipe.name,
          ingredients: recipe.ingredientsList,
          method: recipe.instructions,
          tags: recipe.tagsList,
          isFavorite: isFavorite,
          backgroundColor: _isDarkMode
              ? const Color(0xFF2C2C2E)
              : CupertinoColors.white,
          nameStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
          sectionHeaderStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
          ingredientStyle: TextStyle(
            fontSize: 14,
            color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            height: 1.3,
          ),
          methodStyle: TextStyle(
            fontSize: 14,
            color: _isDarkMode
                ? const Color(0xFFAEAEB2)
                : CupertinoColors.systemGrey,
            height: 1.4,
          ),
          tagBackgroundColor: _isDarkMode
              ? const Color(0xFF3A3A3C)
              : CupertinoColors.systemGrey6,
          tagStyle: TextStyle(
            fontSize: 12,
            color: _isDarkMode
                ? const Color(0xFFAEAEB2)
                : CupertinoColors.systemGrey,
            fontWeight: FontWeight.w500,
          ),
          onEdit: recipe.isCustom && recipe.userId == _recipeService.customService.currentUserId
              ? () => _handleEditRecipe(recipe)
              : null,
          onDelete: recipe.isCustom && recipe.userId == _recipeService.customService.currentUserId
              ? () => _handleDeleteRecipe(recipe)
              : null,
          onFavorite: () => _handleFavoriteToggle(recipe),
          onTap: () => _handleRecipeTap(recipe),
        );
      }, childCount: _displayedRecipes.length),
    );
  }

  String _getEmptyStateMessage(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.allRecipes:
        return _searchQuery.isNotEmpty 
            ? 'No recipes found for "$_searchQuery".\nTry a different search term.'
            : 'No recipes available.\nCheck your internet connection and try refreshing.';
      case RecipeCategory.favorites:
        return 'No favorite recipes yet.\nStart adding some favorites by tapping the heart icon!';
      case RecipeCategory.myRecipes:
        return 'You haven\'t created any recipes yet.\nTap the + button to create your first recipe!';
    }
  }

  Future<void> _handleEditRecipe(Recipe recipe) async {
    // Navigate to edit recipe screen
    print('Edit recipe: ${recipe.name}');
    // TODO: Implement edit functionality
  }

  Future<void> _handleDeleteRecipe(Recipe recipe) async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Delete Recipe'),
          content: Text(
            'Are you sure you want to delete "${recipe.name}"? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.pop(context);
                
                final success = await _recipeService.customService.deleteCustomRecipe(recipe.id);
                if (success) {
                  await _loadData(); // Refresh data
                  if (mounted) {
                    _showSuccessDialog('Recipe deleted successfully');
                  }
                } else {
                  if (mounted) {
                    _showErrorDialog('Failed to delete recipe. Please try again.');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFavoriteToggle(Recipe recipe) async {
    print('🔄 Toggling favorite for: ${recipe.name}');
    
    // Show immediate feedback
    final favoriteKey = '${recipe.id}_${recipe.type.name}';
    final currentStatus = _favoriteStatusCache[favoriteKey] ?? false;
    
    // Optimistic update
    setState(() {
      _favoriteStatusCache[favoriteKey] = !currentStatus;
    });

    try {
      final success = await _recipeService.toggleRecipeFavorite(recipe);
      
      if (success) {
        print('✅ Favorite toggle successful');
        // Refresh data to get updated favorites list
        await _loadData();
      } else {
        print('❌ Favorite toggle failed');
        // Revert optimistic update
        setState(() {
          _favoriteStatusCache[favoriteKey] = currentStatus;
        });
        _showErrorDialog('Failed to update favorite status');
      }
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      // Revert optimistic update
      setState(() {
        _favoriteStatusCache[favoriteKey] = currentStatus;
      });
      _showErrorDialog('Failed to update favorite status');
    }
  }

  Future<void> _handleRecipeTap(Recipe recipe) async {
    // Record view for analytics
    await _recipeService.recordRecipeView(recipe);
    
    // Convert Recipe to Map for RecipeDetailsScreen
    final favoriteKey = '${recipe.id}_${recipe.type.name}';
    final isFavorite = _favoriteStatusCache[favoriteKey] ?? false;
    
    final recipeMap = {
      'id': recipe.id,
      'name': recipe.name,
      'ingredients': recipe.ingredientsList,
      'method': recipe.instructions,
      'tags': recipe.tagsList,
      'imagePath': recipe.imageUrl,
      'isFavorite': isFavorite,
      'isMyRecipe': recipe.isCustom,
    };

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: recipeMap,
          isDarkMode: _isDarkMode,
        ),
      ),
    ).then((_) {
      // Refresh data when returning from recipe details
      _loadData();
    });
  }

  String _getCategoryDisplayName(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.allRecipes:
        return 'All Recipes';
      case RecipeCategory.favorites:
        return 'Favorites';
      case RecipeCategory.myRecipes:
        return 'My Recipes';
    }
  }

  Future<void> _handleAddRecipe() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        builder: (context) => const CreateRecipe(),
        fullscreenDialog: true,
      ),
    );

    // Reload data when returning from create recipe
    if (result != null && result['success'] == true) {
      print('✅ Recipe created, refreshing data...');
      await _loadData();
    }

    // Reload theme when returning from any navigation
    await _loadThemePreference();
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Success'),
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

  CupertinoNavigationBar navigationBar() {
    return CupertinoNavigationBar(
      middle: Text(
        'Mama\'s Recipes',
        style: TextStyle(
          color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const Settings()),
          );
          // Reload theme and data when returning from Settings
          await _loadThemePreference();
          await _loadData();
        },
        child: const Icon(
          CupertinoIcons.bars,
          color: CupertinoColors.systemOrange,
          size: 24,
        ),
      ),
      backgroundColor: _isDarkMode
          ? const Color(0xFF1C1C1E)
          : CupertinoColors.white,
      border: null,
    );
  }
}