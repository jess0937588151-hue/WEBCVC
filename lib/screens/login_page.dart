import 'package:flutter/material.dart';
import 'package:stockflow_flutter_pro/app/app_theme.dart';
import 'package:stockflow_flutter_pro/controllers/app_controller.dart';
import 'package:stockflow_flutter_pro/widgets/glass_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final ok = await widget.controller.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.error ?? '登入失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 12,
                      child: GlassCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.secondary,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: Color(0xFF03131D),
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'StockFlow Pro',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '多店登入、分店回報、總部彙整、依安全庫存自動產生建議叫貨量。這個 Flutter 版本可直接延伸成 Web 與 Android APK 商用系統。',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                    height: 1.7,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: const [
                                _FeatureChip(
                                  icon: Icons.store_mall_directory_rounded,
                                  label: '多店帳號登入',
                                ),
                                _FeatureChip(
                                  icon: Icons.inventory_rounded,
                                  label: '庫存與安全庫存',
                                ),
                                _FeatureChip(
                                  icon: Icons.shopping_cart_checkout_rounded,
                                  label: '建議叫貨量引擎',
                                ),
                                _FeatureChip(
                                  icon: Icons.devices_rounded,
                                  label: 'Web / Android 共用',
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.03),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '測試帳號',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text('主帳號：admin / admin123'),
                                  SizedBox(height: 6),
                                  Text('分店帳號：taipei01 / store123'),
                                  SizedBox(height: 6),
                                  Text('分店帳號：taichung01 / store123'),
                                  SizedBox(height: 6),
                                  Text('分店帳號：kaohsiung01 / store123'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24, height: 24),
                    Expanded(
                      flex: 9,
                      child: GlassCard(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '登入系統',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '請使用主帳號或分店帳號登入',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: '帳號',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? '請輸入帳號'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '密碼',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? '請輸入密碼'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _submitting ? null : _submit,
                                  icon: _submitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.login_rounded),
                                  label: Text(_submitting ? '登入中...' : '進入後台'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '畫面資料會存放在本機裝置，可作為展示版與開發基礎。',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
