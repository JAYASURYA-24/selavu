import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Wallet {
  double salary;
  double balance;
  double savings;
  double totalExpense;

  Wallet({
    this.salary = 0.0,
    this.balance = 0.0,
    this.savings = 0.0,
    this.totalExpense = 0.0,
  });

  // Update salary, balance, and savings when salary is updated
  void updateSalary(double newSalary) {
    if (balance > 0) {
      savings += balance; // Add balance to savings before resetting balance
    }
    salary = newSalary;
    balance = newSalary; // Reset balance to the new salary value
  }

  // Directly set the salary and move current balance to savings
  void setSalary(double newSalary) {
    // if (balance > 0) {
    //   savings += balance; // Add balance to savings before resetting balance
    // }
    salary = newSalary;
    // balance = newSalary; // Reset balance to the new salary value
  }

  // Update balance and subtract from both balance and savings
  void updateBalance(double expenseAmount) {
    balance -= expenseAmount;
    // savings -= expenseAmount;
  }

  // Update savings directly
  void updateSavings(double amount) {
    savings += amount;
  }

  // Move balance to savings if balance > 0
  void moveBalanceToSavings(double amount) {
    if (balance > 0) {
      savings += balance; // Add current balance to savings
      balance = amount; // Reset balance to 0 after moving it to savings
    } else if (balance == 0) {
      balance = savings + amount;
      savings = 0;
    }
  }

  // If balance goes negative, move deficit from savings
  void moveDeficitToSavings() {
    if (balance < 0) {
      double deficit =
          balance.abs(); // Get the absolute value of the negative balance
      if (savings >= deficit) {
        savings -= deficit; // Use savings to cover the deficit
        balance = 0; // Set balance to 0 after covering the deficit
      } else {
        balance = 0; // If savings can't cover the deficit, set balance to 0
        savings = savings - deficit; // Deplete savings completely
      }
    }
  }
}

class WalletProvider extends ChangeNotifier {
  Wallet _wallet = Wallet();

  Wallet get wallet => _wallet;

  // Method to update salary
  void updateSalary(double newSalary) {
    _wallet.updateSalary(newSalary);
    notifyListeners();
    _saveToHive();
  }

  // Method to set salary directly (without affecting balance/savings)
  void setSalary(double newSalary) {
    _wallet.setSalary(newSalary); // This will also move balance to savings
    notifyListeners();
    _saveToHive();
  }

  // Method to add an expense (subtract from balance and savings)
  void addExpense(double amount) {
    _wallet.updateBalance(
      amount,
    ); // Deduct the expense from balance and savings
    _wallet.moveDeficitToSavings();
    // If balance is negative, move deficit from savings
    notifyListeners();
    _saveToHive();
  }

  // Method to reset wallet if needed
  void resetWallet() {
    _wallet = Wallet();
    notifyListeners();
    _saveToHive();
  }

  // Move balance to savings directly
  void moveBalanceToSavings(salary) {
    _wallet.moveBalanceToSavings(salary); // This will move balance to savings
    notifyListeners();
    _saveToHive();
  }

  // If balance is negative, move the deficit from savings
  void handleNegativeBalance() {
    _wallet
        .moveDeficitToSavings(); // This will move the negative balance to savings
    notifyListeners();
    _saveToHive();
  }

  void setBalance(double balance) {
    _wallet.balance = balance;
    notifyListeners();
    _saveToHive();
  }

  void setSavings(double savings) {
    _wallet.savings = savings;
    notifyListeners();
    _saveToHive();
  }

  void setSalaryH(double salary) {
    _wallet.salary = salary;
    notifyListeners();
    _saveToHive();
  }

  Future<void> _saveToHive() async {
    final walletBox = await Hive.openBox<Wallet>('wallets');
    walletBox.put('wallet', _wallet);
  }

  Future<void> loadWalletData() async {
    final walletBox = await Hive.openBox<Wallet>('wallets');
    _wallet = walletBox.get('wallet', defaultValue: Wallet())!;
    notifyListeners();
  }
}
