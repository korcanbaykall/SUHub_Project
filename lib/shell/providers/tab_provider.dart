import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabProvider extends ChangeNotifier {
  static const _key = 'last_tab_index';

  int _index = 1; // default Home
  SharedPreferences? _prefs;

  TabProvider() {
    _load();
  }

  int get index => _index;

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    _index = _prefs!.getInt(_key) ?? 1;
    notifyListeners();
  }

  Future<void> setIndex(int newIndex) async {
    _index = newIndex;
    notifyListeners();

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(_key, newIndex);
  }
}
