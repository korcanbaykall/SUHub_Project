import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../services/events_repository.dart';

class EventsProvider extends ChangeNotifier {
  final EventsRepository _repo;

  bool _busy = false;
  String? _error;

  EventsProvider({EventsRepository? repo})
      : _repo = repo ?? EventsRepository();

  bool get busy => _busy;
  String? get error => _error;

  Stream<List<Event>> eventsStream() => _repo.streamEvents();

  Future<void> createEvent({
    required String title,
    required String date,
    required String imageUrl,
    required String details,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.createEvent(
        title: title,
        date: date,
        imageUrl: imageUrl,
        details: details,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String date,
    required String imageUrl,
    required String details,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.updateEvent(
        id: id,
        title: title,
        date: date,
        imageUrl: imageUrl,
        details: details,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.deleteEvent(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
