// lib/screens/login_screen.dart (Final M3 Implementation)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_banking_app_ui/state/auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _authenticate(BuildContext context, bool isRegister) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      authModel.setMessage('Please enter both username and password.');
      return;
    }

    if (isRegister) {
      authModel.register(username, password);
    } else {
      authModel.login(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds the UI when AuthModel data changes (e.g., loading or message)
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🏦 Banking Companion'),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card( // M3 Card equivalent of your 'card' class
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Matches your 16px
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineMedium, // M3 title style
                      ),
                      const SizedBox(height: 24),

                      // Username Input (M3 Outlined Field)
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(), // Outline for clarity
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Input (M3 Outlined Field)
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button (M3 Filled Button)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: authModel.isLoading ? null : () => _authenticate(context, false),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: authModel.isLoading
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Register Button (M3 Text Button)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: authModel.isLoading ? null : () => _authenticate(context, true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Register'),
                        ),
                      ),

                      // Feedback Message (Error/Success)
                      if (authModel.message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            authModel.message!,
                            style: TextStyle(
                              color: authModel.message!.contains('successful') ? Colors.green : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}