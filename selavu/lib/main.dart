import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:selavu/authservices.dart';
import 'package:selavu/bottomnav.dart';

import 'package:selavu/expense.dart';
import 'package:selavu/expenseprovider.dart';
import 'package:selavu/loginscreen.dart';
import 'package:selavu/usernameprovider.dart';
import 'package:selavu/walletprovider.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(WalletAdapter());

  // Open the boxes with unique names
  final expenseBox = await Hive.openBox<Expense>('expenses');
  final walletBox = await Hive.openBox<Wallet>('wallets');
  final AuthService _authService = AuthService();

  // Check if the user is logged in
  var isLoggedIn = await _authService.isUserLoggedIn();

  // Run the app with the appropriate screen based on login status
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WalletProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],

      child: MyApp(
        expenseBox: expenseBox,
        walletBox: walletBox,
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box<Expense> expenseBox;
  final Box<Wallet> walletBox;
  final bool isLoggedIn;

  const MyApp({
    Key? key,
    required this.expenseBox,
    required this.walletBox,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',

      home:
          isLoggedIn
              ? BottomNavbar(expenseBox: expenseBox, walletBox: walletBox)
              : LoginScreen(), // Navigate based on login status
    );
  }
}
