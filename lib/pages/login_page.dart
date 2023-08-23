import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const platform = MethodChannel(
    'com.code-app/poc-smart-lift-sdk-flutter',
  );

  final countryCodeTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    TextField(
                      controller: countryCodeTextController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Country Code',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordTextController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextButton(
                      child: const Text('Login'),
                      onPressed: () => _loginWithEmail(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    try {
      final result = await platform.invokeMethod(
        'loginWithEmail',
        {
          'country_code': countryCodeTextController.text,
          'email': emailTextController.text,
          'password': passwordTextController.text,
        },
      );
      print('result: $result');
    } on PlatformException catch (error) {
      print('error: ${error.message}');
    }
  }
}
