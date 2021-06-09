package com.massivemedia.reactnativebanuba

import android.app.Application
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import com.banuba.sdk.audiobrowser.di.AudioBrowserKoinModule
import com.banuba.sdk.gallery.di.GalleryKoinModule
import com.banuba.sdk.token.storage.di.TokenStorageKoinModule
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.massivemedia.reactnativebanuba.videoeditor.di.VideoEditorKoinModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class RNBanubaPackage(application: Application) : ReactPackage {

    init {
        startKoin {
            androidContext(application)

            // pass the customized Koin module that implements required dependencies.
            modules(
                    AudioBrowserKoinModule().module, // use this module only if you bought it
                    ArCloudKoinModule().module,
                    TokenStorageKoinModule().module,
                    VideoEditorKoinModule().module,
                    GalleryKoinModule().module
            )
        }
    }

    override fun createViewManagers(reactContext: ReactApplicationContext):
            MutableList<ViewManager<*, *>> {
        return mutableListOf()
    }

    override fun createNativeModules(reactContext: ReactApplicationContext):
            MutableList<NativeModule> {
        return mutableListOf(RNBanubaModule(reactContext))
    }
}
