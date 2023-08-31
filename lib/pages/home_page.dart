// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/ui_blocking_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/extensions/alert_dialog_convenience_showing.dart';
import 'package:poc_flutter_smart_lift_sdk/loading_with_blocking_widget.dart';
import 'package:poc_flutter_smart_lift_sdk/models/device.dart';
import 'package:poc_flutter_smart_lift_sdk/models/home.dart';
import 'package:poc_flutter_smart_lift_sdk/models/project.dart';
import 'package:poc_flutter_smart_lift_sdk/models/user.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/device_adding_ap_mode.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/device_adding_ez_mode.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/device_adding_zigbee_gateway.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/device_adding_zigbee_subdevice.dart';
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

  Home? currentHome;

  bool isEditingHomeList = false;
  List<Home> homes = [];

  bool isEditingDeviceList = false;
  List<Device> devices = [];

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
      body: LoadingWithBlockingWidget(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),
            _buildAccountSection(context),
            const Divider(height: 32),
            _buildHomeListSection(context),
            const Divider(height: 32),
            _buildDeviceListSection(context),
            const Divider(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Poc Smart Lift SDK'),
      automaticallyImplyLeading: false,
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

                  _fetchDevices(homeId: home.homeId);
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
                          onTap: () => _removeHome(homeId: home.homeId),
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

  Widget _buildDeviceListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Device List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isEditingDeviceList)
              GestureDetector(
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                onTap: () => setState(() {
                  isEditingDeviceList = false;
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
                onTap: () => showAddDeviceAlertDialog(context),
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
                  isEditingDeviceList = true;
                }),
              )
            ]
          ],
        ),
        const SizedBox(height: 8),
        ...devices
            .map<Widget>(
              (device) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      if (isEditingDeviceList) ...[
                        const Spacer(),
                        GestureDetector(
                          child: const Text(
                            'Rename',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () => showEditDeviceAlertDialog(context,
                              device: device),
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
                          onTap: () => _removeDevice(deviceId: device.deviceId),
                        ),
                      ],
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

  void showEditDeviceAlertDialog(
    BuildContext context, {
    required Device device,
  }) {
    final nameController = TextEditingController(text: device.name);

    AlertDialogConvenienceShowing.showAlertDialog(
      context: context,
      title: 'Edit Device',
      inputField: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Device Name'),
          ),
        ],
      ),
      actions: [
        AlertAction('Cancel'),
        AlertAction('Edit', onPressed: () {
          _editDevice(
            deviceId: device.deviceId,
            name: nameController.text,
          );
        }),
      ],
    );
  }

  void showAddDeviceAlertDialog(BuildContext context) {
    final alertDialogCubit = context.read<AlertDialogCubit>();

    alertDialogCubit.alertActionSheet(
      title: 'Device Adding',
      actions: [
        AlertAction(
          'Wi-Fi, EZ Mode',
          onPressed: () => navigationToDeviceAddingEZMode(),
        ),
        AlertAction(
          'Wi-Fi, AP Mode',
          onPressed: () => navigationToDeviceAddingAPMode(),
        ),
        AlertAction(
          'Zigbee Gateway',
          onPressed: () => navigationToDeviceAddingZigbeeGateway(),
        ),
        AlertAction(
          'Zigbee Subdevice',
          onPressed: () => navigationToDeviceAddingZigbeeSubdevice(),
        )
      ],
    );
  }

  void navigationToDeviceAddingEZMode() async {
    final home = currentHome;

    if (home != null) {
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceAddingEZMode(
            homeId: home.homeId,
            onAdded: () async {
              await Future.delayed(const Duration(seconds: 1));
              _fetchDevices(homeId: home.homeId);
            },
          ),
        ),
      );
    }
  }

  void navigationToDeviceAddingAPMode() async {
    final home = currentHome;

    if (home != null) {
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceAddingAPMode(
            homeId: home.homeId,
            onAdded: () async {
              await Future.delayed(const Duration(seconds: 1));
              _fetchDevices(homeId: home.homeId);
            },
          ),
        ),
      );
    }
  }

  void navigationToDeviceAddingZigbeeGateway() async {
    final home = currentHome;

    if (home != null) {
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceAddingZigbeeGateway(
            homeId: home.homeId,
            onAdded: () async {
              await Future.delayed(const Duration(seconds: 1));
              _fetchDevices(homeId: home.homeId);
            },
          ),
        ),
      );
    }
  }

  void navigationToDeviceAddingZigbeeSubdevice() async {
    final home = currentHome;
    final gatewayId =
        devices.firstWhereOrNull((element) => element.isZigBeeWifi)?.deviceId;

    if (home != null && gatewayId != null) {
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceAddingZigbeeSubdevice(
            gatewayId: gatewayId,
            onAdded: () async {
              await Future.delayed(const Duration(seconds: 1));
              _fetchDevices(homeId: home.homeId);
            },
          ),
        ),
      );
    }
  }
  //MARK: Repository

  Future<void> _updateNickname(
    BuildContext context, {
    required String nickname,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.updateNickname(nickname: nickname);

      setState(() {
        widget.user.nickname = nickname;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _logout(BuildContext context) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.logout();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _fetchHomes() async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      final homes = await repository.fetchHomes();

      setState(() {
        this.homes = homes;
        currentHome = homes.firstOrNull;
      });

      currentHome?.let((home) => _fetchDevices(homeId: home.homeId));
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _addHome({
    required String name,
    required List<String> rooms,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.addHome(
        name: name,
        rooms: rooms,
        location: project.name,
        latitude: project.latitude,
        longitude: project.longitude,
      );

      _fetchHomes();
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _editHome({
    required String homeId,
    required String name,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

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
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _removeHome({required String homeId}) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.removeHome(homeId: homeId);

      _fetchHomes();
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _fetchDevices({required String homeId}) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      final devices = await repository.fetchDevices(homeId: homeId);

      setState(() {
        this.devices = devices;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _editDevice({
    required String deviceId,
    required String name,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.editDevice(
        deviceId: deviceId,
        name: name,
      );

      currentHome?.let((home) => _fetchDevices(homeId: home.homeId));
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> _removeDevice({required String deviceId}) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.removeDevice(deviceId: deviceId);

      currentHome?.let((home) => _fetchDevices(homeId: home.homeId));
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }
}
