import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/main_menu.dart';
import 'package:umkm_connect/services/api_static.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _errorMessage = '';
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final api = APIStatic();
      final email = _emailController.text.trim();
      final pass = _passwordController.text.trim();

      if (isLogin) {
        final res = await api.login(email, pass);
        if (res.containsKey('access_token') && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      } else {
        final res = await api.register(
          _nameController.text.trim(),
          email,
          pass,
        );
        if (res.containsKey('access_token') && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }

    setState(() => _loading = false);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: Text(
                      isLogin ? 'Login' : 'Daftar',
                      key: ValueKey(isLogin),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SlideTransition hanya ketika !isLogin
                  if (!isLogin)
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nama Lengkap',
                            validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: (value) => value!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscure: true,
                    validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.red)),

                  ElevatedButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? 'Login' : 'Daftar'),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        if (!isLogin) {
                          _animController.forward(from: 0);
                        }
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Belum punya akun? Daftar'
                          : 'Sudah punya akun? Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
