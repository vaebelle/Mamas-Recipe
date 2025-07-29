import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRecipes {
  final String gRecipeId;
  final String gRecipeName;
  final String gRecipeIngredients;
  final String gRecipeInstructions;
  final String gRecipeImage; 
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

    // Debug: Print all available fields
    print('🔍 DEBUG - All Firestore fields for ${doc.id}:');
    data.forEach((key, value) {
      if (key.toLowerCase().contains('image') || key.toLowerCase().contains('url')) {
        print('  - $key: "$value"');
      }
    });

    // Clean the image URL by removing quotes
    String imageUrl = data['gRecipe_image'] ?? '';
    if (imageUrl.startsWith('"') && imageUrl.endsWith('"')) {
      imageUrl = imageUrl.substring(1, imageUrl.length - 1);
    }
    
    final recipe = GlobalRecipes(
      gRecipeId: doc.id,
      gRecipeName: data['gRecipe_name'] ?? '',
      gRecipeIngredients: data['gRecipe_ingredients'] ?? '',
      gRecipeInstructions: data['gRecipe_instructions'] ?? '',
      gRecipeImage: imageUrl,  
      tags: data['tags'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );

    // Debug: Check what we're getting from Firestore
    print('🔍 DEBUG - Global Recipe: ${recipe.gRecipeName}');
    print('🔍 DEBUG - Raw gRecipe_image from Firestore: "${data['gRecipe_image']}"');
    print('🔍 DEBUG - Cleaned gRecipeImage field: "${recipe.gRecipeImage}"');
    print('🔍 DEBUG - Is image URL empty? ${recipe.gRecipeImage.isEmpty}');
    
    return recipe;
  }

  // Factory constructor from Map (for JSON parsing)
  factory GlobalRecipes.fromMap(Map<String, dynamic> map) {
    // Clean the image URL by removing quotes
    String imageUrl = map['gRecipe_image'] ?? '';
    if (imageUrl.startsWith('"') && imageUrl.endsWith('"')) {
      imageUrl = imageUrl.substring(1, imageUrl.length - 1);
    }
    
    return GlobalRecipes(
      gRecipeId: map['gRecipe_id'] ?? '',
      gRecipeName: map['gRecipe_name'] ?? '',
      gRecipeIngredients: map['gRecipe_ingredients'] ?? '',
      gRecipeInstructions: map['gRecipe_instructions'] ?? '',
      gRecipeImage: imageUrl, 
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
      'gRecipe_image': gRecipeImage,  
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

//EOF