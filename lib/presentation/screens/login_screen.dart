import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'e',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Card form
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(28),
                child: _showRegister ? _buildRegisterForm() : _buildLoginForm(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
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
          const SizedBox(height: 24),

          // Email field
          _buildLabel('Username Atau Email'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'example@example.com',
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Email tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),

          // Password field
          _buildLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '• • • • • • • •',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
          ),
          const SizedBox(height: 8),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login button
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : CustomButton(
                  text: 'Masuk',
                  onPressed: _login,
                ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau daftar dengan',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Social buttons placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn(Icons.g_mobiledata_rounded, 'G'),
              const SizedBox(width: 16),
              _socialBtn(Icons.face, 'F'),
            ],
          ),
          const SizedBox(height: 20),

          // Register link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Belum Punya Akun? ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showRegister = true),
                  child: const Text(
                    'Daftar',
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
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showRegister = false),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLabel('Full Name'),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Nama lengkap')),
        const SizedBox(height: 16),
        _buildLabel('Email'),
        const SizedBox(height: 8),
        const TextField(
            decoration: InputDecoration(hintText: 'example@example.com')),
        const SizedBox(height: 16),
        _buildLabel('Mobile Number'),
        const SizedBox(height: 8),
        const TextField(
            decoration: InputDecoration(hintText: '+123 456 788')),
        const SizedBox(height: 16),
        _buildLabel('Date Of Birth'),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'DD / MM / YYY')),
        const SizedBox(height: 16),
        _buildLabel('Password'),
        const SizedBox(height: 8),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(hintText: '• • • • • • • •'),
        ),
        const SizedBox(height: 16),
        _buildLabel('Confirm Password'),
        const SizedBox(height: 8),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(hintText: '• • • • • • • •'),
        ),
        const SizedBox(height: 20),
        Text(
          'By continuing, you agree to our Terms of Use and Privacy Policy.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'Sign Up',
          onPressed: () => setState(() => _showRegister = false),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah Punya Akun? ',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => setState(() => _showRegister = false),
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
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return Container(
      width: 56,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppTheme.textSecondary, size: 24),
    );
  }
}
