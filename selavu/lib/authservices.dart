import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();

  // Save user credentials
  Future<void> saveUserCredentials(
    String username,
    String password,
    String phoneNumber, {
    required bool is_loggedIn,
  }) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'phone_number', value: phoneNumber);
    await _storage.write(key: 'is_loggedin', value: is_loggedIn.toString());
  }

  // Get saved user credentials
  Future<Map<String, String>?> getUserCredentials() async {
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');
    String? phoneNumber = await _storage.read(key: 'phone_number');

    if (username != null && password != null && phoneNumber != null) {
      return {
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
      };
    }

    return null;
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    String? isLoggedIn = await _storage.read(key: 'is_loggedin');
    return isLoggedIn == 'true';
  }

  // Logout the user
  Future<void> logout() async {
    await _storage.write(key: 'is_loggedin', value: 'false');
  }

  // Check if phone number is registered
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    String? savedPhoneNumber = await _storage.read(key: 'phone_number');
    return savedPhoneNumber != null && savedPhoneNumber == phoneNumber;
  }
}
