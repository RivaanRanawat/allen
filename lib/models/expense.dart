const String tableExpense = 'expense';

class ExpenseFields {
  static final List<String> values = [
    id, title, money, incomeOrExpense
  ];

  static const String id = '_id';
  static const String money = 'money';
  static const String title = 'title';
  static const String incomeOrExpense = 'incomeOrExpense';
}

class Expense {
  final int? id;
  final String title;
  final int money;
  final String incomeOrExpense;

  const Expense({
    this.id,
    required this.title,
    required this.money,
    required this.incomeOrExpense
  });

  Expense copy({
    int? id,
    int? money,
    String? title,
    String? incomeOrExpense,
  }) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        incomeOrExpense: incomeOrExpense?? this.incomeOrExpense,
        money:money??this.money,
      );

  static Expense fromJson(Map<String, Object?> json) => Expense(
        id: json[ExpenseFields.id] as int?,
        title: json[ExpenseFields.title] as String,
        money: json[ExpenseFields.money] as int,
        incomeOrExpense: json[ExpenseFields.incomeOrExpense] as String,
      );

  Map<String, Object?> toJson() => {
        ExpenseFields.id: id,
        ExpenseFields.title: title,
        ExpenseFields.money: money,
        ExpenseFields.incomeOrExpense: incomeOrExpense
      };
}
