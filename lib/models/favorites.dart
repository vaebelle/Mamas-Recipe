import 'package:cloud_firestore/cloud_firestore.dart';

class Favorites {
  final String favoriteId;
  final String userId;
  final String recipeType; 
  final String recipeId;    
  final DateTime createdAt;

  Favorites({
    required this.favoriteId,
    required this.userId,
    required this.recipeType,
    required this.recipeId,
    required this.createdAt,
  });

  factory Favorites.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Favorites(
      favoriteId: doc.id,
      userId: data['user_id'] ?? '',
      recipeType: data['recipe_type'] ?? '',
      recipeId: data['recipe_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Favorites.fromMap(Map<String, dynamic> map) {
    return Favorites(
      favoriteId: map['favorite_id'] ?? '',
      userId: map['user_id'] ?? '',
      recipeId: map['recipe_id'] ?? '',
      recipeType: map['recipe_type'] ?? '',
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'recipe_type': recipeType,
      'recipe_id': recipeId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Recipe type constants
  static const String recipeTypeGlobal = 'global';
  static const String recipeTypeCustom = 'custom';

  // Helper methods
  bool get isGlobalRecipe => recipeType == recipeTypeGlobal;
  bool get isCustomRecipe => recipeType == recipeTypeCustom;

  // Create favorite for global recipe
  factory Favorites.forGlobalRecipe({
    required String favoriteId,
    required String userId,
    required String gRecipeId,
  }) {
    return Favorites(
      favoriteId: favoriteId,
      userId: userId,
      recipeType: recipeTypeGlobal,
      recipeId: gRecipeId,
      createdAt: DateTime.now(),
    );
  }

  // Create favorite for custom recipe
  factory Favorites.forCustomRecipe({
    required String favoriteId,
    required String userId,
    required String cRecipeId,
  }) {
    return Favorites(
      favoriteId: favoriteId,
      userId: userId,
      recipeType: recipeTypeCustom,
      recipeId: cRecipeId,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Favorites(favoriteId: $favoriteId, userId: $userId, recipeType: $recipeType, recipeId: $recipeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorites && other.favoriteId == favoriteId;
  }

  @override
  int get hashCode => favoriteId.hashCode;
}

//EOF