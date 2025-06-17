import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:selavu/color.dart';
import 'package:selavu/expense.dart';
import 'package:selavu/expenseprovider.dart';

class ExpenseListScreen extends StatefulWidget {
  final Box<Expense> box;

  ExpenseListScreen({required this.box});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> displayedExpenses = [];
  String selectedFilter = 'None'; // Default to 'None'
  int? selectedYear;
  int? selectedMonth;
  DateTime? selectedDate;
  double totalExpense = 0.0;

  // Function to format the amount with commas
  String formatAmountIndian(double amount) {
    return NumberFormat("#,##,###", "en_IN").format(amount);
  }

  // Function to filter expenses for the selected month and year
  Future<void> filterExpensesByMonth(List<Expense> expenses) async {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    DateTime currentDate = DateTime.now();
    int currentYear = currentDate.year;
    int currentMonth = currentDate.month;
    List<int> years = List.generate(10, (index) => currentYear - index);

    final selectedMonthYear = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        int selectedYearLocal = selectedYear ?? currentYear;
        int selectedMonthLocal = selectedMonth ?? (currentMonth - 1);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Appcolor().backgroundColor,
              elevation: 4,
              title: Text('Select Month and Year'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Dropdown
                  DropdownButton<int>(
                    value: selectedYearLocal,
                    onChanged: (newValue) {
                      setStateDialog(() {
                        selectedYearLocal = newValue!;
                      });
                    },
                    items:
                        years.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          );
                        }).toList(),
                  ),
                  // Month Dropdown
                  DropdownButton<int>(
                    value: selectedMonthLocal,
                    onChanged: (newValue) {
                      setStateDialog(() {
                        selectedMonthLocal = newValue!;
                      });
                    },
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(months[index]),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'year': selectedYearLocal,
                      'month': selectedMonthLocal + 1,
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedMonthYear != null) {
      int selectedYearLocal = selectedMonthYear['year'];
      int selectedMonthLocal = selectedMonthYear['month'];

      setState(() {
        selectedYear = selectedYearLocal;
        selectedMonth = selectedMonthLocal - 1;
        selectedFilter = 'Month';

        displayedExpenses =
            expenses
                .where((expense) {
                  return expense.date.year == selectedYearLocal &&
                      expense.date.month == selectedMonthLocal;
                })
                .toList()
                .reversed
                .toList();
      });

      calculateTotalExpense();
    }
  }

  // Function to filter expenses by week
  List<Expense> filterExpensesByWeek(List<Expense> expenses) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    return expenses.where((expense) {
      return expense.date.isAfter(startOfWeek) &&
          expense.date.isBefore(endOfWeek);
    }).toList();
  }

  // Function to filter expenses for the selected date
  Future<void> filterExpensesByDate(List<Expense> expenses) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        selectedFilter = 'Date';
        displayedExpenses =
            expenses
                .where((expense) {
                  return expense.date.year == pickedDate.year &&
                      expense.date.month == pickedDate.month &&
                      expense.date.day == pickedDate.day;
                })
                .toList()
                .reversed
                .toList();
      });

      calculateTotalExpense();
    }
  }

  // Function to filter expenses for the current month
  List<Expense> filterExpensesByMonthAlt(List<Expense> expenses) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return expenses.where((expense) {
      return expense.date.isAfter(firstDayOfMonth) &&
          expense.date.isBefore(lastDayOfMonth);
    }).toList();
  }

  // Function to update the displayed list based on the selected filter
  void updateDisplayedList() {
    List<Expense> expenses = widget.box.values.toList().reversed.toList();

    if (selectedFilter == 'Week') {
      displayedExpenses = filterExpensesByWeek(expenses);
    } else if (selectedFilter == 'Month') {
      displayedExpenses = filterExpensesByMonthAlt(expenses);
    } else if (selectedFilter == 'Date') {
      if (selectedDate != null) {
        displayedExpenses =
            expenses
                .where((expense) {
                  return expense.date.year == selectedDate!.year &&
                      expense.date.month == selectedDate!.month &&
                      expense.date.day == selectedDate!.day;
                })
                .toList()
                .reversed
                .toList();
      }
    } else {
      displayedExpenses = expenses;
    }

    calculateTotalExpense();
  }

  // Function to calculate total expense
  void calculateTotalExpense() {
    totalExpense = displayedExpenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // var expensePro = Provider.of<ExpenseProvider>(context, listen: false);
    // expensePro.loadExpenses();
    displayedExpenses = widget.box.values.toList().reversed.toList();
    // displayedExpenses = expensePro.expenses.toList().reversed.toList();
    calculateTotalExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expensepro, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Appcolor().backgroundColor,
            appBar: AppBar(
              backgroundColor: Appcolor().backgroundColor,
              title: Text('My Expenses'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: DropdownButton<String>(
                    dropdownColor: Appcolor().backgroundColor,
                    value: selectedFilter == 'None' ? null : selectedFilter,
                    hint: Text('Select Filter'),
                    items:
                        ['None', 'Date', 'Week', 'Month'].map((String filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                        updateDisplayedList();
                      });
                      if (selectedFilter == 'Date') {
                        filterExpensesByDate(widget.box.values.toList());
                      } else if (selectedFilter == 'Month') {
                        filterExpensesByMonth(widget.box.values.toList());
                      }
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Total: ₹${formatAmountIndian(totalExpense)}',
                        style: TextStyle(fontSize: 20, color: Colors.red[400]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: widget.box.listenable(),
                    builder: (context, Box<Expense> box, _) {
                      if (box.isEmpty) {
                        return Center(child: Text('No expenses added yet.'));
                      }

                      if (displayedExpenses.isEmpty) {
                        return Center(
                          child: Text(
                            'No expenses found for the selected filter.',
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: displayedExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = displayedExpenses[index];
                          final formattedDate = DateFormat(
                            'dd/MM/yyyy, HH:mm',
                          ).format(expense.date);

                          String formattedAmount = formatAmountIndian(
                            expense.amount,
                          );

                          return ListTile(
                            title: Text(
                              'Rs. $formattedAmount',
                              style: TextStyle(color: Colors.amber[700]),
                            ),
                            subtitle: Text(
                              '${expense.description ?? ''} \nDate: $formattedDate',
                            ),
                            trailing: Text(
                              expense.category ?? '',
                              style: TextStyle(color: color(expense.category)),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Divider(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

color(color) {
  switch (color) {
    case 'Groceries':
      return Colors.green;
    case 'Rent':
      return Colors.blue;
    case 'EMI':
      return Colors.red;
    case 'Own Vehicle':
      return Colors.yellow;
    case 'Restaurant':
      return Colors.orange;
    case 'Shopping':
      return Colors.purple;
    case 'Transport':
      return Colors.teal;
    case 'Bill':
      return Colors.brown;
    case 'Entertain':
      return Colors.pink;
    case 'Health':
      return Colors.cyan;
    case 'Others':
      return Colors.grey;
  }
}
