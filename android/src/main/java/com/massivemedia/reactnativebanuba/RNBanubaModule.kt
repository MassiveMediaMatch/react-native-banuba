package com.massivemedia.reactnativebanuba

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.banuba.sdk.cameraui.domain.MODE_RECORD_VIDEO
import com.banuba.sdk.ve.flow.VideoCreationActivity
import com.banuba.sdk.veui.ui.EXTRA_EXPORTED_SUCCESS
import com.banuba.sdk.veui.ui.ExportResult
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter


class RNBanubaModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), ActivityEventListener {

    override fun getName() = "RNBanubaModule"

    override fun getConstants(): MutableMap<String, Any> {
        return hashMapOf()
    }

    
    @ReactMethod
    fun startEditor(promise: Promise) {
        val intent = VideoCreationActivity.buildIntent(
                reactApplicationContext,
                // setup what kind of action you want to do with VideoCreationActivity
                MODE_RECORD_VIDEO,
                // setup data that will be acceptable during export flow
                null,
                // set TrackData object if you open VideoCreationActivity with preselected music track
                null
        )
        reactApplicationContext.addActivityEventListener(this)
        reactApplicationContext.startActivityForResult(intent, 1, null);
        promise.resolve(true)
    }

    override fun onNewIntent(intent: Intent?) {}

    override fun onActivityResult(activity: Activity?, requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1 && resultCode == Activity.RESULT_OK && data !== null ) {
            var bundle:ExportResult.Success = data.getParcelableExtra(EXTRA_EXPORTED_SUCCESS)
            var videoUrls = bundle.videoList.map { video -> video.fileUri.toString() }

            val map = Arguments.createMap()
            map.putString("preview", bundle.preview.toString())
            map.putArray("urls", Arguments.fromArray(videoUrls.toTypedArray()))
            reactApplicationContext
                    .getJSModule(RCTDeviceEventEmitter::class.java)
                    .emit("BANUBA_SUCCESS", null)
        }
    }
}
