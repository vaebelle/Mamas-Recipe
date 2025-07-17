import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/custom_recipes.dart';

class CustomRecipesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String collection = 'customRecipes';

  String? get currentUserId => auth.currentUser?.uid;

  // CREATE: Add a new custom recipe
  Future<String?> createCustomRecipe({
    required String recipeName,
    required String ingredients,
    required String instructions,
    required String tags,
    String? imageUrl,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final now = DateTime.now();
      final recipeData = {
        'user_id': currentUserId!,
        'cRecipe_name': recipeName,
        'cRecipe_ingredients': ingredients,
        'cRecipe_instructions': instructions,
        'cRecipe_image': imageUrl ?? '',
        'tags': tags,
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      };

      final docRef = await firestore.collection(collection).add(recipeData);
      return docRef.id;
    } catch (e) {
      print('Error creating custom recipe: $e');
      return null;
    }
  }

  // READ: Get all user's custom recipes (Stream for real-time updates)
  Stream<List<CustomRecipes>> getUserCustomRecipes() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return firestore
        .collection(collection)
        .where('user_id', isEqualTo: currentUserId)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomRecipes.fromFirestore(doc))
            .toList());
  }

  // READ: Get specific custom recipe by ID
  Future<CustomRecipes?> getCustomRecipeById(String recipeId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await firestore.collection(collection).doc(recipeId).get();
      if (doc.exists) {
        final recipe = CustomRecipes.fromFirestore(doc);
        // Ensure user can only access their own recipes
        if (recipe.userId == currentUserId) {
          return recipe;
        }
      }
      return null;
    } catch (e) {
      print('Error getting custom recipe: $e');
      return null;
    }
  }

  // READ: Search user's custom recipes
  Future<List<CustomRecipes>> searchUserCustomRecipes(String searchTerm) async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      final allRecipes = snapshot.docs
          .map((doc) => CustomRecipes.fromFirestore(doc))
          .toList();

      return allRecipes
          .where((recipe) => recipe.containsSearchTerms(searchTerm))
          .toList();
    } catch (e) {
      print('Error searching custom recipes: $e');
      return [];
    }
  }

  // UPDATE: Update an existing custom recipe
  Future<bool> updateCustomRecipe({
    required String recipeId,
    String? recipeName,
    String? ingredients,
    String? instructions,
    String? tags,
    String? imageUrl,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First verify the recipe belongs to the current user
      final recipe = await getCustomRecipeById(recipeId);
      if (recipe == null || recipe.userId != currentUserId) {
        return false;
      }

      final updateData = <String, dynamic>{
        'updated_at': Timestamp.fromDate(DateTime.now()),
      };

      if (recipeName != null) updateData['cRecipe_name'] = recipeName;
      if (ingredients != null) updateData['cRecipe_ingredients'] = ingredients;
      if (instructions != null) updateData['cRecipe_instructions'] = instructions;
      if (tags != null) updateData['tags'] = tags;
      if (imageUrl != null) updateData['cRecipe_image'] = imageUrl;

      await firestore.collection(collection).doc(recipeId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating custom recipe: $e');
      return false;
    }
  }

  // DELETE: Delete a custom recipe
  Future<bool> deleteCustomRecipe(String recipeId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First verify the recipe belongs to the current user
      final recipe = await getCustomRecipeById(recipeId);
      if (recipe == null || recipe.userId != currentUserId) {
        return false;
      }

      // Delete from favorites first (if any)
      await removeFavoriteIfExists(recipeId);

      // Delete the recipe
      await firestore.collection(collection).doc(recipeId).delete();
      return true;
    } catch (e) {
      print('Error deleting custom recipe: $e');
      return false;
    }
  }

  // READ: Get user's custom recipes by tag
  Future<List<CustomRecipes>> getUserCustomRecipesByTag(String tag) async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      final allRecipes = snapshot.docs
          .map((doc) => CustomRecipes.fromFirestore(doc))
          .toList();

      return allRecipes.where((recipe) => recipe.hasTag(tag)).toList();
    } catch (e) {
      print('Error getting custom recipes by tag: $e');
      return [];
    }
  }

  // Helper: Remove from favorites when deleting recipe
  Future<void> removeFavoriteIfExists(String recipeId) async {
    try {
      final favoritesSnapshot = await firestore
          .collection('favorites')
          .where('user_id', isEqualTo: currentUserId)
          .where('recipe_type', isEqualTo: 'custom')
          .where('recipe_id', isEqualTo: recipeId)
          .get();

      for (var doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}
