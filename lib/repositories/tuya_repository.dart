import 'package:flutter/services.dart';
import 'package:poc_flutter_smart_lift_sdk/models/device.dart';
import 'package:poc_flutter_smart_lift_sdk/models/home.dart';
import 'package:poc_flutter_smart_lift_sdk/models/user.dart';

class TuyaRepository {
  TuyaRepository({required this.methodChannel});

  final MethodChannel methodChannel;

  Future<User> loginWithEmail({
    required String countryCode,
    required String email,
    required String password,
  }) async {
    final argument = {
      'country_code': countryCode,
      'email': email,
      'password': password,
    };

    return await methodChannel
        .invokeMethod('loginWithEmail', argument)
        .then((response) => User.fromMap(response));
  }

  Future<void> updateNickname({required String nickname}) async {
    final argument = {
      'nickname': nickname,
    };

    return await methodChannel.invokeMethod('updateNickname', argument);
  }

  Future<void> logout() async {
    return await methodChannel.invokeMethod('logout');
  }

  Future<List<Home>> fetchHomes() async {
    return await methodChannel.invokeMethod<List>('fetchHomes').then(
        (response) =>
            response?.map((home) => Home.fromMap(home)).toList() ?? []);
  }

  Future<String> addHome({
    required String name,
    required List<String> rooms,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final argument = {
      'name': name,
      'rooms': rooms,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };

    return await methodChannel
        .invokeMethod('addHome', argument)
        .then((response) => response.toString());
  }

  Future<String> editHome({
    required String homeId,
    required String name,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final argument = {
      'home_id': homeId,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };

    return await methodChannel
        .invokeMethod('editHome', argument)
        .then((response) => response.toString());
  }

  Future<void> removeHome({required String homeId}) async {
    final argument = {
      'home_id': homeId,
    };

    return await methodChannel.invokeMethod('removeHome', argument);
  }

  Future<List<Device>> fetchDevices({required String homeId}) async {
    final argument = {
      'home_id': homeId,
    };

    return await methodChannel
        .invokeMethod<List>('fetchDevices', argument)
        .then((response) =>
            response?.map((device) => Device.fromMap(device)).toList() ?? []);
  }

  Future<String> editDevice({
    required String deviceId,
    required String name,
  }) async {
    final argument = {
      'device_id': deviceId,
      'name': name,
    };

    return await methodChannel
        .invokeMethod('editDevice', argument)
        .then((response) => response.toString());
  }

  Future<void> removeDevice({required String deviceId}) async {
    final argument = {
      'device_id': deviceId,
    };

    return await methodChannel.invokeMethod('removeDevice', argument);
  }

  Future<String> fetchPairingToken({required String homeId}) async {
    final argument = {
      'home_id': homeId,
    };

    return await methodChannel.invokeMethod('fetchPairingToken', argument);
  }

  Future<String> startPairingDeviceWithEZMode({
    required String ssid,
    required String password,
    required String token,
  }) async {
    final argument = {
      'ssid': ssid,
      'password': password,
      'token': token,
    };

    return await methodChannel.invokeMethod(
      'startPairingDeviceWithEZMode',
      argument,
    );
  }

  Future<String> startPairingDeviceWithAPMode({
    required String ssid,
    required String password,
    required String token,
  }) async {
    final argument = {
      'ssid': ssid,
      'password': password,
      'token': token,
    };

    return await methodChannel.invokeMethod(
      'startPairingDeviceWithAPMode',
      argument,
    );
  }

  Future<String> startPairingDeviceWithZigbeeGateway({
    required String token,
  }) async {
    final argument = {
      'token': token,
    };

    return await methodChannel.invokeMethod(
      'startPairingDeviceWithZigbeeGateway',
      argument,
    );
  }

  Future<String> startPairingDeviceWithSubDevices({
    required String gatewayId,
  }) async {
    final argument = {
      'gateway_id': gatewayId,
    };

    return await methodChannel.invokeMethod(
      'startPairingDeviceWithSubDevices',
      argument,
    );
  }

  Future<void> stopPairingDevice() async {
    return await methodChannel.invokeMethod('stopPairingDevice');
  }
}
