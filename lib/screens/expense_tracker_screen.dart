import 'package:allen/models/expense.dart';
import 'package:allen/services/expense_db_helper.dart';
import 'package:allen/widgets/custom_drawer.dart';
import 'package:allen/widgets/top_exp_card.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:iconsax/iconsax.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({Key? key}) : super(key: key);

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  // collect user input
  final _amountController = TextEditingController();
  final _itemController = TextEditingController();
  final _advancedDrawerController = AdvancedDrawerController();
  bool _isIncome = false;
  List<Expense> expenses = [];
  bool isLoading = false;
  int balance = 0;
  int income = 0;
  int expense = 0;

  @override
  void dispose() {
    ExpenseDatabase.instance.close();
    super.dispose();
  }

  Future refreshExpenses() async {
    setState(() => isLoading = true);
    expenses = await ExpenseDatabase.instance.readAllExpenses();
    balance = 0;
    income = 0;
    expense = 0;
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].incomeOrExpense == 'Income') {
        balance += expenses[i].money;
        income += expenses[i].money;
      } else {
        balance -= expenses[i].money;
        expense += expenses[i].money;
      }
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshExpenses();
  }

  Future addExpense(String title, bool isIncome, int money) async {
    final expense = Expense(
        title: title,
        // id: 1,
        money: money,
        incomeOrExpense: isIncome ? "Income" : "Expense");

    await ExpenseDatabase.instance.create(expense);
    refreshExpenses();
  }

  // new transaction
  void _newTransaction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return FadeIn(
                child: AlertDialog(
                  title: Text('New Transaction'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Expense'),
                            Switch(
                              value: _isIncome,
                              onChanged: (newValue) {
                                setState(() {
                                  _isIncome = newValue;
                                });
                              },
                            ),
                            const Text('Income'),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  filled: true,
                                  fillColor: Color(0xffF5F6FA),
                                  hintText: "Amount",
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _itemController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    filled: true,
                                    fillColor: Color(0xffF5F6FA),
                                    hintText: "For What",
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    MaterialButton(
                      // color: Colors.grey[600],
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text('Enter',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        if (_amountController.text.isNotEmpty &&
                            _itemController.text.isNotEmpty) {
                          addExpense(_itemController.text, _isIncome,
                              int.parse(_amountController.text));
                          setState(() {
                            _itemController.text = "";
                            _amountController.text = "";
                          });
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.grey.shade900,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade900,
            blurRadius: 20.0,
            spreadRadius: 5.0,
            offset: const Offset(-20.0, 0.0),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      drawer: const CustomDrawer(),
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              color: Colors.black,
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Iconsax.close_square : Iconsax.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            centerTitle: true,
            title: BounceInDown(
              child: const Text(
                "Allen",
                style: TextStyle(color: Colors.black),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: _newTransaction,
                  icon: const Icon(Iconsax.add_circle4,
                      color: Colors.black, size: 25))
            ]),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: TopExpCard(
                  balance: balance.toString(),
                  income: income.toString(),
                  expense: expense.toString(),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              return SlideInRight(
                                duration: Duration(milliseconds: (index+1)*200),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      color: const Color(0xffF5F6FA),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.money,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(expenses[index].title,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Text(
                                            (expenses[index].incomeOrExpense ==
                                                        'Expense'
                                                    ? '-'
                                                    : '+') +
                                                '₹' +
                                                expenses[index].money.toString(),
                                            style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: expenses[index]
                                                          .incomeOrExpense ==
                                                      'Expense'
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
