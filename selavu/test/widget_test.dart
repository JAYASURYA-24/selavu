import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selavu/authservices.dart';
import 'package:selavu/expense.dart';
import 'package:selavu/main.dart';
import 'package:selavu/walletprovider.dart';

void main() {
  // Initialize Hive and open the box before all tests
  setUpAll(() async {
    await Hive.initFlutter();
    await Hive.openBox<Expense>('expensesBox');
  });

  setUp(() async {
    // Clear the box before each test to ensure isolation
    var box = await Hive.openBox<Expense>('expensesBox');
    var box1 = await Hive.openBox<Wallet>('walletBox');
    await box.clear();
  });

  testWidgets('Add expense to Hive box', (tester) async {
    // Open the box to pass it into MyApp
    final box = await Hive.openBox<Expense>('expensesBox');
    var box1 = await Hive.openBox<Wallet>('walletBox');
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();

    // Pump MyApp with the required box parameter
    await tester.pumpWidget(
      MyApp(expenseBox: box, walletBox: box1, isLoggedIn: isLoggedIn),
    );

    // Find the add expense button (adjust the find logic to your button's widget)
    final addExpenseButton = find.byType(
      ElevatedButton,
    ); // Adjust this if needed
    expect(addExpenseButton, findsOneWidget); // Ensure the button is found
    await tester.tap(addExpenseButton);
    await tester.pumpAndSettle();

    // Insert a new expense (you may want to trigger a form submission, etc.)
    final expense = Expense(
      amount: 50.0,
      category: 'Food',
      description: 'Lunch',
      date: DateTime.now(),
      username: 'test_user', // Add username if needed
    );

    // Add the expense to the box
    await box.add(expense);

    // Verify that the expense is added to the Hive box
    expect(box.length, 1);
    expect(box.getAt(0)?.amount, 50.0);
    expect(box.getAt(0)?.category, 'Food');
    expect(box.getAt(0)?.description, 'Lunch');
    expect(box.getAt(0)?.username, 'test_user');
  });
}
