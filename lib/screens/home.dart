import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/widgets/slidingSegment.dart';
import 'package:mama_recipe/widgets/card.dart';
import 'package:mama_recipe/screens/newRecipe.dart';
import 'package:mama_recipe/screens/settings.dart';
import 'package:mama_recipe/screens/recipeDetails.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';

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
  final List<bool> _favoriteStates = [false, true, false, true, false, false];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    List<Map<String, dynamic>> recipes = _getRecipesForCategory(
      _selectedCategory,
    );

    if (recipes.isEmpty) {
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
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          imagePath: recipe['imagePath'],
          cardName: recipe['name'],
          ingredients: List<String>.from(recipe['ingredients']),
          method: recipe['method'],
          tags: List<String>.from(recipe['tags']),
          isFavorite: _favoriteStates[recipe['id'] % _favoriteStates.length],
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
          onEdit: _selectedCategory == RecipeCategory.myRecipes
              ? () {
                  _handleEditRecipe(recipe['id']);
                }
              : null,
          onDelete: _selectedCategory == RecipeCategory.myRecipes
              ? () {
                  _handleDeleteRecipe(recipe['id']);
                }
              : null,
          onFavorite: () {
            _handleFavoriteToggle(recipe['id']);
          },
          onTap: () {
            _handleRecipeTap(recipe['id']);
          },
        );
      }, childCount: recipes.length),
    );
  }

  List<Map<String, dynamic>> _getRecipesForCategory(RecipeCategory category) {
    // Sample recipe data - replace with your actual data source
    final allRecipes = [
      {
        'id': 0,
        'name': 'Creamy Garlic Pasta',
        'ingredients': [
          '1 lb pasta',
          '4 cloves garlic, minced',
          '1 cup heavy cream',
          '1/2 cup parmesan cheese',
          '2 tbsp olive oil',
          'Salt and pepper to taste',
        ],
        'method':
            'Cook pasta according to package directions. Heat olive oil in large pan, sauté garlic until fragrant. Add cream and bring to simmer. Toss with pasta and parmesan cheese. Season with salt and pepper.',
        'imagePath': 'assets/images/pasta.jpg',
        'tags': ['italian', 'pasta', 'quick'],
        'isFavorite': false,
        'isMyRecipe': false,
      },
      {
        'id': 1,
        'name': 'Classic Chocolate Chip Cookies',
        'ingredients': [
          '2 cups flour',
          '1 cup butter',
          '1/2 cup brown sugar',
          '1/2 cup white sugar',
          '2 large eggs',
          '2 tsp vanilla extract',
          '1 tsp baking soda',
          '2 cups chocolate chips',
        ],
        'method':
            'Preheat oven to 375°F. Mix dry ingredients. Cream butter and sugars. Add eggs and vanilla. Combine wet and dry ingredients. Fold in chocolate chips. Drop spoonfuls on baking sheet. Bake for 9-11 minutes.',
        'imagePath': 'assets/images/cookies.jpg',
        'tags': ['dessert', 'cookies', 'chocolate'],
        'isFavorite': true,
        'isMyRecipe': false,
      },
      {
        'id': 2,
        'name': 'Grilled Chicken Salad',
        'ingredients': [
          '2 chicken breasts',
          '4 cups mixed greens',
          '1 cucumber, diced',
          '1 cup cherry tomatoes',
          '1/4 red onion, sliced',
          '2 tbsp olive oil',
          '1 tbsp balsamic vinegar',
        ],
        'method':
            'Season and grill chicken breasts until cooked through. Let rest, then slice. Combine greens, cucumber, tomatoes, and onion. Whisk olive oil and balsamic vinegar. Top salad with sliced chicken and dressing.',
        'imagePath': 'assets/images/salad.jpg',
        'tags': ['healthy', 'protein', 'salad'],
        'isFavorite': false,
        'isMyRecipe': false,
      },
      {
        'id': 3,
        'name': 'Mom\'s Special Adobo',
        'ingredients': [
          '2 lbs pork shoulder, cubed',
          '1/2 cup soy sauce',
          '1/4 cup vinegar',
          '6 cloves garlic, crushed',
          '2 bay leaves',
          '1 tsp peppercorns',
          '1 tbsp sugar',
        ],
        'method':
            'Marinate pork in soy sauce and vinegar for 30 minutes. In pot, combine all ingredients and bring to boil. Reduce heat and simmer covered for 45 minutes. Remove cover and cook until sauce thickens.',
        'imagePath': 'assets/images/adobo.jpg',
        'tags': ['filipino', 'traditional', 'family recipe'],
        'isFavorite': true,
        'isMyRecipe': true,
      },
      {
        'id': 4,
        'name': 'Homemade Pizza',
        'ingredients': [
          '2 cups flour',
          '1 tsp active dry yeast',
          '3/4 cup warm water',
          '1 tsp salt',
          '2 tbsp olive oil',
          '1/2 cup pizza sauce',
          '2 cups mozzarella cheese',
        ],
        'method':
            'Mix yeast with warm water. Combine flour and salt, add yeast mixture and olive oil. Knead until smooth. Let rise 1 hour. Roll out dough, add sauce and cheese. Bake at 475°F for 12-15 minutes.',
        'imagePath': 'assets/images/pizza.jpg',
        'tags': ['italian', 'pizza', 'homemade'],
        'isFavorite': false,
        'isMyRecipe': true,
      },
      {
        'id': 5,
        'name': 'Banana Bread',
        'ingredients': [
          '3 ripe bananas, mashed',
          '1/3 cup melted butter',
          '3/4 cup sugar',
          '1 egg, beaten',
          '1 tsp vanilla',
          '1 tsp baking soda',
          '1 1/2 cups flour',
        ],
        'method':
            'Preheat oven to 350°F. Mix mashed bananas with melted butter. Add sugar, egg, and vanilla. Mix in baking soda and flour until just combined. Pour into greased loaf pan. Bake 60-65 minutes.',
        'imagePath': 'assets/images/banana_bread.jpg',
        'tags': ['baking', 'breakfast', 'sweet'],
        'isFavorite': false,
        'isMyRecipe': false,
      },
    ];

    switch (category) {
      case RecipeCategory.allRecipes:
        return allRecipes;
      case RecipeCategory.favorites:
        return allRecipes
            .where((recipe) => recipe['isFavorite'] == true)
            .toList();
      case RecipeCategory.myRecipes:
        return allRecipes
            .where((recipe) => recipe['isMyRecipe'] == true)
            .toList();
    }
  }

  String _getEmptyStateMessage(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.allRecipes:
        return 'No recipes found.\nTry searching for something else.';
      case RecipeCategory.favorites:
        return 'No favorite recipes yet.\nStart adding some favorites!';
      case RecipeCategory.myRecipes:
        return 'You haven\'t created any recipes yet.\nTap the + button to create your first recipe!';
    }
  }

  void _handleEditRecipe(int recipeId) {
    // Navigate to edit recipe screen
    print('Edit recipe with ID: $recipeId');
    // Navigator.push(context, CupertinoPageRoute(builder: (context) => EditRecipeScreen(recipeId: recipeId)));
  }

  void _handleDeleteRecipe(int recipeId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Delete Recipe'),
          content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                print('Delete recipe with ID: $recipeId');
                // Implement delete logic here
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleFavoriteToggle(int recipeId) {
    setState(() {
      int index = recipeId % _favoriteStates.length;
      _favoriteStates[index] = !_favoriteStates[index];
    });
    print('Toggle favorite for recipe ID: $recipeId');
  }

  void _handleRecipeTap(int recipeId) {
    // Find the recipe data
    final allRecipes = _getRecipesForCategory(RecipeCategory.allRecipes);
    try {
      final recipe = allRecipes.firstWhere((r) => r['id'] == recipeId);

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              RecipeDetailsScreen(recipe: recipe, isDarkMode: _isDarkMode),
        ),
      );
    } catch (e) {
      // Recipe not found, handle error gracefully
      print('Recipe with ID $recipeId not found');
    }
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

  void _handleAddRecipe() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        builder: (context) => const CreateRecipe(),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      // Handle the new recipe data
      print('New recipe created: $result');
      // TODO: Add the new recipe to your data source
      // You might want to refresh the recipe list here
      setState(() {
        // Refresh the UI if needed
      });
    }

    // Reload theme when returning from any navigation
    await _loadThemePreference();
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
          // Reload theme when returning from Settings
          await _loadThemePreference();
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
