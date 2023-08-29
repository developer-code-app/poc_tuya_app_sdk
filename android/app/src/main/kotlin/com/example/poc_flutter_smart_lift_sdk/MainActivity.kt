package com.example.poc_flutter_smart_lift_sdk

import androidx.annotation.NonNull
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.api.IReNickNameCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.sdk.api.IResultCallback
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
                "updateNickname" -> updateNickname(call, result)
                "logout" -> logout(call, result)
                "fetchHomes" -> fetchHomes(call, result)
                "addHome" -> addHome(call, result)
                "editHome" -> editHome(call, result)
                "removeHome" -> removeHome(call, result)
                else -> result.notImplemented()
            }
        }
    }


    private fun updateNickname(call: MethodCall, result: MethodChannel.Result) {
        val nickname = call.argument<String>("nickname")
        val callback =  object : IReNickNameCallback {
            override fun onSuccess() {
                result.success("SUCCESS")
            }

            override fun onError(code: String?, error: String?) {
                result.error(
                    "UPDATE_NICKNAME_ERROR",
                    error,
                    null
                )
            }
        }

        ThingHomeSdk.getUserInstance().updateNickName(nickname, callback)
    }
    private fun loginWithEmail(call: MethodCall, result: MethodChannel.Result) {
        val countryCode = call.argument<String>("country_code")
        val account = call.argument<String>("email")
        val password = call.argument<String>("password")
        val callback =  object : ILoginCallback {
            override fun onSuccess(user: User?) {
                if (user != null) {
                    result.success(
                        hashMapOf(
                            "user_id" to user.uid,
                            "session_id" to user.sid,
                            "user_name" to user.username,
                            "email" to user.email,
                            "nickname" to user.nickName
                        )
                    )
                } else {
                    result.success(null)
                }
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

    private fun logout(call: MethodCall, result: MethodChannel.Result) {
        ThingHomeSdk.getUserInstance().logout(object : ILogoutCallback {
            override fun onSuccess() {
                result.success("SUCCESS")
            }

            override fun onError(errorCode: String, errorMsg: String) {
                result.error(
                    errorCode,
                    errorMsg,
                    null
                )
            }
        })
    }

    private fun fetchHomes(call: MethodCall, result: MethodChannel.Result) {
        ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
            override fun onSuccess(homeBeans: List<HomeBean>) {
                val homes = homeBeans.map { home ->
                    hashMapOf(
                        "home_id" to home.homeId,
                        "name" to home.name,
                    )
                }

                result.success(homes)
            }

            override fun onError(errorCode: String, error: String) {
                result.error(
                    errorCode,
                    error,
                    null
                )
            }
        })

    }
    private fun addHome(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        val rooms = call.argument<List<String>>("rooms")
        val location = call.argument<String>("location")
        val latitude = call.argument<Double>("latitude")
        val longitude = call.argument<Double>("longitude")

        if (name != null && rooms != null && location != null && latitude != null && longitude != null) {
            ThingHomeSdk.getHomeManagerInstance()
                .createHome(name, longitude, latitude, location, rooms, object : IThingHomeResultCallback {
                    override fun onSuccess(bean: HomeBean) {
                        result.success(bean.homeId.toString())
                    }

                    override fun onError(errorCode: String, errorMsg: String) {
                        result.error(
                            errorCode,
                            errorMsg,
                            null
                        )
                    }
                })
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }
    private fun editHome(call: MethodCall, result: MethodChannel.Result) {
        val homeId = call.argument<String>("home_id")?.toLongOrNull()
        val name = call.argument<String>("name")
        val location = call.argument<String>("location")
        val latitude = call.argument<Double>("latitude")
        val longitude = call.argument<Double>("longitude")

        if (homeId != null && name != null && location != null && latitude != null && longitude != null) {
            ThingHomeSdk.newHomeInstance(homeId)
                .updateHome(name, longitude, latitude,location, object : IResultCallback {
                    override fun onError(code: String?, error: String?) {
                        result.error(
                            code ?: "EDIT_HOMES_ERROR",
                            error,
                            null
                        )
                    }

                    override fun onSuccess() {
                        result.success("SUCCESS")
                    }
                })
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }
    private fun removeHome(call: MethodCall, result: MethodChannel.Result) {
        val homeId = call.argument<String>("home_id")?.toLongOrNull()

        if (homeId != null) {
            ThingHomeSdk.newHomeInstance(homeId).dismissHome(object : IResultCallback {
                override fun onSuccess() {
                    result.success("SUCCESS")
                }

                override fun onError(code: String, error: String) {
                    result.error(
                        code ,
                        error,
                        null
                    )
                }
            })
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }
}
