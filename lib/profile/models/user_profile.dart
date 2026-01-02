import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String username;
  final Timestamp? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: (data['uid'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      username: (data['username'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'createdAt': createdAt,
    };
  }
}

