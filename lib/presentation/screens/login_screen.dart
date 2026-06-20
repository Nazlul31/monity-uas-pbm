import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regUsernameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();

  bool _obscureLoginPw = true;
  bool _obscureRegPw = true;
  bool _obscureConfirmPw = true;
  bool _showRegister = false;

  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _switchToRegister() {
    setState(() => _showRegister = true);
    _slideCtrl.forward(from: 0);
  }

  void _switchToLogin() {
    setState(() => _showRegister = false);
  }

  Future<void> _login() async {
    if (!(_loginKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final txProvider = context.read<TransactionProvider>();

    final error = await auth.login(
      emailOrUsername: _loginEmailCtrl.text,
      password: _loginPasswordCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      _showError(error);
    } else {
      // Load transaksi user
      await txProvider.loadTransactions(auth.currentUser!.id!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  Future<void> _register() async {
    if (!(_registerKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final txProvider = context.read<TransactionProvider>();

    final error = await auth.register(
      fullName: _regNameCtrl.text,
      username: _regUsernameCtrl.text,
      email: _regEmailCtrl.text,
      password: _regPasswordCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      _showError(error);
    } else {
      await txProvider.loadTransactions(auth.currentUser!.id!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: AppTheme.expenseColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // Logo
              const SizedBox(height: 24),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'e',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'monity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Container(
                  key: ValueKey(_showRegister),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: _showRegister ? _buildRegisterForm() : _buildLoginForm(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Form(
        key: _loginKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Selamat datang kembali 👋',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _buildLabel('Username atau Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loginEmailCtrl,
              decoration: const InputDecoration(
                hintText: 'Username atau email@example.com',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            _buildLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loginPasswordCtrl,
              obscureText: _obscureLoginPw,
              decoration: InputDecoration(
                hintText: '• • • • • • • •',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPw ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureLoginPw = !_obscureLoginPw),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
            ),
            const SizedBox(height: 24),

            auth.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : CustomButton(text: 'Masuk', onPressed: _login),
            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('atau',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: _switchToRegister,
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Form(
        key: _registerKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _switchToLogin,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppTheme.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                'Isi data diri untuk mendaftar',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _regNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textSecondary, size: 20),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Nama minimal 2 karakter' : null,
            ),
            const SizedBox(height: 14),

            _buildLabel('Username'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _regUsernameCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: naufal123',
                prefixIcon: Icon(Icons.alternate_email, color: AppTheme.textSecondary, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
                if (v.trim().length < 3) return 'Username minimal 3 karakter';
                if (v.contains(' ')) return 'Username tidak boleh mengandung spasi';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _regEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'email@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _buildLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _regPasswordCtrl,
              obscureText: _obscureRegPw,
              decoration: InputDecoration(
                hintText: 'Minimal 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPw ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureRegPw = !_obscureRegPw),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
            ),
            const SizedBox(height: 14),

            _buildLabel('Konfirmasi Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _regConfirmCtrl,
              obscureText: _obscureConfirmPw,
              decoration: InputDecoration(
                hintText: 'Ulangi password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPw ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPw = !_obscureConfirmPw),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v != _regPasswordCtrl.text) return 'Password tidak sama';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Dengan mendaftar, Anda menyetujui Syarat & Ketentuan kami.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            auth.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : CustomButton(text: 'Daftar', onPressed: _register),
            const SizedBox(height: 16),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: _switchToLogin,
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
