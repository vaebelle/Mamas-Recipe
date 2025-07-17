import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRecipes {
  final String gRecipeId;
  final String gRecipeName;
  final String gRecipeIngredients;
  final String gRecipeInstructions;
  final String gRecipeImage;  // Changed from gRecipeImageUrl to match ERD
  final String tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  GlobalRecipes({
    required this.gRecipeId,
    required this.gRecipeName,
    required this.gRecipeIngredients,
    required this.gRecipeInstructions,
    required this.gRecipeImage,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create GlobalRecipes from Firestore document
  factory GlobalRecipes.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return GlobalRecipes(
      gRecipeId: doc.id,
      gRecipeName: data['gRecipe_name'] ?? '',
      gRecipeIngredients: data['gRecipe_ingredients'] ?? '',
      gRecipeInstructions: data['gRecipe_instructions'] ?? '',
      gRecipeImage: data['gRecipe_image'] ?? '',  // Updated field name
      tags: data['tags'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map (for JSON parsing)
  factory GlobalRecipes.fromMap(Map<String, dynamic> map) {
    return GlobalRecipes(
      gRecipeId: map['gRecipe_id'] ?? '',
      gRecipeName: map['gRecipe_name'] ?? '',
      gRecipeIngredients: map['gRecipe_ingredients'] ?? '',
      gRecipeInstructions: map['gRecipe_instructions'] ?? '',
      gRecipeImage: map['gRecipe_image'] ?? '',  // Updated field name
      tags: map['tags'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(
              map['created_at'] ?? DateTime.now().toIso8601String(),
            ),
      updatedAt: map['updated_at'] is Timestamp
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.parse(
              map['updated_at'] ?? DateTime.now().toIso8601String(),
            ),
    );
  }

  // Method to convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'gRecipe_name': gRecipeName,
      'gRecipe_ingredients': gRecipeIngredients,
      'gRecipe_instructions': gRecipeInstructions,
      'gRecipe_image': gRecipeImage,  // Updated field name
      'tags': tags,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to convert ingredients string to list
  List<String> get ingredientsList {
    if (gRecipeIngredients.isEmpty) return [];
    return gRecipeIngredients
        .split('\n')
        .where((ingredient) => ingredient.trim().isNotEmpty)
        .toList();
  }

  // Helper method to convert instructions string to list
  List<String> get instructionsList {
    if (gRecipeInstructions.isEmpty) return [];
    return gRecipeInstructions
        .split('\n')
        .where((instruction) => instruction.trim().isNotEmpty)
        .toList();
  }

  // Helper method to convert tags string to list
  List<String> get tagsList {
    if (tags.isEmpty) return [];
    return tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  // Search method to check if recipe contains search terms
  bool containsSearchTerms(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return gRecipeName.toLowerCase().contains(term) ||
        gRecipeIngredients.toLowerCase().contains(term) ||
        gRecipeInstructions.toLowerCase().contains(term) ||
        tags.toLowerCase().contains(term);
  }

  // Helper method to check if recipe has specific tag
  bool hasTag(String tag) {
    return tagsList.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  @override
  String toString() {
    return 'GlobalRecipes(gRecipeId: $gRecipeId, gRecipeName: $gRecipeName, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalRecipes && other.gRecipeId == gRecipeId;
  }

  @override
  int get hashCode => gRecipeId.hashCode;
}