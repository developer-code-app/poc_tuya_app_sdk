package com.example.poc_flutter_smart_lift_sdk

import android.app.Application
import com.thingclips.smart.home.sdk.ThingHomeSdk

class BaseApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        ThingHomeSdk.init(this)
        ThingHomeSdk.setDebugMode(true)
    }

    override fun onTerminate() {
        super.onTerminate()

        ThingHomeSdk.onDestroy()
    }
}