// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/cubit/ui_blocking_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/loading_with_blocking_widget.dart';
import 'package:poc_flutter_smart_lift_sdk/repositories/tuya_repository.dart';

class DeviceAddingZigbeeSubdevice extends StatefulWidget {
  const DeviceAddingZigbeeSubdevice({
    required this.gatewayId,
    required this.onAdded,
    super.key,
  });

  final String gatewayId;
  final void Function() onAdded;

  @override
  State<DeviceAddingZigbeeSubdevice> createState() =>
      _DeviceAddingZigbeeSubdeviceState();
}

class _DeviceAddingZigbeeSubdeviceState
    extends State<DeviceAddingZigbeeSubdevice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zigbee Sub-devices'),
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
            TextButton(
              child: const Text('Search'),
              onPressed: () => startPairingDeviceWithSubDevices(
                gatewayId: widget.gatewayId,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> startPairingDeviceWithSubDevices({
    required String gatewayId,
  }) async {
    final repository = context.read<TuyaRepository>();
    final alertDialogCubit = context.read<AlertDialogCubit>();
    final uiBlockingCubit = context.read<UIBlockingCubit>();

    uiBlockingCubit.block();

    try {
      await repository.startPairingDeviceWithSubDevices(gatewayId: gatewayId);

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
