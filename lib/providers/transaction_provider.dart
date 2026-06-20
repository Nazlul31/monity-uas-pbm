import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  int? _currentUserId;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  /// Load semua transaksi milik user aktif dari database
  Future<void> loadTransactions(int userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseHelper.instance.getTransactionsByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Hapus semua data lokal (saat logout)
  void clearTransactions() {
    _transactions = [];
    _currentUserId = null;
    notifyListeners();
  }

  // ─── FILTERS ────────────────────────────────────────────────────

  /// Transaksi hari ini
  List<TransactionModel> get dailyTransactions {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  /// Transaksi 7 hari terakhir
  List<TransactionModel> get weeklyTransactions {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final startOfDay = DateTime(start.year, start.month, start.day);
    return _transactions
        .where((t) => t.date.isAfter(startOfDay))
        .toList();
  }

  /// Transaksi bulan ini
  List<TransactionModel> get monthlyTransactions {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))))
        .toList();
  }

  /// Ambil transaksi berdasarkan index periode
  List<TransactionModel> getByPeriod(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return dailyTransactions;
      case 1:
        return weeklyTransactions;
      case 2:
        return monthlyTransactions;
      default:
        return _transactions;
    }
  }

  // ─── AGGREGATES ────────────────────────────────────────────────

  double get totalSaldo {
    double income = 0, expense = 0;
    for (final tx in _transactions) {
      if (tx.type == 'pemasukan') {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return income - expense;
  }

  double totalIncomeFor(List<TransactionModel> list) =>
      list.where((t) => t.type == 'pemasukan').fold(0.0, (s, t) => s + t.amount);

  double totalExpenseFor(List<TransactionModel> list) =>
      list.where((t) => t.type == 'pengeluaran').fold(0.0, (s, t) => s + t.amount);

  /// Pengeluaran per kategori untuk pie chart
  Map<String, double> expenseByCategory(List<TransactionModel> list) {
    final Map<String, double> result = {};
    for (final tx in list.where((t) => t.type == 'pengeluaran')) {
      result[tx.category] = (result[tx.category] ?? 0) + tx.amount;
    }
    return result;
  }

  /// Pengeluaran per hari selama 7 hari untuk bar chart (index 0 = 6 hari lalu)
  List<double> weeklyExpensePerDay() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day - (6 - i),
      );
      final nextDay = day.add(const Duration(days: 1));
      return _transactions
          .where((t) =>
              t.type == 'pengeluaran' &&
              t.date.isAfter(day.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(nextDay))
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  /// Pemasukan per hari selama 7 hari
  List<double> weeklyIncomePerDay() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day - (6 - i),
      );
      final nextDay = day.add(const Duration(days: 1));
      return _transactions
          .where((t) =>
              t.type == 'pemasukan' &&
              t.date.isAfter(day.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(nextDay))
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  /// Pengeluaran per hari selama sebulan untuk line chart
  List<double> monthlyExpensePerDay() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final day = DateTime(now.year, now.month, i + 1);
      final nextDay = day.add(const Duration(days: 1));
      return monthlyTransactions
          .where((t) =>
              t.type == 'pengeluaran' &&
              t.date.isAfter(day.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(nextDay))
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  // ─── ADD / DELETE ───────────────────────────────────────────────

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  int? get currentUserId => _currentUserId;
}
