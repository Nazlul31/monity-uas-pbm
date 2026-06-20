import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class ReportScreen extends StatefulWidget {
  final bool embedded;
  const ReportScreen({super.key, this.embedded = false});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedPeriod = 2; // 0=Hari, 1=Minggu, 2=Bulanan
  int _touchedIndex = -1;
  DateTime _currentMonth = DateTime.now();

  final List<String> _periods = ['Hari', 'Minggu', 'Bulanan'];

  String _monthLabel(DateTime date) {
    const months = [
      '', 'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return '${months[date.month]} ${date.year}';
  }

  void _prevMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1);
      });

  Map<String, double> _getCategoryExpenses(
      List<TransactionModel> transactions) {
    final Map<String, double> map = {};
    for (final tx in transactions) {
      if (tx.type == 'pengeluaran') {
        map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  String _formatRp(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final allTx = provider.transactions;
        final totalIncome = allTx
            .where((t) => t.type == 'pemasukan')
            .fold(0.0, (s, t) => s + t.amount);
        final totalExpense = allTx
            .where((t) => t.type == 'pengeluaran')
            .fold(0.0, (s, t) => s + t.amount);
        final savings = totalIncome - totalExpense;
        final savingsPct = totalIncome > 0
            ? ((savings / totalIncome) * 100).round()
            : 0;

        final categoryExpenses = _getCategoryExpenses(allTx.toList());
        final totalCatExpense =
            categoryExpenses.values.fold(0.0, (s, v) => s + v);

        // Pie chart data
        final List<Color> pieColors = [
          AppTheme.primaryColor,
          const Color(0xFFFF8C66),
          const Color(0xFF6C8EFF),
          const Color(0xFFFFCB47),
          const Color(0xFF9B59B6),
          const Color(0xFF1ABC9C),
        ];

        final catEntries = categoryExpenses.entries.toList();

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            slivers: [
              // Header gradient
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
                  padding: EdgeInsets.fromLTRB(
                      24, widget.embedded ? 20 : 52, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laporan Keuangan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Month navigator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _prevMonth,
                            child: const Icon(Icons.chevron_left,
                                color: Colors.white70, size: 28),
                          ),
                          Text(
                            _monthLabel(_currentMonth),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: _nextMonth,
                            child: const Icon(Icons.chevron_right,
                                color: Colors.white70, size: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Period filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
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
                              duration: const Duration(milliseconds: 250),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
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
                ),
              ),

              // Summary cards
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          label: 'Pemasukan',
                          value: _formatRp(totalIncome),
                          color: AppTheme.incomeColor,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          label: 'Pengeluaran',
                          value: _formatRp(totalExpense),
                          color: AppTheme.expenseColor,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _savingsCard(
                          pct: savingsPct,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pie chart section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Pengeluaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Berdasarkan kategori',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (categoryExpenses.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Belum ada data pengeluaran.',
                                style: TextStyle(
                                    color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Pie chart
                              SizedBox(
                                height: 200,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        pieTouchData: PieTouchData(
                                          touchCallback: (event, response) {
                                            setState(() {
                                              if (!event
                                                      .isInterestedForInteractions ||
                                                  response == null ||
                                                  response.touchedSection ==
                                                      null) {
                                                _touchedIndex = -1;
                                                return;
                                              }
                                              _touchedIndex = response
                                                  .touchedSection!
                                                  .touchedSectionIndex;
                                            });
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 60,
                                        sections: catEntries
                                            .asMap()
                                            .entries
                                            .map((e) {
                                          final i = e.key;
                                          final entry = e.value;
                                          final pct = totalCatExpense > 0
                                              ? (entry.value /
                                                      totalCatExpense *
                                                      100)
                                                  .toStringAsFixed(0)
                                              : '0';
                                          final isTouched =
                                              i == _touchedIndex;

                                          return PieChartSectionData(
                                            color: pieColors[
                                                i % pieColors.length],
                                            value: entry.value,
                                            title: '$pct%',
                                            radius: isTouched ? 36 : 28,
                                            titleStyle: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    // Center label
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'TOTAL\nPENGELUARAN',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.textSecondary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatRp(totalExpense),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (totalIncome > 0)
                                          Text(
                                            '▼ ${savingsPct.abs()}%',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.expenseColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Legend
                              ...catEntries.asMap().entries.map((e) {
                                final i = e.key;
                                final entry = e.value;
                                final pct = totalCatExpense > 0
                                    ? (entry.value / totalCatExpense * 100)
                                        .toStringAsFixed(1)
                                    : '0';
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: pieColors[i % pieColors.length],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatRp(entry.value),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
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

  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _savingsCard({required int pct}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.savings_rounded,
              color: AppTheme.primaryColor, size: 18),
          const SizedBox(height: 6),
          Text(
            '$pct%',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text(
            'Tabungan',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
