import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:selavu/color.dart';

import 'package:selavu/usernameprovider.dart';
import 'package:selavu/viewexpenses.dart';
import 'walletprovider.dart'; // Your WalletProvider
import 'expense.dart'; // Your Expense model

class AddExpenseScreen extends StatefulWidget {
  final Box<Expense> box; // Box for storing expenses

  AddExpenseScreen({required this.box});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Groceries', 'icon': 'assets/vegetable.png'},
    {'name': 'Rent', 'icon': 'assets/rent.png'},
    {'name': 'EMI', 'icon': 'assets/money.png'},
    {'name': 'Own Vehicle', 'icon': 'assets/bycicle.png'},
    {'name': 'Restaurant', 'icon': 'assets/restaurant.png'},
    {'name': 'Shopping', 'icon': 'assets/woman.png'},
    {'name': 'Transport', 'icon': 'assets/transportation.png'},
    {'name': 'Bill', 'icon': 'assets/transaction.png'},
    {'name': 'Entertain', 'icon': 'assets/entertainment.png'},
    {'name': 'Health', 'icon': 'assets/healthcare.png'},
    {'name': 'Others', 'icon': 'assets/menu.png'},
  ];

  void initState() {
    super.initState();
    _loadWalletData();
    Provider.of<AuthProvider>(context, listen: false).getUsername();
  }

  Future<void> _loadWalletData() async {
    await Provider.of<WalletProvider>(context, listen: false).loadWalletData();
  }

  void _showSalaryDialog(BuildContext context, WalletProvider walletProvider) {
    final _salaryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              child: Text('Cancel'),
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
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final userPro = Provider.of<AuthProvider>(context).username;

    return userPro == null
        ? Center(child: CircularProgressIndicator())
        : Consumer2<WalletProvider, AuthProvider>(
          builder: (context, walletProvider, userpro, child) {
            return SafeArea(
              child: Scaffold(
                backgroundColor: Appcolor().backgroundColor,
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Hi..", style: TextStyle(fontSize: 25)),
                                Text(
                                  userPro.toString(),
                                  style: TextStyle(fontSize: 25),
                                ),
                              ],
                            ),
                            Row(children: [Text("Welcome Back")]),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "Bal: ₹${walletProvider.wallet.balance.toStringAsFixed(2)}",
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              bottom: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                // Display salary, balance, and savings
                                Row(
                                  children: [Text("Categories")],
                                ), // Category selection
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                  },
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          crossAxisSpacing: 1,
                                          mainAxisSpacing: 1,
                                        ),
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory =
                                                category['name'];
                                          });
                                        },

                                        child: Card(
                                          color:
                                              _selectedCategory ==
                                                      category['name']
                                                  ? Appcolor().btnColorlight
                                                  : Colors.grey[100],
                                          shadowColor:
                                              _selectedCategory ==
                                                      category['name']
                                                  ? Appcolor().btnColorlight
                                                  : Colors.grey[100],
                                          elevation:
                                              _selectedCategory ==
                                                      category['name']
                                                  ? 15
                                                  : 4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      category['icon'],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                category['name'],
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Amount input
                                TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Amount',
                                    prefixText: '₹ ',
                                  ),
                                  onChanged: (text) {
                                    String formattedAmount = formatAmountIndian(
                                      text,
                                    );
                                    _amountController.value = _amountController
                                        .value
                                        .copyWith(
                                          text: formattedAmount,
                                          selection: TextSelection.collapsed(
                                            offset: formattedAmount.length,
                                          ),
                                        );
                                  },
                                ),
                                // Description input
                                TextField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Add Expense button
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Appcolor().btnColordark,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_amountController.text.isEmpty ||
                                        _descriptionController.text.isEmpty ||
                                        _selectedCategory == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select a category, and enter amount and description',
                                          ),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    double amount = 0;
                                    String amountWithoutCommas =
                                        _amountController.text.replaceAll(
                                          ',',
                                          '',
                                        );
                                    try {
                                      amount = double.parse(
                                        amountWithoutCommas,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Invalid amount entered',
                                          ),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    // Create the expense object
                                    final expense = Expense(
                                      amount: amount,
                                      category: _selectedCategory!,
                                      description: _descriptionController.text,
                                      date: DateTime.now(),
                                      username: '',
                                    );

                                    // Add the expense to the box
                                    await widget.box.add(expense);

                                    // Update the wallet after adding the expense
                                    walletProvider.addExpense(amount);

                                    // Clear the form
                                    _amountController.clear();
                                    _descriptionController.clear();
                                    setState(() {
                                      _selectedCategory = null;
                                    });

                                    // Navigate to the ExpenseListScreen after adding the expense
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ExpenseListScreen(
                                              box: widget.box,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Appcolor().btntextColorw,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  // Function to format the amount as Indian currency
  String formatAmountIndian(String text) {
    text = text.replaceAll(',', '');
    if (text.isEmpty) return '';

    double value = double.tryParse(text) ?? 0;

    if (value == 0) return '0';

    String formatted = NumberFormat("#,##,###", "en_IN").format(value);
    return formatted;
  }
}
