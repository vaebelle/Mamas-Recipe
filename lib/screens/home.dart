import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/slidingSegment.dart';
import 'package:mama_recipe/widgets/card.dart';
import 'package:mama_recipe/screens/newRecipe.dart';
import 'package:mama_recipe/screens/settings.dart';
import 'package:mama_recipe/screens/recipeDetails.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/services/recipe_service.dart';
import 'package:mama_recipe/services/favorites_service.dart';
import 'package:mama_recipe/models/recipe_models.dart';
import 'package:mama_recipe/screens/editCustomRecipe.dart';
import 'package:mama_recipe/models/custom_recipes.dart';

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
  bool _isRefreshing = false;
  String _searchQuery = '';

  // Cache for favorite status to avoid constant rebuilding
  Map<String, bool> _favoriteStatusCache = {};
  String? _currentUserId;
  bool _dataIsFresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
    _initializeData();

    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadThemePreference();
      _checkUserAndRefreshIfNeeded();
    }
  }

  Future<void> _initializeData() async {
    await _loadData();
    _currentUserId = _recipeService.customService.currentUserId;
  }

  Future<void> _forceRefreshData() async {
    print('🔄 Force refreshing all data...');
    
    // Clear all caches
    _favoriteStatusCache.clear();
    _dataIsFresh = false;
    
    // Force reload data
    await _loadData();
    
    print('✅ Force refresh completed');
  }

  Future<void> _checkUserAndRefreshIfNeeded() async {
    final newUserId = _recipeService.customService.currentUserId;

    if (_currentUserId != newUserId) {
      print(
        '🔄 User changed from $_currentUserId to $newUserId - refreshing data...',
      );
      _currentUserId = newUserId;

      // Clear cache when user changes
      _favoriteStatusCache.clear();
      _dataIsFresh = false;

      await _loadData();
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = searchController.text;
        _filterRecipes();
      });
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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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
          _dataIsFresh = true; 
          _isLoading = false; 

          print(
            '📈 Final counts - All: ${_allRecipes.length}, Favorites: ${_favoriteRecipes.length}, My: ${_myRecipes.length}',
          );

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

    print(
      '💾 Loaded favorite status for ${_favoriteStatusCache.length} recipes',
    );
  }

  void _updateFavoriteCacheQuickly(
    String recipeId,
    String recipeType,
    bool isFavorite,
  ) {
    final cacheKey =
        '${recipeId}_${recipeType == 'custom' ? 'custom' : 'global'}';

    setState(() {
      _favoriteStatusCache[cacheKey] = isFavorite;

      // Update favorite recipes list without full reload
      if (isFavorite) {
        // Find the recipe and add to favorites if not already there
        final recipe = _allRecipes.firstWhere(
          (r) =>
              r.id == recipeId &&
              (recipeType == 'custom' ? r.isCustom : r.isGlobal),
          orElse: () => Recipe(
            id: recipeId,
            name: 'Unknown Recipe',
            ingredients: '',
            instructions: '',
            imageUrl: '',
            tags: '',
            type: recipeType == 'custom'
                ? RecipeType.custom
                : RecipeType.global,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (!_favoriteRecipes.any((r) => r.id == recipeId)) {
          _favoriteRecipes.add(recipe);
          _favoriteRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      } else {
        // Remove from favorites
        _favoriteRecipes.removeWhere((r) => r.id == recipeId);
      }

      // Re-filter with updated data
      _filterRecipes();
    });

    print('⚡ Quick cache update for $recipeId: $isFavorite');
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
      _displayedRecipes = List.from(
        baseRecipes,
      ); // Create new list to ensure UI updates
    } else {
      _displayedRecipes = baseRecipes
          .where((recipe) => recipe.containsSearchTerms(_searchQuery))
          .toList();
    }
    print(
      '🔍 Filtered to ${_displayedRecipes.length} recipes for category ${_selectedCategory.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [
                    const Color(0xFF1C1C1E),
                    const Color(0xFF3D2914), // Darker orange
                    const Color(0xFF2C1810), // Medium orange
                    const Color(0xFF1C1C1E),
                  ]
                : [
                    const Color(0xFFFFF8F0), // Light cream
                    const Color(0xFFFFE5CC), // Light orange
                    const Color(0xFFFFF0E6), // Very light orange
                    CupertinoColors.white,
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white.withOpacity(
            0.0,
          ), // Make scaffold transparent
          navigationBar: navigationBar(),
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping on background
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    setState(() {
                      _isRefreshing = true;
                    });

                    // Clear all caches and force refresh
                    _favoriteStatusCache.clear();
                    _dataIsFresh = false;
                    await _loadData();
                    
                    setState(() {
                      _isRefreshing = false;
                    });
                  },
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  CupertinoIcons.plus,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search bar
                      CustomTextField(
                        controller: searchController,
                        hintText: 'Search recipes...',
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),

                      // Category selector
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
                            if (value != null && value != _selectedCategory) {
                              setState(() {
                                _selectedCategory = value;
                                _filterRecipes();
                              });
                              print(
                                '🔄 Switched to ${value.name} tab - ${_displayedRecipes.length} recipes',
                              );
                            }
                          },
                          children: <RecipeCategory, Widget>{
                            RecipeCategory.allRecipes: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Recipe List
                if (_isLoading && !_isRefreshing)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            radius: 24,
                            color: _isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading recipes...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _isDarkMode
                                  ? const Color(0xFFAEAEB2)
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_displayedRecipes.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 64,
                            color: _isDarkMode
                                ? const Color(0xFF8E8E93)
                                : CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyStateMessage(_selectedCategory),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDarkMode
                                  ? const Color(0xFFAEAEB2)
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildRecipesList(),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesList() {
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
          onEdit:
              recipe.isCustom &&
                  recipe.userId == _recipeService.customService.currentUserId
              ? () => _handleEditRecipe(recipe)
              : null,
          onDelete:
              recipe.isCustom &&
                  recipe.userId == _recipeService.customService.currentUserId
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
    try {
      // Convert Recipe to CustomRecipes object
      final customRecipe = CustomRecipes(
        cRecipeId: recipe.id,
        cRecipeName: recipe.name,
        cRecipeIngredients: recipe.ingredients,
        cRecipeInstructions: recipe.instructions,
        cRecipeImage: recipe.imageUrl,
        tags: recipe.tags,
        userId: recipe.userId ?? '',
        createdAt: recipe.createdAt,
        updatedAt: recipe.updatedAt,
      );

      // Navigate directly to EditCustomRecipe screen
      final result = await Navigator.push<bool>(
        context,
        CupertinoPageRoute(
          builder: (context) => EditCustomRecipe(recipe: customRecipe),
          fullscreenDialog: true,
        ),
      );

      // If recipe was updated successfully, refresh the data
      if (result == true) {
        print('✅ Recipe updated, refreshing data...');
        await _loadData();
        if (mounted) {
          _showSuccessDialog('Recipe updated successfully');
        }
      }
    } catch (e) {
      print('❌ Error navigating to edit recipe: $e');
      if (mounted) {
        _showErrorDialog('Failed to open edit screen. Please try again.');
      }
    }
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

                final success = await _recipeService.customService
                    .deleteCustomRecipe(recipe.id);
                if (success) {
                  // Remove from local lists immediately
                  setState(() {
                    _allRecipes.removeWhere((r) => r.id == recipe.id);
                    _myRecipes.removeWhere((r) => r.id == recipe.id);
                    _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
                    _favoriteStatusCache.remove(
                      '${recipe.id}_${recipe.type.name}',
                    );
                    _filterRecipes();
                  });

                  if (mounted) {
                    _showSuccessDialog('Recipe deleted successfully');
                  }
                } else {
                  if (mounted) {
                    _showErrorDialog(
                      'Failed to delete recipe. Please try again.',
                    );
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

    final favoriteKey = '${recipe.id}_${recipe.type.name}';
    final currentStatus = _favoriteStatusCache[favoriteKey] ?? false;
    final newStatus = !currentStatus;

    _updateFavoriteCacheQuickly(
      recipe.id,
      recipe.isCustom ? 'custom' : 'global',
      newStatus,
    );

    try {
      final success = await _recipeService.toggleRecipeFavorite(recipe);

      if (success) {
        print('✅ Favorite toggle successful');
      } else {
        print('❌ Favorite toggle failed');
        _updateFavoriteCacheQuickly(
          recipe.id,
          recipe.isCustom ? 'custom' : 'global',
          currentStatus,
        );
        _showErrorDialog('Failed to update favorite status');
      }
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      _updateFavoriteCacheQuickly(
        recipe.id,
        recipe.isCustom ? 'custom' : 'global',
        currentStatus,
      );
      _showErrorDialog('Failed to update favorite status');
    }
  }

  Future<void> _handleRecipeTap(Recipe recipe) async {
    _recipeService.recordRecipeView(recipe).catchError((e) {
      print('❌ Analytics error: $e');
    });

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

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            RecipeDetailsScreen(recipe: recipeMap, isDarkMode: _isDarkMode),
      ),
    );

    // Handle favorite status changes without full reload
    if (result != null && result['favoriteChanged'] == true) {
      final recipeId = result['recipeId'] as String?;
      final recipeType = result['recipeType'] as String?;
      final newFavoriteStatus = result['isFavorite'] as bool? ?? false;

      if (recipeId != null && recipeType != null) {
        // Quick cache update instead of full reload
        _updateFavoriteCacheQuickly(recipeId, recipeType, newFavoriteStatus);
        print(
          '⚡ Quick updated favorite cache for $recipeId: $newFavoriteStatus',
        );
      }
    }
  }

  String _getCategoryDisplayName(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.allRecipes:
        return 'All Recipes';
      case RecipeCategory.favorites:
        return 'Favorites';
      case RecipeCategory.myRecipes:
        return 'Personal Recipes'; 
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

    if (result != null && result['success'] == true) {
      print('✅ Recipe created, refreshing data...');
      _dataIsFresh = false; 
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
          // Reload theme and check for user changes when returning from Settings
          await _loadThemePreference();
          await _checkUserAndRefreshIfNeeded();
        },
        child: const Icon(
          CupertinoIcons.bars,
          color: CupertinoColors.systemOrange,
          size: 24,
        ),
      ),
      backgroundColor: CupertinoColors.white.withOpacity(
        0.0,
      ), // Make navigation bar transparent
      border: null,
    );
  }
}