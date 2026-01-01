import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

class EventsRepository {
  final FirebaseFirestore _db;

  EventsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Event>> streamEvents() {
    return _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Event.fromDoc(d)).toList());
  }

  Future<void> createEvent({
    required String title,
    required String date,
    required String imageUrl,
    required String details,
  }) async {
    final doc = _db.collection('events').doc();
    await doc.set({
      'id': doc.id,
      'title': title,
      'date': date,
      'imageUrl': imageUrl,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
