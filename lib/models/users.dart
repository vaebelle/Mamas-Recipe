import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create Users from Firestore document
  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Users(
      userId: doc.id,
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      password: data['password'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      password: map['password'] ?? '',
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
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get initials
  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  String toString() {
    return 'Users(userId: $userId, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Users && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

//EOF