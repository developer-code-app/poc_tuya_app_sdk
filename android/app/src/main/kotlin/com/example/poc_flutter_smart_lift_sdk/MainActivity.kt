package com.example.poc_flutter_smart_lift_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.code-app/poc-smart-lift-sdk-flutter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "loginWithEmail" -> loginWithEmail(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun loginWithEmail(call: MethodCall, result: MethodChannel.Result) {
        print("login smart lift sdk");
    }
}
