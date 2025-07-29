import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/global_recipes.dart';

class GlobalRecipesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collection = 'globalRecipes';

  // READ: Get all global recipes (Stream for real-time updates)
  Stream<List<GlobalRecipes>> getAllGlobalRecipes() {
    return firestore
        .collection(collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlobalRecipes.fromFirestore(doc))
            .toList());
  }

  // READ: Get paginated global recipes
  Future<List<GlobalRecipes>> getGlobalRecipesPaginated({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = firestore
        .collection(collection)
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => GlobalRecipes.fromFirestore(doc))
        .toList();
  }

  // READ: Get specific global recipe by ID
  Future<GlobalRecipes?> getGlobalRecipeById(String recipeId) async {
    try {
      final doc = await firestore.collection(collection).doc(recipeId).get();
      if (doc.exists) {
        return GlobalRecipes.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting global recipe: $e');
      return null;
    }
  }

  // READ: Search global recipes
  Future<List<GlobalRecipes>> searchGlobalRecipes(String searchTerm) async {
    try {
      // Get all recipes and filter locally (Firestore doesn't support full-text search)
      final snapshot = await firestore.collection(collection).get();
      final allRecipes = snapshot.docs
          .map((doc) => GlobalRecipes.fromFirestore(doc))
          .toList();

      return allRecipes
          .where((recipe) => recipe.containsSearchTerms(searchTerm))
          .toList();
    } catch (e) {
      print('Error searching global recipes: $e');
      return [];
    }
  }

  // READ: Get global recipes by tag
  Future<List<GlobalRecipes>> getGlobalRecipesByTag(String tag) async {
    try {
      final snapshot = await firestore.collection(collection).get();
      final allRecipes = snapshot.docs
          .map((doc) => GlobalRecipes.fromFirestore(doc))
          .toList();

      return allRecipes.where((recipe) => recipe.hasTag(tag)).toList();
    } catch (e) {
      print('Error getting global recipes by tag: $e');
      return [];
    }
  }

  // READ: Get popular tags from all global recipes
  Future<List<String>> getPopularTags({int limit = 10}) async {
    try {
      final snapshot = await firestore.collection(collection).get();
      final allRecipes = snapshot.docs
          .map((doc) => GlobalRecipes.fromFirestore(doc))
          .toList();

      // Count tag frequency
      Map<String, int> tagCount = {};
      for (var recipe in allRecipes) {
        for (var tag in recipe.tagsList) {
          tagCount[tag] = (tagCount[tag] ?? 0) + 1;
        }
      }

      // Sort by frequency and return top tags
      var sortedTags = tagCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(limit).map((e) => e.key).toList();
    } catch (e) {
      print('Error getting popular tags: $e');
      return [];
    }
  }
}