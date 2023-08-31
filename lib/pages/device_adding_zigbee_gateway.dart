// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/ui_blocking_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/loading_with_blocking_widget.dart';
import 'package:poc_flutter_smart_lift_sdk/repositories/tuya_repository.dart';

class DeviceAddingZigbeeGateway extends StatefulWidget {
  const DeviceAddingZigbeeGateway({
    required this.homeId,
    required this.onAdded,
    super.key,
  });

  final String homeId;
  final void Function() onAdded;

  @override
  State<DeviceAddingZigbeeGateway> createState() =>
      _DeviceAddingZigbeeGatewayState();
}

class _DeviceAddingZigbeeGatewayState extends State<DeviceAddingZigbeeGateway> {
  String token = "";

  @override
  void initState() {
    super.initState();

    fetchPairingToken(homeId: widget.homeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Adding Zigbee Gateway'),
      ),
      backgroundColor: Colors.blueGrey.shade50,
      body: LoadingWithBlockingWidget(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 24),
            const Text(
              'Tuya Pairing Date',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Token',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const Spacer(),
                Text(token),
              ],
            ),
            const Divider(),
            TextButton(
              child: const Text('Search'),
              onPressed: () =>
                  startPairingDeviceWithZigbeeGateway(token: token),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchPairingToken({required String homeId}) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      final token = await repository.fetchPairingToken(homeId: homeId);

      setState(() {
        this.token = token;
      });
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> startPairingDeviceWithZigbeeGateway({
    required String token,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.startPairingDeviceWithZigbeeGateway(token: token);

      Navigator.pop(context);
      widget.onAdded();
    } on Exception catch (error) {
      alertDialogCubit.errorAlert(error: error);
    } finally {
      uiBlockingCubit.unblock();
    }
  }

  Future<void> stopPairingDevice() async {
    final repository = context.read<TuyaRepository>();

    try {
      await repository.stopPairingDevice();
    } on Exception catch (error) {
      if (kDebugMode) {
        print('Stop pairing device error: ${error.toString()}');
      }
    }
  }
}
