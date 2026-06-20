import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'tx-1',
      title: 'Gaji Bulanan',
      amount: 5000000.0,
      type: 'pemasukan',
      category: 'Gaji',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 'tx-2',
      title: 'Belanja Bulanan',
      amount: 1500000.0,
      type: 'pengeluaran',
      category: 'Kebutuhan',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: 'tx-3',
      title: 'Beli Kopi',
      amount: 50000.0,
      type: 'pengeluaran',
      category: 'Gaya Hidup',
      date: DateTime.now(),
    ),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  double get totalSaldo {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in _transactions) {
      if (tx.type == 'pemasukan') {
        totalIncome += tx.amount;
      } else if (tx.type == 'pengeluaran') {
        totalExpense += tx.amount;
      }
    }

    return totalIncome - totalExpense;
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
    // TODO: Integrasikan dengan DatabaseHelper di branch feature/integration
    // DatabaseHelper().insertTransaction(transaction);
  }

  Future<void> loadTransactionsFromDB() async {
    // TODO: Integrasikan dengan DatabaseHelper di branch feature/integration
    // _transactions.clear();
    // final dbTransactions = await DatabaseHelper().getTransactions();
    // _transactions.addAll(dbTransactions);
    // notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    // TODO: Integrasikan dengan DatabaseHelper di branch feature/integration
    // DatabaseHelper().deleteTransaction(id);
  }
}
