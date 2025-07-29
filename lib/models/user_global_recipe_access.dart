import 'package:cloud_firestore/cloud_firestore.dart';

class UserGlobalRecipeAccess {
  final String userId;
  final String gRecipeId;
  final String accessType;
  final DateTime createdAt;  

  UserGlobalRecipeAccess({
    required this.userId,
    required this.gRecipeId,
    required this.accessType,
    required this.createdAt,
  });

  // Factory constructor to create UserGlobalRecipeAccess from Firestore document
  factory UserGlobalRecipeAccess.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserGlobalRecipeAccess(
      userId: data['user_id'] ?? '',
      gRecipeId: data['gRecipe_id'] ?? '',
      accessType: data['access_type'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory UserGlobalRecipeAccess.fromMap(Map<String, dynamic> map) {
    return UserGlobalRecipeAccess(
      userId: map['user_id'] ?? '',
      gRecipeId: map['gRecipe_id'] ?? '',
      accessType: map['access_type'] ?? '',
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'gRecipe_id': gRecipeId,
      'access_type': accessType,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Access type constants 
  static const String accessTypeView = 'view';
  static const String accessTypeFavorite = 'favorite';

  // Helper methods
  bool get isView => accessType == accessTypeView;
  bool get isFavorite => accessType == accessTypeFavorite;

  // Create composite key for Firestore document ID 
  String get compositeKey => '${userId}_${gRecipeId}_$accessType';

  @override
  String toString() {
    return 'UserGlobalRecipeAccess(userId: $userId, gRecipeId: $gRecipeId, accessType: $accessType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserGlobalRecipeAccess && 
           other.userId == userId && 
           other.gRecipeId == gRecipeId && 
           other.accessType == accessType;
  }

  @override
  int get hashCode => Object.hash(userId, gRecipeId, accessType);
}

//EOF