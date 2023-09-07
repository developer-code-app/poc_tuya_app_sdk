// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/ui_blocking_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/loading_with_blocking_widget.dart';
import 'package:poc_flutter_smart_lift_sdk/models/user.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/home_page.dart';
import 'package:poc_flutter_smart_lift_sdk/repositories/tuya_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final countryCodeTextController = TextEditingController(text: '66');
  final uidTextController = TextEditingController(text: 'az1694077932939nDcaA');
  final passwordTextController = TextEditingController(text: 'qweasd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: LoadingWithBlockingWidget(
        child: Column(
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
                        controller: uidTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'UID',
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
                        onPressed: () => _loginWithEmail(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithEmail(BuildContext context) async {
    final repository = context.read<TuyaRepository>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    uiBlockingCubit.block();

    try {
      final user = await repository.loginWithUID(
        countryCode: countryCodeTextController.text,
        uid: uidTextController.text,
        password: passwordTextController.text,
      );

      navigationToHomePage(user: user);
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  void navigationToHomePage({required User user}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(user: user),
      ),
    );
  }
}
