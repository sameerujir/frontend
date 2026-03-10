import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco, size: 64, color: AppTheme.emeraldPrimary),
                const SizedBox(height: 24),
                Text(
                  authVM.isRegisterMode ? "Join the Garden." : "Welcome Back.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "Your personal AI plant expert awaits.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),
                
                _buildInput(_usernameController, "Username", Icons.person_outline),
                const SizedBox(height: 16),
                
                if (authVM.isRegisterMode) ...[
                  _buildInput(_emailController, "Email (Optional)", Icons.email_outlined),
                  const SizedBox(height: 16),
                ],

                _buildInput(_passwordController, "Password", Icons.lock_outline, isPassword: true),
                
                if (authVM.error != null) ...[
                  const SizedBox(height: 24),
                  Text(authVM.error!, style: const TextStyle(color: AppTheme.critical, fontSize: 12), textAlign: TextAlign.center),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authVM.isLoading ? null : () async {
                      bool success = authVM.isRegisterMode
                          ? await authVM.register(_usernameController.text, _passwordController.text, _emailController.text)
                          : await authVM.login(_usernameController.text, _passwordController.text);
                      if (success) widget.onLoggedIn();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: authVM.isLoading 
                       ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                       : Text(authVM.isRegisterMode ? "Create Account" : "Sign In", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => authVM.toggleRegisterMode(),
                  child: Text(
                    authVM.isRegisterMode ? "Already have an account? Sign In" : "New here? Create Account",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}