import 'package:cloud_firestore/cloud_firestore.dart';

class CustomRecipes {
  final String cRecipeId;
  final String userId;
  final String cRecipeName;
  final String cRecipeIngredients;
  final String cRecipeInstructions;
  final String cRecipeImage;
  final String tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomRecipes({
    required this.cRecipeId,
    required this.userId,
    required this.cRecipeName,
    required this.cRecipeIngredients,
    required this.cRecipeInstructions,
    required this.cRecipeImage,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create CustomRecipes from Firestore document
  factory CustomRecipes.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CustomRecipes(
      cRecipeId: doc.id,
      userId: data['user_id'] ?? '',
      cRecipeName: data['cRecipe_name'] ?? '',
      cRecipeIngredients: data['cRecipe_ingredients'] ?? '',
      cRecipeInstructions: data['cRecipe_instructions'] ?? '',
      cRecipeImage: data['cRecipe_image'] ?? '',
      tags: data['tags'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory CustomRecipes.fromMap(Map<String, dynamic> map) {
    return CustomRecipes(
      cRecipeId: map['cRecipe_id'] ?? '',
      userId: map['user_id'] ?? '',
      cRecipeName: map['cRecipe_name'] ?? '',
      cRecipeIngredients: map['cRecipe_ingredients'] ?? '',
      cRecipeInstructions: map['cRecipe_instructions'] ?? '',
      cRecipeImage: map['cRecipe_image'] ?? '',
      tags: map['tags'] ?? '',
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updated_at'] is Timestamp 
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'cRecipe_name': cRecipeName,
      'cRecipe_ingredients': cRecipeIngredients,
      'cRecipe_instructions': cRecipeInstructions,
      'cRecipe_image': cRecipeImage,
      'tags': tags,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to convert ingredients string to list
  List<String> get ingredientsList {
    if (cRecipeIngredients.isEmpty) return [];
    return cRecipeIngredients.split('\n').where((ingredient) => ingredient.trim().isNotEmpty).toList();
  }

  // Helper method to convert instructions string to list
  List<String> get instructionsList {
    if (cRecipeInstructions.isEmpty) return [];
    return cRecipeInstructions.split('\n').where((instruction) => instruction.trim().isNotEmpty).toList();
  }

  // Helper method to convert tags string to list
  List<String> get tagsList {
    if (tags.isEmpty) return [];
    return tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  // Search method to check if recipe contains search terms
  bool containsSearchTerms(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return cRecipeName.toLowerCase().contains(term) ||
        tags.toLowerCase().contains(term);
  }

  // Helper method to check if recipe has specific tag
  bool hasTag(String tag) {
    return tagsList.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  // Create a copy with updated fields
  CustomRecipes copyWith({
    String? cRecipeId,
    String? userId,
    String? cRecipeName,
    String? cRecipeIngredients,
    String? cRecipeInstructions,
    String? cRecipeImage,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomRecipes(
      cRecipeId: cRecipeId ?? this.cRecipeId,
      userId: userId ?? this.userId,
      cRecipeName: cRecipeName ?? this.cRecipeName,
      cRecipeIngredients: cRecipeIngredients ?? this.cRecipeIngredients,
      cRecipeInstructions: cRecipeInstructions ?? this.cRecipeInstructions,
      cRecipeImage: cRecipeImage ?? this.cRecipeImage,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CustomRecipes(cRecipeId: $cRecipeId, userId: $userId, cRecipeName: $cRecipeName, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomRecipes && other.cRecipeId == cRecipeId;
  }

  @override
  int get hashCode => cRecipeId.hashCode;
}