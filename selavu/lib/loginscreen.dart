import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive for the box
import 'package:selavu/authservices.dart';
import 'package:selavu/bottomnav.dart';
import 'package:selavu/color.dart';

import 'package:selavu/expense.dart';
import 'package:selavu/registerscreen.dart';
import 'package:selavu/walletprovider.dart';

// Import AddExpenseScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Login function to validate credentials
  _login() async {
    final enteredUsername = _usernameController.text;
    final enteredPassword = _passwordController.text;

    // Get saved user credentials
    final userCredentials = await _authService.getUserCredentials();

    if (userCredentials != null &&
        userCredentials['username'] == enteredUsername &&
        userCredentials['password'] == enteredPassword) {
      // Save the user as logged in
      await _authService.saveUserCredentials(
        enteredUsername,
        enteredPassword,
        userCredentials['phone_number'] ?? '',
        is_loggedIn: true,
      );

      // Open Hive box for expenses
      var expenseBox = await Hive.openBox<Expense>('expensesBox');
      var walletBox = await Hive.openBox<Wallet>('walletBox');

      // Navigate to the bottom navbar screen and pass the Hive box
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => BottomNavbar(
                expenseBox: expenseBox,
                walletBox: walletBox,
              ), // Pass the box to Bottomnavbar
        ),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } else {
      // Show an error dialog if credentials don't match
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor().backgroundColor,
      appBar: AppBar(
        backgroundColor: Appcolor().backgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Login", style: TextStyle(fontSize: 30)),
                  // Username TextField
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  SizedBox(height: 10),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Appcolor().btnColordark,
                      ),
                    ),
                    onPressed: _login,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Appcolor().btntextColorw),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Registration Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Do not have an account? "),
                      InkWell(
                        onTap: () {
                          // Navigate to Registration Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
