import 'global_recipes.dart';
import 'custom_recipes.dart';

enum RecipeType { global, custom }

class Recipe {
  final String id;
  final String name;
  final String ingredients;
  final String instructions;
  final String imageUrl;  
  final String tags;
  final RecipeType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId; 

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.tags,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  // Create from GlobalRecipes
  factory Recipe.fromGlobalRecipe(GlobalRecipes global) {
    final recipe = Recipe(
      id: global.gRecipeId,
      name: global.gRecipeName,
      ingredients: global.gRecipeIngredients,
      instructions: global.gRecipeInstructions,
      imageUrl: global.gRecipeImage,  
      tags: global.tags,
      type: RecipeType.global,
      createdAt: global.createdAt,
      updatedAt: global.updatedAt,
    );

    // Debug: Check Recipe model mapping
    print('🔄 DEBUG - Recipe mapping for: ${recipe.name}');
    print('🔄 DEBUG - global.gRecipeImage: "${global.gRecipeImage}"');
    print('🔄 DEBUG - recipe.imageUrl: "${recipe.imageUrl}"');
    
    return recipe;
  }

  // Create from CustomRecipes
  factory Recipe.fromCustomRecipe(CustomRecipes custom) {
    return Recipe(
      id: custom.cRecipeId,
      name: custom.cRecipeName,
      ingredients: custom.cRecipeIngredients,
      instructions: custom.cRecipeInstructions,
      imageUrl: custom.cRecipeImage,
      tags: custom.tags,
      type: RecipeType.custom,
      createdAt: custom.createdAt,
      updatedAt: custom.updatedAt,
      userId: custom.userId,
    );
  }

  // Helper methods
  List<String> get ingredientsList {
    if (ingredients.isEmpty) return [];
    return ingredients.split('\n').where((ingredient) => ingredient.trim().isNotEmpty).toList();
  }

  List<String> get instructionsList {
    if (instructions.isEmpty) return [];
    return instructions.split('\n').where((instruction) => instruction.trim().isNotEmpty).toList();
  }

  List<String> get tagsList {
    if (tags.isEmpty) return [];
    return tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  bool get isGlobal => type == RecipeType.global;
  bool get isCustom => type == RecipeType.custom;

  bool containsSearchTerms(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return name.toLowerCase().contains(term) ||
        tags.toLowerCase().contains(term);
  }

  bool hasTag(String tag) {
    return tagsList.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id && other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);
}

//EOF