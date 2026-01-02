import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String imageUrl;
  final String details;
  final Timestamp? createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.details,
    required this.createdAt,
  });

  factory Event.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Event(
      id: (data['id'] ?? doc.id) as String,
      title: (data['title'] ?? '') as String,
      date: (data['date'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      details: (data['details'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toDetailMap() => {
        'title': title,
        'date': date,
        'imageAsset': imageUrl,
        'details': details,
      };
}
