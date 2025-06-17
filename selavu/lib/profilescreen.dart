import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:selavu/authservices.dart';
import 'package:selavu/color.dart';
import 'package:selavu/expense.dart';
import 'package:selavu/expenseprovider.dart';
import 'package:selavu/loginscreen.dart';
import 'package:selavu/usernameprovider.dart';

import 'package:selavu/walletprovider.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  void initState() {
    super.initState();
    _loadWalletData();
    _curExp();
    Provider.of<AuthProvider>(context, listen: false).getUsername();
  }

  String formatAmountIndian(double amount) {
    final format = NumberFormat('#,##,###', 'en_IN');
    return format.format(amount);
  }

  Future<void> _loadWalletData() async {
    await Provider.of<WalletProvider>(context, listen: false).loadWalletData();
  }

  Future<void> _curExp() async {
    var box = await Hive.openBox<Expense>('expenses');
    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).calculateCurrentMonthTotal(box);
  }

  void _showSalaryDialog(BuildContext context, WalletProvider walletProvider) {
    final _salaryController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolor().backgroundColor,
          elevation: 4,
          title: Text('Enter Salary'),
          content: TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Salary'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog when cancel is pressed
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Appcolor().btnColorlight),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Get the salary text and remove commas
                String salaryText = _salaryController.text.trim();
                salaryText = salaryText.replaceAll(',', '');

                // Parse the salary as double
                double salary = double.parse(salaryText);

                // Add the current balance to savings before setting salary
                walletProvider.moveBalanceToSavings(salary);

                // Set the salary in the provider
                walletProvider.setSalary(salary);

                // Save the salary in Hive
                final walletBox = Hive.box('wallets');
                walletBox.put('salary', salary);

                // Close the dialog after saving the salary
                // Ensure this is called after the salary is saved
              },
              child: Text(
                'Save',
                style: TextStyle(color: Appcolor().btnColordark),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showlogout() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolor().backgroundColor,
          elevation: 4,
          title: Text('Are you sure want to logout..?'),

          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog when cancel is pressed
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Appcolor().btnColorlight),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _authService.logout();

                // After logout, navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },

              child: Text(
                'Yes, logout',
                style: TextStyle(color: Appcolor().btnColordark),
              ),
            ),
          ],
        );
      },
    );
  }

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Appcolor().backgroundColor,
        appBar: AppBar(
          backgroundColor: Appcolor().backgroundColor,
          title: Text("Profile"),
          actions: [
            IconButton(
              icon: Icon(Icons.account_balance_wallet_rounded),
              onPressed: () {
                // Show the dialog to add salary when the wallet icon is clicked
                _showSalaryDialog(context, walletProvider);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Appcolor().cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Salary"),
                        Text(
                          "₹${formatAmountIndian(walletProvider.wallet.salary)}",
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Appcolor().cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Balance"),
                        Text(
                          "₹${formatAmountIndian(walletProvider.wallet.balance)}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Appcolor().cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Savings"),
                        Text(
                          "₹${formatAmountIndian(walletProvider.wallet.savings)}",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Appcolor().cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Expenses"),
                        Text(
                          "₹${formatAmountIndian(expenseProvider.totalExpense)}",

                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              ExpansionTile(
                title: Text("Account"),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Name "),
                            Text(authProvider.username.toString()),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Mobile"),
                            Text(authProvider.phoneNumber.toString()),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Password"),
                            Text(authProvider.password.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text("About"),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "App work  panni parunga entha bug vanthalum kindly please solunga....And inum neraya features add panalam so neenga enna expect panringanu kandipa solunga add panna mudincha panidalam...Nanri..!!",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Appcolor().btnColordark,
                minWidth: 300,
                onPressed: () {
                  _showlogout();
                },
                child: Text(
                  "Log out",
                  style: TextStyle(color: Appcolor().btntextColorw),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
