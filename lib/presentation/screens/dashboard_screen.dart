import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/empty_state.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNav = 0;
  int _selectedPeriod = 2; // 0=Harian, 1=Mingguan, 2=Bulanan

  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const ReportScreen(embedded: true),
      const SizedBox.shrink(),
      const HistoryScreen(embedded: true),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _selectedNav,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () async {
        final auth = context.read<AuthProvider>();
        if (auth.currentUser == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(
              userId: auth.currentUser!.id!,
            ),
          ),
        );
        setState(() {});
      },
      backgroundColor: AppTheme.primaryColor,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 12,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Home'),
            _navItem(1, Icons.bar_chart_rounded, 'Reports'),
            const SizedBox(width: 48),
            _navItem(3, Icons.receipt_long_rounded, 'Log'),
            _navItem(4, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selectedNav == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNav = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(selected ? 6 : 4),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryColor.withAlpha(25) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer2<TransactionProvider, AuthProvider>(
      builder: (context, txProvider, auth, _) {
        final user = auth.currentUser;
        final periodTxs = txProvider.getByPeriod(_selectedPeriod);
        final saldo = txProvider.totalSaldo;
        final totalIncome = txProvider.totalIncomeFor(periodTxs);
        final totalExpense = txProvider.totalExpenseFor(periodTxs);

        final greeting = _getGreeting();
        final firstName = user?.fullName.split(' ').first ?? 'Pengguna';

        return SafeArea(
          child: txProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : CustomScrollView(
                  slivers: [
                    // Header + Balance card
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1C2A3A), Color(0xFF2C3E50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$greeting, $firstName 👋',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(204),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Text(
                                      'Kelola keuanganmu hari ini',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Avatar
                                GestureDetector(
                                  onTap: () => setState(() => _selectedNav = 4),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white.withAlpha(80), width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.initials ?? '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Total Saldo
                            const Text(
                              'Total Kas',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRp(saldo),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: txProvider.totalIncomeFor(txProvider.transactions) > 0
                                    ? (saldo /
                                            txProvider.totalIncomeFor(
                                                txProvider.transactions))
                                        .clamp(0.0, 1.0)
                                    : 0,
                                backgroundColor: Colors.white.withAlpha(51),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  saldo >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.warning_amber_rounded,
                                  color:
                                      saldo >= 0 ? AppTheme.primaryColor : Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  saldo >= 0
                                      ? 'Keuangan kamu sehat!'
                                      : 'Perhatikan pengeluaranmu',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(178),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Income / Expense mini cards
                            Row(
                              children: [
                                Expanded(
                                  child: _miniCard(
                                    icon: Icons.arrow_downward_rounded,
                                    label: 'Pemasukan',
                                    amount: _formatRp(totalIncome),
                                    color: AppTheme.incomeColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _miniCard(
                                    icon: Icons.arrow_upward_rounded,
                                    label: 'Pengeluaran',
                                    amount: _formatRp(totalExpense),
                                    color: AppTheme.expenseColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Period selector + Detail Laporan
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Laporan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF6F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: List.generate(_periods.length, (i) {
                                  final selected = _selectedPeriod == i;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedPeriod = i),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppTheme.primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _periods[i],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                            fontSize: 13,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getPeriodDescription(_selectedPeriod),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Transaction list
                    periodTxs.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'Belum Ada Transaksi',
                              message: _getEmptyMessage(_selectedPeriod),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final tx = periodTxs[index];
                                  return _transactionTile(tx);
                                },
                                childCount: periodTxs.length,
                              ),
                            ),
                          ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getPeriodDescription(int period) {
    switch (period) {
      case 0:
        return 'Menampilkan transaksi hari ini';
      case 1:
        return 'Menampilkan transaksi 7 hari terakhir';
      case 2:
        return 'Menampilkan transaksi bulan ini';
      default:
        return '';
    }
  }

  String _getEmptyMessage(int period) {
    switch (period) {
      case 0:
        return 'Belum ada transaksi hari ini.\nTambahkan transaksi dengan tombol +';
      case 1:
        return 'Belum ada transaksi dalam 7 hari terakhir.';
      case 2:
        return 'Belum ada transaksi bulan ini.';
      default:
        return 'Tambah transaksi dengan tombol +';
    }
  }

  Widget _miniCard({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final isIncome = tx.type == 'pemasukan';
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${tx.category} • ${_formatDate(tx.date)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isIncome ? 'Pemasukan' : 'Pengeluaran',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${_formatRp(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRp(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]}';
  }
}
