import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_flutter_smart_lift_sdk/action_sheet.dart' as action_sheet;
import 'package:poc_flutter_smart_lift_sdk/alert_dialog_cubit.dart';
import 'package:poc_flutter_smart_lift_sdk/extensions/alert_dialog_convenience_showing.dart';
import 'package:poc_flutter_smart_lift_sdk/pages/login_page.dart';
import 'package:poc_flutter_smart_lift_sdk/repositories/tuya_repository.dart';

void main() {
  const methodChannel = MethodChannel(
    'com.code-app/poc-smart-lift-sdk-flutter',
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TuyaRepository>(
          create: (context) => TuyaRepository(methodChannel: methodChannel),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AlertDialogCubit>(
            create: (context) => AlertDialogCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MultiBlocListener(
            listeners: [
              BlocListener<AlertDialogCubit, AlertData?>(
                listener: (context, state) {
                  if (state == null) return;
                  _showAlertFromData(context, data: state);
                },
              ),
            ],
            child: const LoginPage(),
          ),
        ),
      ),
    ),
  );
}

void _showAlertFromData(
  BuildContext context, {
  required AlertData data,
}) {
  if (data is DialogData) {
    AlertDialogConvenienceShowing.showAlertDialog(
      context: context,
      title: data.title,
      message: data.message,
      remark: data.remark,
      actions: data.actions,
      onDismissed: data.onDismissed,
      dismissible: data.dismissible,
    );
  } else if (data is ActionSheetData) {
    action_sheet.ActionSheet(
      title: data.title,
      message: data.message,
      actions: data.actions
          .map(
            (action) => action_sheet.Action(
              action.title,
              () => action.onPressed?.call(),
              style: action.style,
            ),
          )
          .toList(),
      cancel: action_sheet.Action(
        data.cancelAction.title,
        () => data.cancelAction.onPressed?.call(),
      ),
    ).show(context);
  }
}
