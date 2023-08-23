import 'package:flutter/material.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/login_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const LoginPage(),
  ));
}
