package com.massivemedia.reactnativebanuba

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule

import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import com.banuba.sdk.effectplayer.adapter.BanubaEffectPlayerKoinModule
import com.banuba.sdk.token.storage.TokenStorageKoinModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import com.massivemedia.reactnativebanuba.videoeditor.di.VideoEditorKoinModule
import com.facebook.react.bridge.ReactMethod
import com.banuba.sdk.cameraui.domain.MODE_RECORD_VIDEO
import com.banuba.sdk.ve.flow.VideoCreationActivity
import org.koin.core.context.KoinContextHandler

class RNBanubaModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName() = "RNBanubaModule"

    override fun getConstants(): MutableMap<String, Any> {
        return hashMapOf()
    }

    
    @ReactMethod
    fun startEditor() {
        val intent = VideoCreationActivity.buildIntent(
                reactApplicationContext,
                // setup what kind of action you want to do with VideoCreationActivity
                MODE_RECORD_VIDEO,
                // setup data that will be acceptable during export flow
                null,
                // set TrackData object if you open VideoCreationActivity with preselected music track
                null
        )
        reactApplicationContext.startActivityForResult(intent, 1, null);
    }

    @Override
    fun onHostDestroy() {
        KoinContextHandler.stop()
    }
}
