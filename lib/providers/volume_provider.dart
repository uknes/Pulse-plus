import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolumeProvider with ChangeNotifier {
  double _volume = 1.0;

  VolumeProvider() {
    _loadVolume();
  }

  double get volume => _volume;

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('volume') ?? 1.0;
    notifyListeners();
  }

  Future<void> updateVolume(double newVolume) async {
    if (newVolume != _volume) {
      _volume = newVolume;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', newVolume);
      notifyListeners();
    }
  }
} 