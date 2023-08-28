// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/extensions/alert_dialog_convenience_showing.dart';
import 'package:poc_flutter_smart_lift_sdk/models/user.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/login_page.dart';
import 'package:poc_flutter_smart_lift_sdk/repositories/tuya_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.user,
    super.key,
  });

  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poc Smart Lift SDK'),
        actions: [
          TextButton(
            child: const Text('Log Out'),
            onPressed: () => _logout(context),
          )
        ],
      ),
      backgroundColor: Colors.blueGrey.shade50,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              onTap: () {
                final controller = TextEditingController();

                AlertDialogConvenienceShowing.showAlertDialog(
                  context: context,
                  title: 'Nickname',
                  inputField: TextField(
                    controller: controller,
                  ),
                  actions: [
                    AlertAction('Cancel'),
                    AlertAction('Edit', onPressed: () {
                      _updateNickname(context, nickname: controller.text);
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.user.userName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Nickname',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.user.nickname,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'User ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.user.userId,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Session ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.user.sessionId,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Future<void> _updateNickname(
    BuildContext context, {
    required String nickname,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      await repository.updateNickname(nickname: nickname);

      setState(() {
        widget.user.nickname = nickname;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      await repository.logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }
}
