import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:selavu/addexpenses.dart';
import 'package:selavu/color.dart';
import 'package:selavu/expense.dart';
import 'package:selavu/expensepiechartscreen.dart';
import 'package:selavu/profilescreen.dart';
import 'package:selavu/viewexpenses.dart';
import 'package:selavu/walletprovider.dart';

class BottomNavbar extends StatefulWidget {
  final Box<Expense> expenseBox;
  final Box<Wallet> walletBox;

  const BottomNavbar({
    Key? key,
    required this.expenseBox,
    required this.walletBox,
  }) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarPageState();
}

class _BottomNavbarPageState extends State<BottomNavbar> {
  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      AddExpenseScreen(box: widget.expenseBox),
      ExpenseListScreen(box: widget.expenseBox),
      ExpenseDoughnutChartScreen(box: widget.expenseBox),
      Profilescreen(),
    ];

    return Scaffold(
      backgroundColor: Appcolor().backgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bottomBarPages,
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Appcolor().btnColorlight,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Appcolor().btnColordark,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_rounded, color: Colors.black),
            activeItem: Icon(Icons.home_rounded, color: Colors.white),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.description_rounded, color: Colors.black),
            activeItem: Icon(Icons.description_rounded, color: Colors.white),
            itemLabel: 'Expenses',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.pie_chart_rounded, color: Colors.black),
            activeItem: Icon(Icons.pie_chart_rounded, color: Colors.white),
            itemLabel: 'Chart',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.account_circle_rounded,
              color: Colors.black,
            ),
            activeItem: Icon(Icons.account_circle_rounded, color: Colors.white),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}
