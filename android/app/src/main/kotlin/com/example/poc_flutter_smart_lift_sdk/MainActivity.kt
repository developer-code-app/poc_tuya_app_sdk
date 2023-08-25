package com.example.poc_flutter_smart_lift_sdk

import androidx.annotation.NonNull
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
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
        val countryCode = call.argument<String>("country_code")
        val account = call.argument<String>("email")
        val password = call.argument<String>("password")
        val callback =  object : ILoginCallback {
            override fun onSuccess(user: User?) {
                result.success("Success")
            }

            override fun onError(code: String?, error: String?) {
                result.error(
                    "LOGIN_ERROR",
                    error,
                    null
                )
            }
        }

        if (countryCode != null && account != null && password != null) {
            ThingHomeSdk.getUserInstance().loginWithEmail(
                countryCode,
                account,
                password,
                callback
            )
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }
}
