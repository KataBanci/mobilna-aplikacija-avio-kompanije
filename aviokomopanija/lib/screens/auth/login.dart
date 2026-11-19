import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/validator.dart';
import 'package:aviokomopanija/widgets/password_visibility_button.dart';
import 'package:aviokomopanija/screens/home_screen.dart';
import 'package:aviokomopanija/screens/admin/admin_screen.dart';
import 'package:aviokomopanija/screens/auth/register.dart';
import 'package:aviokomopanija/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (!formKey.currentState!.validate()) return;
    if (!AuthService.login(emailController.text, passwordController.text)) {
      setState(() => error = 'Imejl ili lozinka nisu ispravni.');
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/booking'),
        builder: (_) => AuthService.currentUser?['role'] == 'admin'
            ? const AdminScreen()
            : const HomeScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Dobro došli nazad.',
                  style: TextStyle(fontFamily: 'serif', fontSize: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Prijavi se svojim probnim nalogom. Administrator koristi korisničko ime admin.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Imejl ili korisničko ime',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: MyValidators.loginEmailValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Lozinka',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: PasswordVisibilityButton(
                      isHidden: hidePassword,
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  validator: MyValidators.loginPasswordValidator,
                  onFieldSubmitted: (_) => login(),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(onPressed: login, child: const Text('Prijavi se')),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text('Nemaš nalog? Registruj se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
