import 'package:flutter/services.dart';
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
}
