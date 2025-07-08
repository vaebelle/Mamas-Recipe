import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID from Firebase Auth
  String? get currentUserId => _auth.currentUser?.uid;

  // ===========================
  // USER PROFILE OPERATIONS
  // ===========================

  /// CREATE: Create user profile with email and createdAt only
  Future<void> createUserProfile({required String email}) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(currentUserId).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// READ: Get user profile data
  Future<DocumentSnapshot> getUserProfile() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    return await _firestore.collection('users').doc(currentUserId).get();
  }

  /// UPDATE: Update user email (only field that can be updated for now)
  Future<void> updateUserProfile({required String email}) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(currentUserId).update({
      'email': email,
    });
  }

  /// DELETE: Delete user profile
  Future<void> deleteUserProfile() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(currentUserId).delete();
  }

  // ===========================
  // RECIPE CRUD OPERATIONS
  // ===========================

  /// CREATE: Add a new recipe to user's collection
  Future<String> createRecipe({
    required String title,
    required String
    ingredients, // String for now, can change to List<String> later
    required String
    cookingMethod, // String for now, can change to List<String> later
    required String tags, // String for now, can change to List<String> later
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Create recipe document in user's subcollection
    final docRef = await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .add({
          'title': title,
          'ingredients': ingredients,
          'cookingMethod': cookingMethod,
          'tags': tags,
          'imageURL': '', // Empty for now, will add image logic later
          'isFavorite': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return docRef.id; // Return the auto-generated recipe ID
  }

  /// READ: Get all user's recipes (Stream for real-time updates)
  Stream<QuerySnapshot> getUserRecipes() {
    if (currentUserId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// READ: Get a specific recipe by ID
  Future<DocumentSnapshot> getRecipe(String recipeId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    return await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .doc(recipeId)
        .get();
  }

  /// READ: Search recipes by title or tags (local filtering since Firestore doesn't support full-text search)
  Future<List<DocumentSnapshot>> searchRecipes(String searchTerm) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .get();

    // Filter results locally
    return querySnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String? ?? '').toLowerCase();
      final tags = (data['tags'] as String? ?? '').toLowerCase();
      final searchLower = searchTerm.toLowerCase();

      return title.contains(searchLower) || tags.contains(searchLower);
    }).toList();
  }

  /// UPDATE: Modify an existing recipe
  Future<void> updateRecipe({
    required String recipeId,
    String? title,
    String? ingredients,
    String? cookingMethod,
    String? tags,
    bool? isFavorite,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    Map<String, dynamic> updates = {'updatedAt': FieldValue.serverTimestamp()};

    // Only update fields that are provided (not null)
    if (title != null) updates['title'] = title;
    if (ingredients != null) updates['ingredients'] = ingredients;
    if (cookingMethod != null) updates['cookingMethod'] = cookingMethod;
    if (tags != null) updates['tags'] = tags;
    if (isFavorite != null) updates['isFavorite'] = isFavorite;

    await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .doc(recipeId)
        .update(updates);
  }

  /// DELETE: Remove a recipe from user's collection
  Future<void> deleteRecipe(String recipeId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Remove from favorites if it exists
    await _removeFavoriteIfExists(recipeId);

    // Delete the recipe document
    await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .doc(recipeId)
        .delete();
  }

  // ===========================
  // FAVORITE OPERATIONS
  // ===========================

  /// CREATE/UPDATE: Add recipe to favorites
  Future<void> addToFavorites({
    required String recipeId,
    required String recipeTitle,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // First, mark the recipe as favorite in the recipe document
    await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .doc(recipeId)
        .update({'isFavorite': true});

    // Then add to favorites collection for quick access
    await _firestore
        .collection('favorites')
        .doc(currentUserId)
        .collection('userFavorites')
        .doc(recipeId) // Use recipeId as document ID to prevent duplicates
        .set({
          'recipeId': recipeId,
          'recipeOwnerId': currentUserId,
          'recipeTitle': recipeTitle,
          'recipeImageURL': '', // Empty for now, will add image logic later
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  /// DELETE: Remove recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Mark recipe as not favorite in recipe document
    await _firestore
        .collection('recipes')
        .doc(currentUserId)
        .collection('userRecipes')
        .doc(recipeId)
        .update({'isFavorite': false});

    // Remove from favorites collection
    await _firestore
        .collection('favorites')
        .doc(currentUserId)
        .collection('userFavorites')
        .doc(recipeId)
        .delete();
  }

  /// READ: Get all favorite recipes (Stream for real-time updates)
  Stream<QuerySnapshot> getFavoriteRecipes() {
    if (currentUserId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('favorites')
        .doc(currentUserId)
        .collection('userFavorites')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// READ: Check if a recipe is favorited
  Future<bool> isRecipeFavorited(String recipeId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final doc = await _firestore
        .collection('favorites')
        .doc(currentUserId)
        .collection('userFavorites')
        .doc(recipeId)
        .get();

    return doc.exists;
  }

  // ===========================
  // HELPER METHODS
  // ===========================

  /// HELPER: Remove favorite entry if it exists (used during recipe deletion)
  Future<void> _removeFavoriteIfExists(String recipeId) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(currentUserId)
          .collection('userFavorites')
          .doc(recipeId)
          .delete();
    } catch (e) {
      // Ignore error if favorite doesn't exist
      print('Favorite not found or already deleted: $e');
    }
  }

  // ===========================
  // UTILITY METHODS
  // ===========================

  /// Check if user is authenticated
  bool get isUserAuthenticated => currentUserId != null;

  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Sign out user (call this when user logs out to clear the service)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
