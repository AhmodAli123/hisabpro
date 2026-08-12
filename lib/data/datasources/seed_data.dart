import '../../core/utils/app_dates.dart';
import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/payment_method.dart';
import '../models/transaction_kind.dart';

class _Seed {
  const _Seed(
    this.day,
    this.hour,
    this.minute,
    this.kind,
    this.categoryId,
    this.amount,
    this.note,
    this.method,
  );

  final int day;
  final int hour;
  final int minute;
  final TransactionKind kind;
  final String categoryId;
  final double amount;
  final String note;
  final PaymentMethod method;
}

abstract final class SeedData {
  static const List<_Seed> currentMonth = <_Seed>[
    _Seed(1, 9, 5, TransactionKind.income, 'inc_salary', 8200, 'Monthly salary', PaymentMethod.bank),
    _Seed(1, 10, 20, TransactionKind.expense, 'exp_rent', 1200, 'Rent', PaymentMethod.bank),
    _Seed(2, 18, 40, TransactionKind.expense, 'exp_food', 245.50, 'Weekly groceries', PaymentMethod.card),
    _Seed(3, 8, 15, TransactionKind.expense, 'exp_transport', 100.50, 'Bus card top-up', PaymentMethod.cash),
    _Seed(4, 20, 10, TransactionKind.expense, 'exp_bills', 310.75, 'Electricity', PaymentMethod.online),
    _Seed(5, 13, 30, TransactionKind.expense, 'exp_food', 42, 'Lunch', PaymentMethod.card),
    _Seed(6, 17, 45, TransactionKind.expense, 'exp_shopping', 289, 'Shoes', PaymentMethod.card),
    _Seed(7, 11, 0, TransactionKind.expense, 'exp_health', 150, 'Pharmacy', PaymentMethod.cash),
    _Seed(8, 19, 25, TransactionKind.expense, 'exp_food', 88.25, 'Groceries', PaymentMethod.card),
    _Seed(9, 7, 50, TransactionKind.expense, 'exp_transport', 45, 'Taxi', PaymentMethod.cash),
    _Seed(10, 14, 0, TransactionKind.income, 'inc_freelance', 650, 'Logo project', PaymentMethod.online),
    _Seed(11, 21, 15, TransactionKind.expense, 'exp_entertainment', 75, 'Cinema', PaymentMethod.card),
    _Seed(12, 12, 5, TransactionKind.expense, 'exp_bills', 120, 'Mobile and internet', PaymentMethod.online),
    _Seed(13, 16, 30, TransactionKind.expense, 'exp_education', 400, 'Online course', PaymentMethod.card),
    _Seed(14, 18, 55, TransactionKind.expense, 'exp_food', 132.50, 'Groceries', PaymentMethod.card),
    _Seed(15, 9, 40, TransactionKind.expense, 'exp_transport', 70, 'Fuel', PaymentMethod.cash),
    _Seed(16, 15, 10, TransactionKind.expense, 'exp_shopping', 96, 'Household items', PaymentMethod.card),
    _Seed(18, 13, 20, TransactionKind.expense, 'exp_food', 64, 'Lunch', PaymentMethod.cash),
    _Seed(20, 10, 0, TransactionKind.expense, 'exp_bills', 85, 'Water', PaymentMethod.online),
    _Seed(22, 19, 30, TransactionKind.expense, 'exp_food', 158.75, 'Groceries', PaymentMethod.card),
    _Seed(24, 8, 30, TransactionKind.expense, 'exp_transport', 55, 'Bus card top-up', PaymentMethod.cash),
    _Seed(26, 20, 45, TransactionKind.expense, 'exp_entertainment', 110, 'Family outing', PaymentMethod.card),
  ];

  static const List<_Seed> lastMonth = <_Seed>[
    _Seed(1, 9, 10, TransactionKind.income, 'inc_salary', 8200, 'Monthly salary', PaymentMethod.bank),
    _Seed(1, 10, 30, TransactionKind.expense, 'exp_rent', 1200, 'Rent', PaymentMethod.bank),
    _Seed(3, 18, 20, TransactionKind.expense, 'exp_food', 320, 'Groceries', PaymentMethod.card),
    _Seed(6, 11, 45, TransactionKind.expense, 'exp_bills', 285, 'Electricity', PaymentMethod.online),
    _Seed(9, 16, 15, TransactionKind.expense, 'exp_shopping', 410, 'Clothes', PaymentMethod.card),
    _Seed(12, 8, 40, TransactionKind.expense, 'exp_transport', 180, 'Fuel', PaymentMethod.cash),
    _Seed(15, 19, 5, TransactionKind.expense, 'exp_food', 265, 'Groceries', PaymentMethod.card),
    _Seed(18, 10, 25, TransactionKind.expense, 'exp_health', 95, 'Doctor visit', PaymentMethod.cash),
    _Seed(20, 12, 0, TransactionKind.income, 'inc_bonus', 500, 'Performance bonus', PaymentMethod.bank),
    _Seed(22, 7, 30, TransactionKind.expense, 'exp_travel', 780, 'Flight home', PaymentMethod.card),
    _Seed(25, 21, 10, TransactionKind.expense, 'exp_entertainment', 140, 'Cinema', PaymentMethod.card),
    _Seed(27, 18, 50, TransactionKind.expense, 'exp_food', 210, 'Groceries', PaymentMethod.card),
    _Seed(29, 9, 15, TransactionKind.expense, 'exp_bills', 130, 'Mobile and internet', PaymentMethod.online),
  ];

  static const List<_Seed> today = <_Seed>[
    _Seed(1, 8, 20, TransactionKind.expense, 'exp_transport', 12, 'Bus fare', PaymentMethod.cash),
    _Seed(1, 13, 15, TransactionKind.expense, 'exp_food', 22, 'Lunch', PaymentMethod.cash),
    _Seed(1, 19, 40, TransactionKind.expense, 'exp_food', 51.50, 'Dinner groceries', PaymentMethod.card),
  ];

  static List<MoneyTransaction> buildForMonth(
    DateTime monthStart,
    List<_Seed> seeds, {
    DateTime? notAfter,
    bool forceDayToMonthDay = false,
  }) {
    final List<MoneyTransaction> result = <MoneyTransaction>[];
    final int lastDay = AppDates.daysInMonth(monthStart);

    for (final _Seed seed in seeds) {
      final int day = (forceDayToMonthDay ? monthStart.day : seed.day).clamp(1, lastDay);
      final DateTime date = DateTime(
        monthStart.year,
        monthStart.month,
        day,
        seed.hour,
        seed.minute,
      );
      if (notAfter != null && date.isAfter(notAfter)) {
        continue;
      }
      result.add(
        MoneyTransaction.create(
          kind: seed.kind,
          amount: seed.amount,
          categoryId: seed.categoryId,
          dateTime: date,
          note: seed.note,
          paymentMethod: seed.method,
        ),
      );
    }

    return result;
  }

  static List<MonthlyBudget> defaultBudgets(DateTime reference) {
    return <MonthlyBudget>[
      MonthlyBudget.forMonth(AppDates.startOfMonth(reference), 5000),
      MonthlyBudget.forMonth(AppDates.startOfMonth(DateTime(reference.year, reference.month - 1)), 5000),
    ];
  }
}
