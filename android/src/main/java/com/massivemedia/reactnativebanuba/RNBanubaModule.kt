package com.massivemedia.reactnativebanuba

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import com.banuba.sdk.cameraui.domain.MODE_RECORD_VIDEO
import com.banuba.sdk.ve.flow.VideoCreationActivity
import com.banuba.sdk.veui.ui.EXTRA_EXPORTED_SUCCESS
import com.banuba.sdk.veui.ui.ExportResult
import com.facebook.react.bridge.*


class RNBanubaModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), ActivityEventListener {

    private val cache: PromiseCache = PromiseCache()

    override fun getName() = "RNBanubaModule"

    override fun getConstants(): MutableMap<String, Any> {
        return hashMapOf()
    }

    @ReactMethod
    fun setTokens(videoEditorToken: String, effectToken: String) {
        val sharedPref = currentActivity?.getSharedPreferences("banuba",Context.MODE_PRIVATE)
        var editor = sharedPref?.edit()
        editor?.putString("banuba_video_editor_token",videoEditorToken)
        editor?.putString("banuba_effect_token",effectToken)
        editor?.apply()
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
        cache.putPromise("result", promise)
    }

    override fun onNewIntent(intent: Intent?) {}

    override fun onActivityResult(activity: Activity?, requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1) {
            if (resultCode == Activity.RESULT_OK && data !== null) {
                var bundle: ExportResult.Success = data.getParcelableExtra(EXTRA_EXPORTED_SUCCESS)
                val map = Arguments.createMap()
                map.putString("preview", bundle.preview.toString())
                map.putString("url", bundle.videoList[1].fileUri.toString())
                if (cache.hasPromise("result")) {
                    cache.resolvePromise("result", map)
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                if (cache.hasPromise("result")) {
                    cache.rejectPromise("result", "canceled")
                }
            } else {
                if (cache.hasPromise("result")) {
                    cache.rejectPromise("result", "banuba error")
                }
            }

        }
    }
}
