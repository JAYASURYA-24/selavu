import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:selavu/expense.dart';

class ExpenseProvider with ChangeNotifier {
  double _totalExpense = 0.0;

  double get totalExpense => _totalExpense;

  // Function to calculate the total expense for the current month
  calculateCurrentMonthTotal(Box<Expense> box) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Calculate the total expense for the current month
    _totalExpense = box.values
        .where(
          (expense) =>
              expense.date.isAfter(firstDayOfMonth) &&
              expense.date.isBefore(lastDayOfMonth),
        )
        .fold(0.0, (sum, item) => sum + item.amount);

    notifyListeners(); // Notify listeners when the total changes
  }
}
