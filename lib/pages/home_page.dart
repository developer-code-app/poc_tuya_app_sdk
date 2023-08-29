// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:poc_flutter_smart_lift_sdk/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/extensions/alert_dialog_convenience_showing.dart';
import 'package:poc_flutter_smart_lift_sdk/models/home.dart';
import 'package:poc_flutter_smart_lift_sdk/models/project.dart';
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
  final project = Project(
    name: 'Grand Bangkok Boulevard Ratchaphruek-Charan',
    latitude: 13.7529896,
    longitude: 100.432558,
  );

  bool isEditingHomeList = false;
  List<Home> homes = [];
  Home? currentHome;

  @override
  void initState() {
    super.initState();

    _fetchHomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Colors.blueGrey.shade50,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 16),
          _buildAccountSection(context),
          const Divider(height: 32),
          _buildHomeListSection(context),
          const Divider(height: 32),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Poc Smart Lift SDK'),
      actions: [
        TextButton(
          child: const Text('Log Out'),
          onPressed: () => _logout(context),
        )
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              onTap: () => showEditAccountAlertDialog(),
            )
          ],
        ),
        const SizedBox(height: 8),
        _buildInformation(
          context,
          title: 'Username',
          value: widget.user.userName,
        ),
        const SizedBox(height: 8),
        _buildInformation(
          context,
          title: 'Nickname',
          value: widget.user.nickname,
        ),
        const SizedBox(height: 8),
        _buildInformation(
          context,
          title: 'User ID',
          value: widget.user.userId,
        ),
        const SizedBox(height: 8),
        _buildInformation(
          context,
          title: 'Session ID',
          value: widget.user.sessionId,
        ),
      ],
    );
  }

  Widget _buildInformation(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Home List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isEditingHomeList)
              GestureDetector(
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                onTap: () => setState(() {
                  isEditingHomeList = false;
                }),
              )
            else ...[
              GestureDetector(
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                onTap: () => showAddHomeAlertDialog(),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                onTap: () => setState(() {
                  isEditingHomeList = true;
                }),
              )
            ]
          ],
        ),
        const SizedBox(height: 8),
        ...homes
            .map<Widget>(
              (home) => GestureDetector(
                onTap: () {
                  if (isEditingHomeList) return;

                  setState(() {
                    currentHome = home;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        home.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (isEditingHomeList) ...[
                        const Spacer(),
                        GestureDetector(
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () =>
                              showEditHomeAlertDialog(context, home: home),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () => _removeHome(
                            context,
                            homeId: home.homeId,
                          ),
                        ),
                      ],
                      if (home.homeId == currentHome?.homeId &&
                          !isEditingHomeList) ...[
                        const Spacer(),
                        const Text(
                          'Current Home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            )
            .intersperse(const SizedBox(height: 12))
            .toList(),
      ],
    );
  }

  //MARK: AlertDialog

  void showEditAccountAlertDialog() {
    final controller = TextEditingController(text: widget.user.nickname);

    AlertDialogConvenienceShowing.showAlertDialog(
      context: context,
      title: 'Edit Account',
      inputField: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nickname')),
      actions: [
        AlertAction('Cancel'),
        AlertAction('Edit', onPressed: () {
          _updateNickname(context, nickname: controller.text);
        }),
      ],
    );
  }

  void showAddHomeAlertDialog() {
    final nameController = TextEditingController();
    final roomController = TextEditingController();

    AlertDialogConvenienceShowing.showAlertDialog(
      context: context,
      title: 'Add Home',
      inputField: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Home Name'),
          ),
          TextField(
            controller: roomController,
            decoration: const InputDecoration(
              labelText: 'Rooms',
              helperText: 'ex: room1, room2, room3',
            ),
          ),
        ],
      ),
      actions: [
        AlertAction('Cancel'),
        AlertAction('Add', onPressed: () {
          _addHome(
            name: nameController.text,
            rooms: roomController.text.split(',').map((e) => e.trim()).toList(),
          );
        }),
      ],
    );
  }

  void showEditHomeAlertDialog(BuildContext context, {required Home home}) {
    final nameController = TextEditingController(text: home.name);

    AlertDialogConvenienceShowing.showAlertDialog(
      context: context,
      title: 'Edit Home',
      inputField: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Home Name'),
          ),
        ],
      ),
      actions: [
        AlertAction('Cancel'),
        AlertAction('Edit', onPressed: () {
          _editHome(
            homeId: home.homeId,
            name: nameController.text,
          );
        }),
      ],
    );
  }

  //MARK: Repository

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

  Future<void> _fetchHomes() async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      final homes = await repository.fetchHomes();

      setState(() {
        this.homes = homes;
        currentHome = homes.firstOrNull;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }

  Future<void> _addHome({
    required String name,
    required List<String> rooms,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      final homeId = await repository.addHome(
        name: name,
        rooms: rooms,
        location: project.name,
        latitude: project.latitude,
        longitude: project.longitude,
      );

      setState(() {
        homes = homes..add(Home(homeId: homeId, name: name));
        currentHome = homes.firstOrNull;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }

  Future<void> _editHome({
    required String homeId,
    required String name,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      await repository.editHome(
        homeId: homeId,
        name: name,
        location: project.name,
        latitude: project.latitude,
        longitude: project.longitude,
      );

      _fetchHomes();
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }

  Future<void> _removeHome(
    BuildContext context, {
    required String homeId,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();

    try {
      await repository.removeHome(homeId: homeId);

      _fetchHomes();
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    }
  }
}
