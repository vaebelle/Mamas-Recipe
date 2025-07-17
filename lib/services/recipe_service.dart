import '../models/recipe_models.dart';
import 'global_recipes_service.dart';
import 'custom_recipes_service.dart';
import 'favorites_service.dart';
import 'user_global_recipe_access_service.dart';

class RecipeService {
  final GlobalRecipesService globalService = GlobalRecipesService();
  final CustomRecipesService customService = CustomRecipesService();
  final FavoritesService favoritesService = FavoritesService();
  final UserGlobalRecipeAccessService accessService = UserGlobalRecipeAccessService();

  // Get all recipes (global + user's custom) - FIXED VERSION
  Future<List<Recipe>> getAllRecipes() async {
    try {
      // Get global recipes using Future instead of Stream
      final globalRecipes = await globalService.getGlobalRecipesPaginated(limit: 50);
      final globalRecipeModels = globalRecipes.map((g) => Recipe.fromGlobalRecipe(g)).toList();

      // Get user's custom recipes - convert stream to future
      final customRecipesSnapshot = await customService.getUserCustomRecipes().first;
      final customRecipeModels = customRecipesSnapshot.map((c) => Recipe.fromCustomRecipe(c)).toList();

      // Combine and sort by creation date
      final allRecipes = [...globalRecipeModels, ...customRecipeModels];
      allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('📊 Loaded ${globalRecipeModels.length} global recipes and ${customRecipeModels.length} custom recipes');
      
      return allRecipes;
    } catch (e) {
      print('❌ Error getting all recipes: $e');
      return [];
    }
  }

  // Get only global recipes
  Future<List<Recipe>> getGlobalRecipes() async {
    try {
      final globalRecipes = await globalService.getGlobalRecipesPaginated(limit: 100);
      return globalRecipes.map((g) => Recipe.fromGlobalRecipe(g)).toList();
    } catch (e) {
      print('❌ Error getting global recipes: $e');
      return [];
    }
  }

  // Get only user's custom recipes
  Future<List<Recipe>> getCustomRecipes() async {
    try {
      final customRecipesSnapshot = await customService.getUserCustomRecipes().first;
      return customRecipesSnapshot.map((c) => Recipe.fromCustomRecipe(c)).toList();
    } catch (e) {
      print('❌ Error getting custom recipes: $e');
      return [];
    }
  }

  // Search across all recipes
  Future<List<Recipe>> searchAllRecipes(String searchTerm) async {
    try {
      final globalRecipes = await globalService.searchGlobalRecipes(searchTerm);
      final customRecipes = await customService.searchUserCustomRecipes(searchTerm);

      final allRecipes = [
        ...globalRecipes.map((g) => Recipe.fromGlobalRecipe(g)),
        ...customRecipes.map((c) => Recipe.fromCustomRecipe(c)),
      ];

      allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allRecipes;
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  // Toggle favorite with proper access tracking
  Future<bool> toggleRecipeFavorite(Recipe recipe) async {
    try {
      final recipeType = recipe.isGlobal ? 'global' : 'custom';
      final success = await favoritesService.toggleFavorite(
        recipeId: recipe.id,
        recipeType: recipeType,
      );

      // Record access for global recipes
      if (success && recipe.isGlobal) {
        await accessService.recordFavorite(recipe.id);
      }

      return success;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Record view when user opens recipe details
  Future<void> recordRecipeView(Recipe recipe) async {
    if (recipe.isGlobal) {
      await accessService.recordView(recipe.id);
    }
  }

  // Get recipe by ID and type
  Future<Recipe?> getRecipeById(String recipeId, RecipeType type) async {
    try {
      if (type == RecipeType.global) {
        final globalRecipe = await globalService.getGlobalRecipeById(recipeId);
        return globalRecipe != null ? Recipe.fromGlobalRecipe(globalRecipe) : null;
      } else {
        final customRecipe = await customService.getCustomRecipeById(recipeId);
        return customRecipe != null ? Recipe.fromCustomRecipe(customRecipe) : null;
      }
    } catch (e) {
      print('Error getting recipe by ID: $e');
      return null;
    }
  }

  // Check if recipe is favorited
  Future<bool> isRecipeFavorited(Recipe recipe) async {
    final recipeType = recipe.isGlobal ? 'global' : 'custom';
    return await favoritesService.isRecipeFavorited(
      recipeId: recipe.id,
      recipeType: recipeType,
    );
  }
}