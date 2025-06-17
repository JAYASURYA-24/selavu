import 'package:flutter/material.dart';
import 'package:selavu/authservices.dart';
import 'package:selavu/color.dart';
import 'package:selavu/loginscreen.dart';

bool isValidMobileNumber(String mobile) {
  // Regex to match 10 digits, starting with 6, 7, 8, or 9
  String mobileNumberPattern = r'^[6-9]\d{9}$';
  RegExp regExp = RegExp(mobileNumberPattern);
  return regExp.hasMatch(mobile);
}

bool isValidPassword(String password) {
  // Password must be at least 8 characters, with one letter and one number
  String passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$';
  RegExp regExp = RegExp(passwordPattern);
  return regExp.hasMatch(password);
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  String? phoneNumberError;
  String? passwordError;
  String? usernameError;

  _register() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final phoneNumber = _phoneController.text;

    // Validate empty fields
    if (username.isEmpty) {
      setState(() {
        usernameError = 'Please enter a valid username';
      });
      return;
    } else {
      setState(() {
        usernameError = null;
      });
    }

    // Validate phone number
    if (!isValidMobileNumber(phoneNumber)) {
      setState(() {
        phoneNumberError =
            'Please enter a valid phone number (10 digits starting with 6, 7, 8, or 9)';
      });
      return;
    } else {
      setState(() {
        phoneNumberError = null;
      });
    }

    // Validate password
    if (!isValidPassword(password)) {
      setState(() {
        passwordError =
            'Password must be at least 8 characters long and contain at least one letter and one number.';
      });
      return;
    } else {
      setState(() {
        passwordError = null;
      });
    }

    // Check if phone number is already registered
    bool isPhoneNumberRegistered = await _authService.isPhoneNumberRegistered(
      phoneNumber,
    );
    if (isPhoneNumberRegistered) {
      // Show error if phone number already exists
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Appcolor().backgroundColor,
            title: Text("Phone Number Already Registered"),
            content: Text(
              "This phone number is already associated with an account.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Appcolor().btnColordark),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    // Proceed to save user credentials
    await _authService.saveUserCredentials(
      username,
      password,
      phoneNumber,
      is_loggedIn: false,
    );

    // Navigate to login screen after successful registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor().backgroundColor,
      appBar: AppBar(backgroundColor: Appcolor().backgroundColor),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text("Register", style: TextStyle(fontSize: 30)),
                // Username Field with error handling
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: usernameError,
                  ),
                ),
                SizedBox(height: 10),

                // Password Field with error handling
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: passwordError,
                  ),
                ),
                SizedBox(height: 10),

                // Phone Number Field with error handling
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    errorText: phoneNumberError,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Appcolor().btnColordark,
                    ),
                  ),
                  onPressed: _register,
                  child: Text(
                    'Register',
                    style: TextStyle(color: Appcolor().btntextColorw),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
