import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/empty_state.dart';

class ReportScreen extends StatefulWidget {
  final bool embedded;
  const ReportScreen({super.key, this.embedded = false});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPeriod = 2; // 0=Harian, 1=Mingguan, 2=Bulanan
  int _touchedIndex = -1;
  late final TabController _tabCtrl;

  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];

  final List<Color> _pieColors = [
    AppTheme.primaryColor,
    const Color(0xFFFF8C66),
    const Color(0xFF6C8EFF),
    const Color(0xFFFFCB47),
    const Color(0xFF9B59B6),
    const Color(0xFF1ABC9C),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this, initialIndex: 2);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _selectedPeriod = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
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
                        const SizedBox(height: 4),
                        Text(
                          'Pantau keuanganmu secara detail',
                          style: TextStyle(
                              color: Colors.white.withAlpha(178), fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        // Tab period selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: List.generate(_periods.length, (i) {
                              final selected = _selectedPeriod == i;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedPeriod = i);
                                    _tabCtrl.animateTo(i);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _periods[i],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selected
                                            ? AppTheme.primaryColor
                                            : Colors.white70,
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
                      ],
                    ),
                  ),
                ),

                // Content based on period
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPeriodContent(provider),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodContent(TransactionProvider provider) {
    switch (_selectedPeriod) {
      case 0:
        return _buildDailyView(provider);
      case 1:
        return _buildWeeklyView(provider);
      case 2:
        return _buildMonthlyView(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── HARIAN ────────────────────────────────────────────────────

  Widget _buildDailyView(TransactionProvider provider) {
    final txs = provider.dailyTransactions;
    final income = provider.totalIncomeFor(txs);
    final expense = provider.totalExpenseFor(txs);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey('daily'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummaryRow(income: income, expense: expense, label: 'Hari Ini'),
          const SizedBox(height: 20),

          // Target harian progress
          _buildDailyTargetCard(expense),
          const SizedBox(height: 20),

          // Transaksi hari ini
          const Text('Transaksi Hari Ini',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          txs.isEmpty
              ? EmptyState(
                  icon: Icons.today_outlined,
                  title: 'Belum Ada Transaksi Hari Ini',
                  message: 'Tambah transaksi untuk mulai mencatat keuangan hari ini.',
                )
              : Column(
                  children: txs.map((tx) => _transactionTile(tx)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildDailyTargetCard(double expense) {
    const target = 500000.0;
    final pct = (expense / target).clamp(0.0, 1.0);
    final color = pct > 0.8 ? AppTheme.expenseColor : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              const Text('Target Pengeluaran Harian',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatRp(expense),
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              Text('dari ${_formatRp(target)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MINGGUAN ──────────────────────────────────────────────────

  Widget _buildWeeklyView(TransactionProvider provider) {
    final txs = provider.weeklyTransactions;
    final income = provider.totalIncomeFor(txs);
    final expense = provider.totalExpenseFor(txs);
    final expensePerDay = provider.weeklyExpensePerDay();
    final incomePerDay = provider.weeklyIncomePerDay();
    final maxY = [...expensePerDay, ...incomePerDay]
        .fold(0.0, (m, v) => v > m ? v : m);

    final now = DateTime.now();
    final dayLabels = List.generate(7,
        (i) => _shortDay(now.subtract(Duration(days: 6 - i)).weekday));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey('weekly'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(income: income, expense: expense, label: '7 Hari Terakhir'),
          const SizedBox(height: 20),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grafik Mingguan',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                const Text('Perbandingan pemasukan & pengeluaran',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY > 0 ? maxY * 1.2 : 1000000,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY > 0 ? maxY / 4 : 250000,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              dayLabels[v.toInt()],
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 46,
                            getTitlesWidget: (v, _) => Text(
                              v >= 1000000
                                  ? '${(v / 1000000).toStringAsFixed(1)}M'
                                  : '${(v / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: incomePerDay[i],
                              color: AppTheme.incomeColor.withAlpha(200),
                              width: 10,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            BarChartRodData(
                              toY: expensePerDay[i],
                              color: AppTheme.expenseColor.withAlpha(200),
                              width: 10,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppTheme.incomeColor, 'Pemasukan'),
                    const SizedBox(width: 20),
                    _legendDot(AppTheme.expenseColor, 'Pengeluaran'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total aktivitas
          _buildWeeklyStatsCard(txs, income, expense),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard(
      List<TransactionModel> txs, double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Mingguan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          _statRow(
              Icons.receipt_long_outlined,
              'Total Transaksi',
              '${txs.length} transaksi',
              AppTheme.primaryColor),
          _statRow(
              Icons.arrow_downward_rounded,
              'Total Pemasukan',
              _formatRp(income),
              AppTheme.incomeColor),
          _statRow(
              Icons.arrow_upward_rounded,
              'Total Pengeluaran',
              _formatRp(expense),
              AppTheme.expenseColor),
          _statRow(
              Icons.savings_outlined,
              'Selisih',
              _formatRp(income - expense),
              income >= expense ? AppTheme.incomeColor : AppTheme.expenseColor),
        ],
      ),
    );
  }

  // ─── BULANAN ──────────────────────────────────────────────────

  Widget _buildMonthlyView(TransactionProvider provider) {
    final txs = provider.monthlyTransactions;
    final income = provider.totalIncomeFor(txs);
    final expense = provider.totalExpenseFor(txs);
    final catExpenses = provider.expenseByCategory(txs);
    final totalCatExp = catExpenses.values.fold(0.0, (s, v) => s + v);
    final catEntries = catExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final expensePerDay = provider.monthlyExpensePerDay();
    final maxY = expensePerDay.fold(0.0, (m, v) => v > m ? v : m);
    final savingsPct = income > 0 ? ((income - expense) / income * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey('monthly'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(income: income, expense: expense, label: 'Bulan Ini'),
          const SizedBox(height: 16),

          // Savings percentage card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF1FA88A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Persentase Tabungan',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      '$savingsPct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: (savingsPct / 100).clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withAlpha(60),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Line chart — trend pengeluaran bulanan
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trend Pengeluaran Bulanan',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const Text('Grafik harian bulan ini',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY > 0 ? maxY / 4 : 250000,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt() + 1}',
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (v, _) => Text(
                              v >= 1000000
                                  ? '${(v / 1000000).toStringAsFixed(1)}M'
                                  : '${(v / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: expensePerDay.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.expenseColor,
                          barWidth: 2.5,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.expenseColor.withAlpha(30),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, xPercentage, bar, index) =>
                                FlDotCirclePainter(
                              radius: spot.y > 0 ? 3 : 0,
                              color: AppTheme.expenseColor,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: maxY > 0 ? maxY * 1.2 : 1000000,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pie chart pengeluaran per kategori
          if (catEntries.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian Pengeluaran per Kategori',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 20),
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
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            sections: catEntries.asMap().entries.map((e) {
                              final i = e.key;
                              final entry = e.value;
                              final pct = totalCatExp > 0
                                  ? (entry.value / totalCatExp * 100)
                                      .toStringAsFixed(0)
                                  : '0';
                              final isTouched = i == _touchedIndex;
                              return PieChartSectionData(
                                color: _pieColors[i % _pieColors.length],
                                value: entry.value,
                                title: '$pct%',
                                radius: isTouched ? 38 : 28,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('PENGELUARAN',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text(
                              _formatRp(expense),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
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
                    final pct = totalCatExp > 0
                        ? (entry.value / totalCatExp * 100).toStringAsFixed(1)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _pieColors[i % _pieColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 13, color: AppTheme.textPrimary)),
                          ),
                          Text('$pct%',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(width: 12),
                          Text(_formatRp(entry.value),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ────────────────────────────────────────────

  Widget _buildSummaryRow({
    required double income,
    required double expense,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'Pemasukan',
            value: _formatRp(income),
            color: AppTheme.incomeColor,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Pengeluaran',
            value: _formatRp(expense),
            color: AppTheme.expenseColor,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Selisih',
            value: _formatRp((income - expense).abs()),
            color: income >= expense ? AppTheme.primaryColor : AppTheme.expenseColor,
            icon: income >= expense
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
        ),
      ],
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
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final isIncome = tx.type == 'pemasukan';
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                Text('${tx.category} • ${_formatDate(tx.date)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${_formatRp(tx.amount)}',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _shortDay(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }
}
