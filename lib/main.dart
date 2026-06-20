import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/transaction_model.dart';
import 'providers/transaction_provider.dart';

void main() {
  runApp(const MonityApp());
}

class MonityApp extends StatelessWidget {
  const MonityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Monity',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const MonityDummyHomeScreen(),
      ),
    );
  }
}

/// Temporary Home Screen to verify that State Management and dummy data work correctly.
/// This screen is a placeholder for testing purposes before Farel builds the actual UI in presentation/.
class MonityDummyHomeScreen extends StatelessWidget {
  const MonityDummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monity Test Bed'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          final totalSaldo = provider.totalSaldo;

          return Column(
            children: [
              // Balance Card
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${totalSaldo.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: totalSaldo >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              // Transactions List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Transaksi (Dummy)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    Text('${transactions.length} item'),
                  ],
                ),
              ),
              // Transactions List
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isIncome = tx.type == 'pemasukan';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor).withAlpha(26),
                        child: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
                      ),
                      title: Text(tx.title),
                      subtitle: Text('${tx.category} • ${tx.date.toString().split(' ')[0]}'),
                      trailing: Text(
                        '${isIncome ? "+" : "-"} Rp ${tx.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
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
        onPressed: () {
          // Quick add transaction to test dynamic state changes
          final provider = Provider.of<TransactionProvider>(context, listen: false);
          provider.addTransaction(
            TransactionModel(
              id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
              title: 'Bonus Tambahan',
              amount: 250000.0,
              type: 'pemasukan',
              category: 'Bonus',
              date: DateTime.now(),
            ),
          );
        },
        tooltip: 'Tambah Dummy Pemasukan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
