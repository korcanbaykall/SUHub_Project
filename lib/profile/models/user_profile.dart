import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String username;
  final Timestamp? createdAt;
  final String role;
  final String? photoUrl;
  final double? photoAlignX;
  final double? photoAlignY;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.role,
    required this.photoUrl,
    required this.photoAlignX,
    required this.photoAlignY,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    final alignX = data['photoAlignX'];
    final alignY = data['photoAlignY'];
    final rawPhotoUrl = data['photoUrl'];
    return UserProfile(
      uid: (data['uid'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      username: (data['username'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
      role: (data['role'] ?? 'user') as String,
      photoUrl: rawPhotoUrl is String ? rawPhotoUrl : null,
      photoAlignX: alignX is num ? alignX.toDouble() : null,
      photoAlignY: alignY is num ? alignY.toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'createdAt': createdAt,
      'role': role,
      'photoUrl': photoUrl ?? '',
      'photoAlignX': photoAlignX ?? 0.0,
      'photoAlignY': photoAlignY ?? 0.0,
    };
  }
}

