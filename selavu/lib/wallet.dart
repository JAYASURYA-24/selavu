import 'package:hive/hive.dart' show HiveField, HiveType;

@HiveType(typeId: 1) // Unique ID for this type
class Wallet {
  @HiveField(0)
  double salary;

  @HiveField(1)
  double balance;

  @HiveField(2)
  double savings;

  Wallet({required this.salary, required this.balance, required this.savings});

  // Method to update balance when an expense is added
  void updateBalance(double expenseAmount) {
    balance -= expenseAmount; // Reduce balance based on expense
    savings -= expenseAmount; // Reduce savings based on expense
  }

  void updateSavings(double amount) {
    this.savings += amount; // Update savings by adding the amount
  }

  // Method to reset the balance to the salary value and add the old balance to savings
  void updateSalary(double newSalary) {
    // If the wallet is empty (e.g., for a new user), set balance and savings to the new salary
    if (balance <= 0) {
      salary = newSalary; // Set the new salary
      balance = newSalary; // Set the balance to the new salary
      // Set the savings to the new salary as well
    } else {
      // If there's an existing balance, just update the salary, balance, and savings accordingly
      // double remainingBalance = balance + newSalary;
      savings = savings + balance; // Add the remaining balance to savings
      salary = newSalary; // Update salary to the new value
      balance = newSalary; // Reset balance to the new salary
    }
  }
}
