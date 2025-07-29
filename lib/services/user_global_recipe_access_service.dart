import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_global_recipe_access.dart';

class UserGlobalRecipeAccessService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String collection = 'user_global_recipe_access'; 

  String? get currentUserId => auth.currentUser?.uid;

  // CREATE: Record access to global recipe
  Future<bool> recordAccess({
    required String gRecipeId,
    required String accessType,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final accessRecord = UserGlobalRecipeAccess(
        userId: currentUserId!,
        gRecipeId: gRecipeId,
        accessType: accessType,
        createdAt: DateTime.now(),
      );

      // Use composite key as document ID 
      final docId = accessRecord.compositeKey;
      
      // Check if access already recorded 
      final existingDoc = await firestore
          .collection(collection)
          .doc(docId)
          .get();

      if (existingDoc.exists) {
        return true; // Already recorded
      }

      // Record new access with composite key as document ID
      await firestore
          .collection(collection)
          .doc(docId)
          .set(accessRecord.toMap());

      return true;
    } catch (e) {
      print('Error recording access: $e');
      return false;
    }
  }

  // READ: Get user's access history
  Stream<List<UserGlobalRecipeAccess>> getUserAccessHistory() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return firestore
        .collection(collection)
        .where('user_id', isEqualTo: currentUserId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserGlobalRecipeAccess.fromFirestore(doc))
            .toList());
  }

  // READ: Get access by type
  Future<List<UserGlobalRecipeAccess>> getAccessByType(String accessType) async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .where('access_type', isEqualTo: accessType)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserGlobalRecipeAccess.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting access by type: $e');
      return [];
    }
  }

  // READ: Get access for specific recipe and user
  Future<List<UserGlobalRecipeAccess>> getUserRecipeAccess(String gRecipeId) async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .where('gRecipe_id', isEqualTo: gRecipeId)
          .get();

      return snapshot.docs
          .map((doc) => UserGlobalRecipeAccess.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user recipe access: $e');
      return [];
    }
  }

  // CHECK: Has user accessed recipe with specific type
  Future<bool> hasUserAccessed({
    required String gRecipeId,
    required String accessType,
  }) async {
    if (currentUserId == null) {
      return false;
    }

    try {
      final compositeKey = UserGlobalRecipeAccess(
        userId: currentUserId!,
        gRecipeId: gRecipeId,
        accessType: accessType,
        createdAt: DateTime.now(),
      ).compositeKey;

      final doc = await firestore
          .collection(collection)
          .doc(compositeKey)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking user access: $e');
      return false;
    }
  }

  // UTILITY: Record view access when user opens a global recipe
  Future<void> recordView(String gRecipeId) async {
    await recordAccess(
      gRecipeId: gRecipeId,
      accessType: UserGlobalRecipeAccess.accessTypeView,
    );
  }

  // UTILITY: Record favorite access when user favorites a global recipe
  Future<void> recordFavorite(String gRecipeId) async {
    await recordAccess(
      gRecipeId: gRecipeId,
      accessType: UserGlobalRecipeAccess.accessTypeFavorite,
    );
  }

  // DELETE: Remove access record
  Future<bool> removeAccess({
    required String gRecipeId,
    required String accessType,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final compositeKey = UserGlobalRecipeAccess(
        userId: currentUserId!,
        gRecipeId: gRecipeId,
        accessType: accessType,
        createdAt: DateTime.now(),
      ).compositeKey;

      await firestore
          .collection(collection)
          .doc(compositeKey)
          .delete();

      return true;
    } catch (e) {
      print('Error removing access: $e');
      return false;
    }
  }

  // ANALYTICS: Get recipe access statistics
  Future<Map<String, int>> getRecipeAccessStats(String gRecipeId) async {
    try {
      final snapshot = await firestore
          .collection(collection)
          .where('gRecipe_id', isEqualTo: gRecipeId)
          .get();

      Map<String, int> stats = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final accessType = data['access_type'] as String;
        stats[accessType] = (stats[accessType] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error getting recipe access stats: $e');
      return {};
    }
  }

  // ANALYTICS: Get user's most accessed recipes
  Future<List<Map<String, dynamic>>> getUserTopAccessedRecipes({int limit = 10}) async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await firestore
          .collection(collection)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      // Count access per recipe
      Map<String, int> recipeAccessCount = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final gRecipeId = data['gRecipe_id'] as String;
        recipeAccessCount[gRecipeId] = (recipeAccessCount[gRecipeId] ?? 0) + 1;
      }

      // Sort and return top recipes
      var sortedRecipes = recipeAccessCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedRecipes.take(limit).map((entry) => {
        'gRecipe_id': entry.key,
        'access_count': entry.value,
      }).toList();
    } catch (e) {
      print('Error getting top accessed recipes: $e');
      return [];
    }
  }
}