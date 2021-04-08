package com.massivemedia.reactnativebanuba.videoeditor.di

import android.util.Log
import com.banuba.sdk.arcloud.data.source.ArEffectsRepositoryProvider
import com.banuba.sdk.audiobrowser.domain.AudioBrowserMusicProvider
import com.banuba.sdk.cameraui.data.CameraRecordingAnimationProvider
import com.banuba.sdk.cameraui.data.CameraTimerStateProvider
import com.banuba.sdk.core.AREffectPlayerProvider
import com.banuba.sdk.core.SimpleEffectPlayerManager
import com.banuba.sdk.core.domain.TrackData
import com.banuba.sdk.core.ui.ContentFeatureProvider
import com.banuba.sdk.effectplayer.adapter.BanubaAREffectPlayerProvider
import com.banuba.sdk.token.storage.TokenProvider
import com.banuba.sdk.ve.effects.EditorEffects
import com.banuba.sdk.ve.effects.WatermarkProvider
import com.banuba.sdk.ve.flow.ExportFlowManager
import com.banuba.sdk.ve.flow.FlowEditorModule
import com.banuba.sdk.ve.flow.export.ForegroundExportFlowManager
import com.banuba.sdk.veui.data.ExportParamsProvider
import com.banuba.sdk.veui.domain.CoverProvider
import com.massivemedia.reactnativebanuba.R
import com.massivemedia.reactnativebanuba.videoeditor.data.TimeEffects
import com.massivemedia.reactnativebanuba.videoeditor.data.VisualEffects
import com.massivemedia.reactnativebanuba.videoeditor.export.IntegrationAppExportParamsProvider
import com.massivemedia.reactnativebanuba.videoeditor.impl.IntegrationAppRecordingAnimationProvider
import com.massivemedia.reactnativebanuba.videoeditor.impl.IntegrationAppWatermarkProvider
import com.massivemedia.reactnativebanuba.videoeditor.impl.IntegrationTimerStateProvider
import org.koin.android.ext.koin.androidContext
import org.koin.core.definition.BeanDefinition
import org.koin.core.qualifier.named

/**
 * All dependencies mentioned in this module will override default
 * implementations provided from SDK.
 * Some dependencies has no default implementations. It means that
 * these classes fully depends on your requirements
 */
class VideoEditorKoinModule : FlowEditorModule() {

    override val exportFlowManager: BeanDefinition<ExportFlowManager> = single(override = true) {
        ForegroundExportFlowManager(
                exportDataProvider = get(),
                editorSessionHelper = get(),
                exportDir = get(named("exportDir")),
                mediaFileNameHelper = get(),
                shouldClearSessionOnFinish = true
        )
    }

    /**
     * Provides params for export
     * */
    override val exportParamsProvider: BeanDefinition<ExportParamsProvider> =
            factory(override = true) {
                IntegrationAppExportParamsProvider(
                        exportDir = get(named("exportDir")),
                        sizeProvider = get(),
                        watermarkBuilder = get()
                )
            }

    override val watermarkProvider: BeanDefinition<WatermarkProvider> = factory(override = true) {
        IntegrationAppWatermarkProvider()
    }

    override val editorEffects: BeanDefinition<EditorEffects> = single(override = true) {
        val visualEffects = listOf(
                VisualEffects.VHS,
                VisualEffects.Rave
        )
        val timeEffects = listOf(
                TimeEffects.SlowMo(),
                TimeEffects.Rapid()
        )

        EditorEffects(
                visual = visualEffects,
                time = timeEffects,
                equalizer = emptyList()
        )
    }

    /**
     * Provides camera record button animation
     * */
    override val cameraRecordingAnimationProvider: BeanDefinition<CameraRecordingAnimationProvider> =
            factory(override = true) {
                IntegrationAppRecordingAnimationProvider(context = get())
            }

    override val cameraTimerStateProvider: BeanDefinition<CameraTimerStateProvider> =
            factory(override = true) {
                IntegrationTimerStateProvider()
            }

    override val musicTrackProvider: BeanDefinition<ContentFeatureProvider<TrackData>> =
            single(named("musicTrackProvider"), override = true) {
                AudioBrowserMusicProvider()
            }

    override val coverProvider: BeanDefinition<CoverProvider> = single(override = true) {
        CoverProvider.EXTENDED
    }

    override val effectPlayerManager: BeanDefinition<AREffectPlayerProvider> = single(override = true) {
        SimpleEffectPlayerManager(
                mediaSizeProvider = get(),
                token = RemoteTokenProvider().getToken()
        )
    }
}
