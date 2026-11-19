import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/validator.dart';
import 'package:aviokomopanija/widgets/password_visibility_button.dart';
import 'package:aviokomopanija/screens/auth/login.dart';
import 'package:aviokomopanija/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool hidePassword = true;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void register() {
    if (!formKey.currentState!.validate()) return;
    final result = AuthService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );
    if (result != null) {
      setState(() => error = result);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo nalog je kreiran. Sada se prijavi.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tvoje putovanje počinje ovde.',
                  style: TextStyle(fontFamily: 'serif', fontSize: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo nalog se briše restartom aplikacije. Koristi probni imejl i lozinku.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ime i prezime',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: MyValidators.displayNameValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Imejl',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: MyValidators.emailValidator,
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
                  validator: MyValidators.passwordValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: hidePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Potvrda lozinke',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => MyValidators.repeatPasswordValidator(
                    value,
                    passwordController.text,
                  ),
                  onFieldSubmitted: (_) => register(),
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
                FilledButton(
                  onPressed: register,
                  child: const Text('Registruj se'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  ),
                  child: const Text('Već imaš nalog? Prijavi se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
