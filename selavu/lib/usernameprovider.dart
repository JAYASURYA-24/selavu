import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For storage

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _username;
  String? _pass;
  String? _mob;

  String? get username => _username;
  String? get password => _pass;
  String? get phoneNumber => _mob;

  // Future to get the username from storage
  Future<void> getUsername() async {
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');
    String? phoneNumber = await _storage.read(key: 'phone_number');
    _username = username;
    _pass = password;
    _mob = phoneNumber;
    notifyListeners(); // Notify listeners when the username changes
  }

  // Optional: Set username if you need to set it manually
}
