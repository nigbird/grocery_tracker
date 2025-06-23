import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String category;

  @HiveField(2)
  double price;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  double amount;

  Expense({
    required this.name,
    required this.category,
    required this.price,
    required this.date,
    required this.amount,
  });
}
