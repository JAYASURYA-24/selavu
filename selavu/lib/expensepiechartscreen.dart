import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selavu/color.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion package
import 'expense.dart';

class ExpenseDoughnutChartScreen extends StatelessWidget {
  final Box<Expense> box;

  ExpenseDoughnutChartScreen({required this.box});

  final Map<String, Color> categoryColorMap = {
    'Groceries': Colors.green,
    'Rent': Colors.blue,
    'EMI': Colors.red,
    'Own Vehicle': Colors.yellow,
    'Restaurant': Colors.orange,
    'Shopping': Colors.purple,
    'Transport': Colors.teal,
    'Bill': Colors.brown,
    'Entertain': Colors.pink,
    'Health': Colors.cyan,
    'Others': Colors.grey,
  };

  Map<String, double> groupExpensesByCategory(List<Expense> expenses) {
    Map<String, double> categoryExpenses = {};

    for (var expense in expenses) {
      if (categoryExpenses.containsKey(expense.category)) {
        categoryExpenses[expense.category] =
            categoryExpenses[expense.category]! + expense.amount;
      } else {
        categoryExpenses[expense.category] = expense.amount;
      }
    }
    return categoryExpenses;
  }

  List<Expense> filterExpensesForCurrentMonth(List<Expense> expenses) {
    DateTime now = DateTime.now();
    DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

    return expenses.where((expense) {
      return expense.date.isAfter(
            firstDayOfCurrentMonth.subtract(Duration(days: 1)),
          ) &&
          expense.date.isBefore(lastDayOfCurrentMonth.add(Duration(days: 1)));
    }).toList();
  }

  List<Expense> filterExpensesForLastMonth(List<Expense> expenses) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    DateTime firstDayOfLastMonth =
        currentMonth == 1
            ? DateTime(currentYear - 1, 12, 1)
            : DateTime(currentYear, currentMonth - 1, 1);
    DateTime lastDayOfLastMonth =
        currentMonth == 1
            ? DateTime(currentYear - 1, 12, 31)
            : DateTime(currentYear, currentMonth, 0);

    return expenses.where((expense) {
      return expense.date.isAfter(
            firstDayOfLastMonth.subtract(Duration(days: 1)),
          ) &&
          expense.date.isBefore(lastDayOfLastMonth.add(Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // We have two tabs
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Appcolor().backgroundColor,
          appBar: AppBar(
            backgroundColor: Appcolor().backgroundColor,
            title: Text('Expense Charts'),
            bottom: TabBar(
              dividerColor: Appcolor().btnColorlight,
              labelColor: Appcolor().btnColordark,
              indicatorColor: Appcolor().btnColordark,
              tabs: [Tab(text: 'Current Month'), Tab(text: 'Last Month')],
            ),
          ),
          body: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<Expense> box, _) {
              if (box.isEmpty) {
                return Center(child: Text('No expenses added yet.'));
              }

              List<Expense> expenses = box.values.toList();
              List<Expense> currentMonthExpenses =
                  filterExpensesForCurrentMonth(expenses);
              List<Expense> lastMonthExpenses = filterExpensesForLastMonth(
                expenses,
              );

              Map<String, double> currentMonthCategoryExpenses =
                  groupExpensesByCategory(currentMonthExpenses);
              Map<String, double> lastMonthCategoryExpenses =
                  groupExpensesByCategory(lastMonthExpenses);

              List<ChartData> currentMonthChartData =
                  currentMonthCategoryExpenses.entries.map((entry) {
                    return ChartData(
                      entry.key,
                      entry.value,
                      categoryColorMap[entry.key] ?? Colors.black,
                    );
                  }).toList();

              List<ChartData> lastMonthChartData =
                  lastMonthCategoryExpenses.entries.map((entry) {
                    return ChartData(
                      entry.key,
                      entry.value,
                      categoryColorMap[entry.key] ?? Colors.black,
                    );
                  }).toList();

              return TabBarView(
                children: [
                  // Current Month Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Current Month Expenses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SfCircularChart(
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: currentMonthChartData,
                                xValueMapper:
                                    (ChartData data, _) => data.category,
                                yValueMapper:
                                    (ChartData data, _) => data.amount,
                                pointColorMapper:
                                    (ChartData data, _) => data.color,
                                radius: '80%',
                                innerRadius: '60%',
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  currentMonthCategoryExpenses.entries.map((
                                    entry,
                                  ) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color:
                                              categoryColorMap[entry.key] ??
                                              Colors.black,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${entry.key}: ₹${entry.value.toStringAsFixed(0)}',
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Last Month Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Last Month Expenses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SfCircularChart(
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: lastMonthChartData,
                                xValueMapper:
                                    (ChartData data, _) => data.category,
                                yValueMapper:
                                    (ChartData data, _) => data.amount,
                                pointColorMapper:
                                    (ChartData data, _) => data.color,
                                radius: '80%',
                                innerRadius: '60%',
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  lastMonthCategoryExpenses.entries.map((
                                    entry,
                                  ) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color:
                                              categoryColorMap[entry.key] ??
                                              Colors.black,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${entry.key}: ₹${entry.value.toStringAsFixed(0)}',
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}
