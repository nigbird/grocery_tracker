import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Box budgetBox = Hive.box('budget');
  DateTime? budgetStart;
  DateTime? budgetEnd;
  double? totalBudget;

  void _addExpense() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final category = categoryController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;

              if (name.isNotEmpty &&
                  category.isNotEmpty &&
                  price > 0 &&
                  amount > 0) {
                final expense = Expense(
                  name: name,
                  category: category,
                  price: price,
                  date: DateTime.now(),
                  amount: amount,
                );
                _expenseBox.add(expense);
                setState(() {});
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(int index) {
    _expenseBox.deleteAt(index);
    setState(() {});
  }

  void _setBudget() async {
    final budgetController = TextEditingController();
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedRange == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Total Budget'),
        content: TextField(
          controller: budgetController,
          decoration: const InputDecoration(labelText: 'Budget Amount'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount =
                  double.tryParse(budgetController.text.trim()) ?? 0.0;
              if (amount > 0) {
                budgetBox.put('amount', amount);
                budgetBox.put(
                  'start',
                  pickedRange.start.millisecondsSinceEpoch,
                );
                budgetBox.put('end', pickedRange.end.millisecondsSinceEpoch);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Tracker'),
        actions: [
          // Set budget icon
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: _setBudget,
            tooltip: 'Set Budget',
          ),
          // Display budget if set
          ValueListenableBuilder(
            valueListenable: Hive.box('budget').listenable(),
            builder: (context, Box budgetBox, _) {
              final budget = budgetBox.get('amount');
              if (budget != null) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          'ብር${budget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    // Edit budget icon
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _setBudget,
                      tooltip: 'Edit Budget',
                    ),
                    // Delete budget icon
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        budgetBox.delete('amount');
                        budgetBox.delete('start');
                        budgetBox.delete('end');
                        setState(() {});
                      },
                      tooltip: 'Delete Budget',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values.toList();
          expenses.sort((a, b) => b.date.compareTo(a.date));

          return expenses.isEmpty
              ? const Center(child: Text('No expenses yet.'))
              : Column(
                  children: [
                    // Dashboard Card
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildDashboard(expenses, context),
                      ),
                    ),
                    // Expenses List
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final e = expenses[index];
                          return ListTile(
                            title: Text(e.name),
                            subtitle: Text(
                              '${e.category} • ${DateFormat.yMMMd().format(e.date)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Price: ₱${e.price.toStringAsFixed(2)}'),
                                Text('Amount: ${e.amount.toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteExpense(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard(List<Expense> expenses, BuildContext context) {
    double totalSpent = 0;
    Map<String, double> productAmounts = {};
    double highestExpense = 0;
    Expense? highestExpenseItem;

    for (var e in expenses) {
      double expenseTotal = e.price * e.amount;
      totalSpent += expenseTotal;
      productAmounts[e.name] = (productAmounts[e.name] ?? 0) + e.amount;
      if (expenseTotal > highestExpense) {
        highestExpense = expenseTotal;
        highestExpenseItem = e;
      }
    }

    String mostBoughtProduct = '';
    double mostBoughtAmount = 0;
    productAmounts.forEach((name, amount) {
      if (amount > mostBoughtAmount) {
        mostBoughtProduct = name;
        mostBoughtAmount = amount;
      }
    });

    // Budget logic
    double? budget = budgetBox.get('amount');
    DateTime? start = budgetBox.get('start') != null
        ? DateTime.fromMillisecondsSinceEpoch(budgetBox.get('start'))
        : null;
    DateTime? end = budgetBox.get('end') != null
        ? DateTime.fromMillisecondsSinceEpoch(budgetBox.get('end'))
        : null;

    double spentInRange = 0;
    if (budget != null && start != null && end != null) {
      for (var e in expenses) {
        if (!e.date.isBefore(start) && !e.date.isAfter(end)) {
          spentInRange += e.price * e.amount;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (budget != null && start != null && end != null) ...[
          Text(
            'Budget: ₱${budget.toStringAsFixed(2)} (${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)})',
          ),
          Text(
            'Remaining: ₱${(budget - spentInRange).toStringAsFixed(2)}',
            style: TextStyle(
              color: (budget - spentInRange) < 0 ? Colors.red : Colors.green,
            ),
          ),
        ] else
          Text('No budget set.'),
        Text('Total Spent: birr${totalSpent.toStringAsFixed(2)}'),
        Text(
          'Most Bought: $mostBoughtProduct (${mostBoughtAmount.toStringAsFixed(2)})',
        ),
        if (highestExpenseItem != null)
          Text(
            'Highest Expense: ${highestExpenseItem.name} (birr${(highestExpenseItem.price * highestExpenseItem.amount).toStringAsFixed(2)})',
          ),
      ],
    );
  }
}
