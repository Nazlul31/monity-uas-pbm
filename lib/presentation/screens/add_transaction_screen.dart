import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;
  const AddTransactionScreen({super.key, required this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl   = TextEditingController();
  final _detailCtrl  = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'pemasukan';
  String? _selectedCategory;

  final List<String> _categories = [
    'Makanan',
    'Belanja',
    'Gaji',
    'Transportasi',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Kebutuhan',
    'Gaya Hidup',
    'Freelance',
    'Lainnya',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final tx = TransactionModel(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.userId,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.replaceAll('.', '')),
      type: _selectedType,
      category: _selectedCategory!,
      date: _selectedDate,
      note: _detailCtrl.text.trim().isEmpty ? null : _detailCtrl.text.trim(),
    );

    context.read<TransactionProvider>().addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil disimpan!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    Navigator.pop(context);
  }

  String _formatDateLabel(DateTime date) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
        ),
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Type toggle (Pemasukan / Pengeluaran)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDF6F4),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _typeBtn('pemasukan', 'Pemasukan'),
                  _typeBtn('pengeluaran', 'Pengeluaran'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tanggal
            _sectionLabel('Tanggal'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateLabel(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_rounded,
                        color: AppTheme.primaryColor, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kategori
            _sectionLabel('Kategori'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text(
                    'Pemasukan/pengeluaran',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCategory = val),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Jumlah
            _sectionLabel('Jumlah'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Rp 35.000',
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Jumlah tidak boleh kosong';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Masukkan jumlah yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Judul Transaksi
            _sectionLabel('Judul Transaksi'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Judul'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Judul tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Detail (optional)
            _sectionLabel('Detail'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _detailCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Keterangan tambahan (opsional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            CustomButton(
              text: 'Simpan',
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String type, String label) {
    final selected = _selectedType == type;
    final color = type == 'pemasukan' ? AppTheme.incomeColor : AppTheme.expenseColor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
