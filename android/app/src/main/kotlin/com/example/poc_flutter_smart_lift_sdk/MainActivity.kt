package com.example.poc_flutter_smart_lift_sdk

import android.content.ContentValues.TAG
import android.util.Log
import androidx.annotation.NonNull
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.api.IReNickNameCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.builder.ActivatorBuilder
import com.thingclips.smart.home.sdk.builder.ThingGwActivatorBuilder
import com.thingclips.smart.home.sdk.builder.ThingGwSubDevActivatorBuilder
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.sdk.api.*
import com.thingclips.smart.sdk.bean.DeviceBean
import com.thingclips.smart.sdk.enums.ActivatorModelEnum
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.code-app/poc-smart-lift-sdk-flutter"

    private var thingActivator: IThingActivator? = null

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
                "fetchDevices" -> fetchDevices(call, result)
                "editDevice" -> editDevice(call, result)
                "removeDevice" -> removeDevice(call, result)
                "fetchPairingToken" -> fetchPairingToken(call, result)
                "startPairingDeviceWithEZMode" -> startPairingDeviceWithEZMode(call, result)
                "startPairingDeviceWithAPMode" -> startPairingDeviceWithAPMode(call, result)
                "startPairingDeviceWithZigbeeGateway" -> startPairingDeviceWithZigbeeGateway(call, result)
                "startPairingDeviceWithSubDevices" -> startPairingDeviceWithSubDevices(call, result)
                "stopPairingDevice" -> stopPairingDevice(call, result)
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
                        "home_id" to home.homeId.toString(),
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

    private fun fetchDevices(call: MethodCall, result: MethodChannel.Result) {
        val homeId = call.argument<String>("home_id")?.toLongOrNull()

        if (homeId != null) {
            ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(object : IThingHomeResultCallback {
                override fun onSuccess(bean: HomeBean?) {
                    val devices = bean?.deviceList ?: listOf()
                    result.success(
                        devices.map { device ->
                            hashMapOf(
                                "device_id" to device.devId,
                                "name" to device.getName(),
                                "is_zig_bee_wifi" to device.isZigBeeWifi,
                            )
                        }
                    )
                }

                override fun onError(errorCode: String?, error: String?) {
                    result.error(
                        errorCode ?: "HONE_NOT_FOUND",
                        error,
                        null
                    )
                }
            })
//            val devices = ThingHomeSdk.newHomeInstance(homeId).homeBean?.let { home -> home.deviceList } ?: listOf()
//
//            result.success(
//                devices.map { device ->
//                    val roomName = ThingHomeSdk.getDataInstance().getDeviceRoomBean(device.getDevId())?.name ?: ""
//
//                    hashMapOf(
//                        "device_id" to device.devId,
//                        "name" to device.getName(),
//                        "room_name" to roomName,
//                    )
//                }
//            )
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }

    private fun editDevice(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("device_id")
        val name = call.argument<String>("name")

        if (deviceId != null && name != null) {
            val device = ThingHomeSdk.newDeviceInstance(deviceId)

            device.renameDevice(name, object : IResultCallback {
                override fun onError(code: String, error: String) {
                    result.error(
                        code,
                        error,
                        null
                    )
                }

                override fun onSuccess() {
                    result.success("SUCCESS")
                    // The device is renamed successfully.
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
    private fun removeDevice(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("device_id")


        if (deviceId != null) {
            val device = ThingHomeSdk.newDeviceInstance(deviceId)

            device.removeDevice(object : IResultCallback {
                override fun onError(errorCode: String, errorMsg: String) {
                    result.error(
                        errorCode,
                        errorMsg,
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

    private fun fetchPairingToken(call: MethodCall, result: MethodChannel.Result) {
        val homeId = call.argument<String>("home_id")?.toLongOrNull()

        if (homeId != null) {
            ThingHomeSdk.getActivatorInstance().getActivatorToken(homeId,
                object : IThingActivatorGetToken {
                    override fun onSuccess(token: String) {
                        result.success(token)
                    }

                    override fun onFailure(s: String, s1: String) {
                        result.error(s, s1, null)
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

    private fun startPairingDeviceWithEZMode(call: MethodCall, result: MethodChannel.Result) {
        val ssid = call.argument<String>("ssid") ?: ""
        val password = call.argument<String>("password") ?: ""
        val token = call.argument<String>("token") ?: ""
        val timeOut = call.argument<Int?>("time_out")?.toLong() ?: 200

        if (ssid.isNotEmpty() && password.isNotEmpty() && token.isNotEmpty()) {
            val builder = ActivatorBuilder()
                .setContext(this)
                .setSsid(ssid)
                .setPassword(password)
                .setToken(token)
                .setActivatorModel(ActivatorModelEnum.THING_EZ)
                .setTimeOut(timeOut)
                .setListener(object : IThingSmartActivatorListener {
                    override fun onStep(step: String?, data: Any?) {
                        Log.i(TAG, "$step --> $data")
                    }

                    override fun onActiveSuccess(devResp: DeviceBean?) {
                        result.success(devResp?.devId)
                    }

                    override fun onError(errorCode: String?, errorMsg: String?) {
                        result.error(
                            errorCode ?: "PAIRING_DEVICE_ERROR",
                            errorMsg,
                            null
                        )
                    }
                })

            thingActivator = ThingHomeSdk.getActivatorInstance().newMultiActivator(builder)
            thingActivator?.start()
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }

    private fun startPairingDeviceWithAPMode(call: MethodCall, result: MethodChannel.Result) {
        val ssid = call.argument<String>("ssid") ?: ""
        val password = call.argument<String>("password") ?: ""
        val token = call.argument<String>("token") ?: ""
        val timeOut = call.argument<Int?>("time_out")?.toLong() ?: 200

        if (ssid.isNotEmpty() && password.isNotEmpty() && token.isNotEmpty()) {
            val builder =  ActivatorBuilder()
                .setContext(context)
                .setSsid(ssid)
                .setPassword(password)
                .setActivatorModel(ActivatorModelEnum.THING_AP)
                .setTimeOut(timeOut)
                .setToken(token)
                .setListener(object : IThingSmartActivatorListener {
                    override fun onError(errorCode: String, errorMsg: String) {
                        result.error(
                            errorCode,
                            errorMsg,
                            null
                        )
                    }

                    override fun onActiveSuccess(devResp: DeviceBean?) {
                        result.success("SUCCESS")
                    }

                    override fun onStep(step: String?, data: Any?) {
                        Log.i(TAG, "$step --> $data")
                    }
                })

            thingActivator = ThingHomeSdk.getActivatorInstance().newActivator(builder)
            thingActivator?.start()
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }

    private fun startPairingDeviceWithZigbeeGateway(call: MethodCall, result: MethodChannel.Result) {
        val token = call.argument<String>("token") ?: ""
        val timeOut = call.argument<Int?>("time_out")?.toLong() ?: 200

        if (token.isNotEmpty()) {
            val thingGwSearcher = ThingHomeSdk.getActivatorInstance().newThingGwActivator().newSearcher()

            thingGwSearcher.registerGwSearchListener { hgwBean ->
                val build = ThingGwActivatorBuilder()
                    .setToken(token)
                    .setTimeOut(timeOut)
                    .setContext(context)
                    .setHgwBean(hgwBean)
                    .setListener(object : IThingSmartActivatorListener {
                        override fun onError(errorCode: String, errorMsg: String) {
                            result.error(
                                errorCode,
                                errorMsg,
                                null
                            )
                        }

                        override fun onActiveSuccess(devResp: DeviceBean) {
                            result.success("SUCCESS")
                        }

                        override fun onStep(step: String, data: Any) {
                            Log.i(TAG, "$step --> $data")
                        }
                    })

                thingActivator = ThingHomeSdk.getActivatorInstance().newGwActivator(build)
                thingActivator?.start()
            }
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }

    private fun startPairingDeviceWithSubDevices(call: MethodCall, result: MethodChannel.Result) {
        val gatewayId = call.argument<String>("gateway_id") ?: ""
        val timeOut = call.argument<Int?>("time_out")?.toLong() ?: 200

        if (gatewayId.isNotEmpty()) {
            val builder = ThingGwSubDevActivatorBuilder()
                .setDevId(gatewayId)
                .setTimeOut(timeOut)
                .setListener(object : IThingSmartActivatorListener {
                    override fun onError(errorCode: String?, errorMsg: String?) {
                        result.error(
                            errorCode ?: "PAIRING_DEVICE_ERROR",
                            errorMsg,
                            null
                        )
                    }

                    override fun onActiveSuccess(devResp: DeviceBean?) {
                        result.success("SUCCESS")
                    }

                    override fun onStep(step: String?, data: Any?) {
                        Log.i(TAG, "$step --> $data")
                    }
                })

            thingActivator = ThingHomeSdk.getActivatorInstance().newGwSubDevActivator(builder)
            thingActivator?.start()
        } else {
            result.error(
                "ARGUMENTS_ERROR",
                "Arguments missing.",
                null
            )
        }
    }

    private fun stopPairingDevice(call: MethodCall, result: MethodChannel.Result) {
        thingActivator?.stop()
        result.success("SUCCESS")
    }
}
