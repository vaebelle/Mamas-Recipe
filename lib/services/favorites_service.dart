import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorites.dart';
import '../models/global_recipes.dart';
import '../models/custom_recipes.dart';
import '../models/recipe_models.dart';

class FavoritesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String collection = 'favorites';

  String? get currentUserId => auth.currentUser?.uid;

  // CREATE: Add recipe to favorites
  Future<bool> addToFavorites({
    required String recipeId,
    required String recipeType, // 'global' or 'custom'
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if already favorited
      final existing = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .where('recipe_type', isEqualTo: recipeType)
          .where('recipe_id', isEqualTo: recipeId)
          .get();

      if (existing.docs.isNotEmpty) {
        print('✅ Recipe already favorited');
        return true; // Already favorited
      }

      // Add to favorites
      final docRef = await firestore.collection(collection).add({
        'user_id': currentUserId!,
        'recipe_type': recipeType,
        'recipe_id': recipeId,
        'created_at': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Added to favorites: ${docRef.id}');
      return true;
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      return false;
    }
  }

  // DELETE: Remove recipe from favorites
  Future<bool> removeFromFavorites({
    required String recipeId,
    required String recipeType,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .where('recipe_type', isEqualTo: recipeType)
          .where('recipe_id', isEqualTo: recipeId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print('✅ Removed from favorites: ${doc.id}');
      }

      return true;
    } catch (e) {
      print('❌ Error removing from favorites: $e');
      return false;
    }
  }

  // READ: Get favorite recipes with full recipe data 
  Future<List<Recipe>> getFavoriteRecipesWithData() async {
    if (currentUserId == null) {
      print('❌ User not authenticated');
      return [];
    }

    try {
      print('📊 Loading favorites for user: $currentUserId');
      
      // Use simple query without ordering to avoid index issues
      final favoritesSnapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      print('📈 Found ${favoritesSnapshot.docs.length} favorite records');

      List<Recipe> favoriteRecipes = [];

      for (var favoriteDoc in favoritesSnapshot.docs) {
        try {
          final data = favoriteDoc.data() as Map<String, dynamic>;
          print('🔍 Processing favorite document: ${data}');
          
          final favorite = Favorites.fromFirestore(favoriteDoc);
          print('📄 Parsed favorite: ${favorite.recipeType} - ${favorite.recipeId}');

          if (favorite.recipeType == 'custom') {
            // Get custom recipe data
            final customDoc = await firestore
                .collection('customRecipes')
                .doc(favorite.recipeId)
                .get();
            
            if (customDoc.exists) {
              final customRecipe = CustomRecipes.fromFirestore(customDoc);
              print('✅ Found custom recipe: ${customRecipe.cRecipeName}');
              
              // Only include if it belongs to current user
              if (customRecipe.userId == currentUserId) {
                favoriteRecipes.add(Recipe.fromCustomRecipe(customRecipe));
                print('✅ Added custom recipe to favorites list');
              } else {
                print('⚠️ Custom recipe belongs to different user: ${customRecipe.userId}');
              }
            } else {
              print('❌ Custom recipe not found: ${favorite.recipeId}');
            }
          } else if (favorite.recipeType == 'global') {
            // Get global recipe data
            final globalDoc = await firestore
                .collection('globalRecipes')
                .doc(favorite.recipeId)
                .get();
            
            if (globalDoc.exists) {
              final globalRecipe = GlobalRecipes.fromFirestore(globalDoc);
              favoriteRecipes.add(Recipe.fromGlobalRecipe(globalRecipe));
              print('✅ Added global recipe: ${globalRecipe.gRecipeName}');
            } else {
              print('❌ Global recipe not found: ${favorite.recipeId}');
            }
          }
        } catch (e) {
          print('❌ Error processing favorite document: $e');
        }
      }

      // Sort by created date manually 
      favoriteRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('📈 Final favorite recipes loaded: ${favoriteRecipes.length}');
      return favoriteRecipes;
    } catch (e) {
      print('❌ Error getting favorite recipes with data: $e');
      return [];
    }
  }

  // READ: Check if recipe is favorited
  Future<bool> isRecipeFavorited({
    required String recipeId,
    required String recipeType,
  }) async {
    if (currentUserId == null) {
      return false;
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .where('recipe_type', isEqualTo: recipeType)
          .where('recipe_id', isEqualTo: recipeId)
          .limit(1)
          .get();

      final isFavorited = snapshot.docs.isNotEmpty;
      return isFavorited;
    } catch (e) {
      print('❌ Error checking if recipe is favorited: $e');
      return false;
    }
  }

  // UTILITY: Toggle favorite status
  Future<bool> toggleFavorite({
    required String recipeId,
    required String recipeType,
  }) async {
    try {
      print('🔄 Toggling favorite for $recipeId ($recipeType)');
      
      final isFavorited = await isRecipeFavorited(
        recipeId: recipeId,
        recipeType: recipeType,
      );

      bool success;
      if (isFavorited) {
        print('➖ Removing from favorites');
        success = await removeFromFavorites(
          recipeId: recipeId,
          recipeType: recipeType,
        );
      } else {
        print('➕ Adding to favorites');
        success = await addToFavorites(
          recipeId: recipeId,
          recipeType: recipeType,
        );
      }

      print('✅ Toggle favorite result: $success');
      return success;
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      return false;
    }
  }

  // UTILITY: Get favorite count
  Future<int> getFavoriteCount() async {
    if (currentUserId == null) {
      return 0;
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting favorite count: $e');
      return 0;
    }
  }

  Future<void> debugPrintFavorites() async {
    if (currentUserId == null) {
      print('❌ User not authenticated');
      return;
    }

    try {
      print('🔍 DEBUG: Printing all favorites for user $currentUserId');
      
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      print('📊 Found ${snapshot.docs.length} favorite documents:');
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('   📄 ${doc.id}: ${data}');
      }
    } catch (e) {
      print('❌ Error in debug print favorites: $e');
    }
  }
}