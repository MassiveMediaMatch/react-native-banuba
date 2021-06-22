//
//  RNBanubaModule.swift
//  RNBanubaModule
//
//  Copyright © 2021 MassiveMedia. All rights reserved.
//

import React
import UIKit
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK
import BanubaVideoEditorSDK

@objc(RNBanubaModule)
class RNBanubaModule: NSObject, RCTBridgeModule {
  
  private var videoEditorSDK: BanubaVideoEditor?
  private var resolver: RCTPromiseResolveBlock?
  private var rejecter: RCTPromiseRejectBlock?
  
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  // MARK: - RCTBridgeModule
  static func moduleName() -> String! {
    return "RNBanubaModule"
  }
  
  @objc func startEditorWithTokens(_ videoEditorToken:String, effectToken:String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    self.resolver = resolve
    self.rejecter = reject
    let config = createVideoEditorConfiguration()
    videoEditorSDK = BanubaVideoEditor(
      token: videoEditorToken,
      configuration: config
    )
    videoEditorSDK?.delegate = self
	
	// load asset if any is specified
//	let assetURL: String? = "/var/mobile/Containers/Data/Application/B6E03023-A4EF-4107-95DA-6DF60471E135/tmp/16178188-6689-4F55-865E-F3822CF1397A.MOV"
//	if (assetURL != nil) {
//		let videoURL = URL(fileURLWithPath: assetURL!)
//		if (videoURL != nil) {
//			videoEditorSDK?.asset = AVAsset(url: videoURL)
//		}
//	}
	
    DispatchQueue.main.async {
      guard let presentedVC = RCTPresentedViewController() else {
        return
      }
      self.videoEditorSDK?.presentVideoEditor(from: presentedVC, animated: true, completion: nil)
    }
  }
	
	func exportVideo() {
		let manager = FileManager.default
		let videoURL = manager.temporaryDirectory.appendingPathComponent("tmp.mov")
		if manager.fileExists(atPath: videoURL.path) {
		  try? manager.removeItem(at: videoURL)
		}
		
		let exportConfiguration = ExportVideoConfiguration(
		  fileURL: videoURL,
		  quality: .auto,
		  useHEVCCodecIfPossible: true,
		  watermarkConfiguration: nil
		)
		
		videoEditorSDK?.exportVideos(using: [exportConfiguration], completion: { (success, error) in
			DispatchQueue.main.async {
				// Clear video editor session data
				self.videoEditorSDK?.clearSessionData()
				let dictRes: [String: String] = [
					"preview": "", // cover is a UIImage, how do i get a path from this?
					"url": videoURL.absoluteString,
				]
				self.resolver?(dictRes)
				self.videoEditorSDK = nil
			}
		})
	  }
}


extension RNBanubaModule: BanubaVideoEditorDelegate {
  func videoEditorDidCancel(_ videoEditor: BanubaVideoEditor) {
    videoEditor.dismissVideoEditor(animated: true) { [weak self] in
      self?.videoEditorSDK = nil
      self?.rejecter?("cancel", "User cancelled video editor", nil);
    }
  }
  
  func videoEditorDone(_ videoEditor: BanubaVideoEditor) {
    videoEditor.dismissVideoEditor(animated: true) { [weak self] in
      self?.exportVideo()
    }
  }
}

// MARK: - VideoEditorConfig

private func createVideoEditorConfiguration() -> VideoEditorConfig {
	var config = VideoEditorConfig()
		
	var featureConfiguration = config.featureConfiguration
	featureConfiguration.supportsTrimRecordedVideo = true
	featureConfiguration.isMuteCameraAudioEnabled = true
	featureConfiguration.isDoubleTapForToggleCameraEnabled = true
	config.updateFeatureConfiguration(featureConfiguration: featureConfiguration)
	config.isHandfreeEnabled = true
	
	// Do customization here
	config.recorderConfiguration = updateRecorderConfiguration(config.recorderConfiguration)
	config.editorConfiguration = updateEditorConfiguration(config.editorConfiguration)
//	config.combinedGalleryConfiguration = updateCombinedGalleryConfiguration(config.combinedGalleryConfiguration)
//	config.videoCoverSelectionConfiguration = updateVideCoverSelectionConfiguration(config.videoCoverSelectionConfiguration)
	config.musicEditorConfiguration = updateMusicEditorConfigurtion(config.musicEditorConfiguration)
	config.overlayEditorConfiguration = updateOverlayEditorConfiguraiton(config.overlayEditorConfiguration)
//	config.textEditorConfiguration = updateTextEditorConfiguration(config.textEditorConfiguration)
	config.speedSelectionConfiguration = updateSpeedSelectionConfiguration(config.speedSelectionConfiguration)
	config.handsfreeConfiguration = updateHandsFreeConfiguration(config.handsfreeConfiguration!)
	config.trimGalleryVideoConfiguration = updateTrimGalleryVideoConfiguration(config.trimGalleryVideoConfiguration)
	config.multiTrimConfiguration = updateMultiTrimConfiguration(config.multiTrimConfiguration)
	config.singleTrimConfiguration = updateSingleTrimConfiguration(config.singleTrimConfiguration)
//	config.filterConfiguration = updateFilterConfiguration(config.filterConfiguration)
	config.alertViewConfiguration = updateAlertViewConfiguration(config.alertViewConfiguration)
//	config.fullScreenActivityConfiguration = updateFullScreenActivityConfiguration(config.fullScreenActivityConfiguration)
//	config.gifPickerConfiguration = updateGifPickerConfiguration(config.gifPickerConfiguration)
	config.videoDurationConfiguration = updateVideoDurationConfiguration(config.videoDurationConfiguration)
  
  return config
}

private func updateRecorderConfiguration(_ configuration: RecorderConfiguration) -> RecorderConfiguration {
	var configuration = configuration
	
	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-close"))
	configuration.removeButtonImageName = "ic-undo"
	configuration.additionalEffectsButtons = [
	  AdditionalEffectsButtonConfiguration(
		identifier: .beauty,
		imageConfiguration: ImageConfiguration(imageName: "ic-beauty"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-beauty-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .effects,
		imageConfiguration: ImageConfiguration(imageName: "ic-filter"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-filter-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .masks,
		imageConfiguration: ImageConfiguration(imageName: "ic-mask"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-mask-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .toggle,
		imageConfiguration: ImageConfiguration(imageName: "ic-flip-camera"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-flip-camera")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .flashlight,
		imageConfiguration: ImageConfiguration(imageName: "ic-flash-off"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-flash")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .timer,
		imageConfiguration: ImageConfiguration(imageName: "ic-timer-off"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-timer-3s")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .speed,
		imageConfiguration: ImageConfiguration(imageName: "ic-speed"),
		selectedImageConfiguration: nil
	  ),
	]

	configuration.speedButton = SpeedButtonConfiguration(
	  imageNameHalf: "ic-speed-x0_5",
	  imageNameNormal: "ic-speed-x1",
	  imageNameDouble: "ic-speed-x2",
	  imageNameTriple: "ic-speed-x3"
	)

	configuration.timerConfiguration.defaultButton = ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-timer-off"))
	configuration.timerConfiguration.options = [
		TimerConfiguration.TimerOptionConfiguration(
		button: ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-timer-3s")),
		startingTimerSeconds: 3,
		stoppingTimerSeconds: 0
		),
		TimerConfiguration.TimerOptionConfiguration(
		  button: ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-timer-5s")),
		  startingTimerSeconds: 5,
		  stoppingTimerSeconds: 0
		),
		TimerConfiguration.TimerOptionConfiguration(
		  button: ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-timer-10s")),
		  startingTimerSeconds: 10,
		  stoppingTimerSeconds: 0
		)
	]
	
	configuration.captureButtonMode = .video
	
	configuration.recordButtonConfiguration.normalImageName = "ic-record"
	configuration.recordButtonConfiguration.recordImageName = "ic-record"
	configuration.recordButtonConfiguration.width = 72
	configuration.recordButtonConfiguration.height = 72
	configuration.recordButtonConfiguration.circularTimeLineCaptureWidth = 3
	configuration.recordButtonConfiguration.circularTimeLineIdleWidth = 3
	configuration.recordButtonConfiguration.idleStrokeColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3).cgColor
	configuration.recordButtonConfiguration.strokeColor = UIColor(red: 255, green: 227, blue: 23).cgColor
	configuration.recordButtonConfiguration.spacingBetweenButtonAndCircular = 9
//	configuration.recordButtonConfiguration.recordingScale = 1.0

	configuration.timeLineConfiguration.isTimeLineHidden = false
	configuration.timeLineConfiguration.timeLineBackgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
//	configuration.timeLineConfiguration.progressBarColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
	configuration.timeLineConfiguration.itemsCornerRadius = 4
	configuration.timeLineConfiguration.progressBarSelectColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	
	configuration.galleryButton.borderColor = UIColor.white.cgColor
	configuration.galleryButton.borderWidth = 1
	configuration.galleryButton.cornerRadius = 22
	configuration.galleryButton.width = 40
	configuration.galleryButton.height = 40
	
	return configuration
  }

private func updateEditorConfiguration(_ configuration: EditorConfiguration) -> EditorConfiguration {
	var configuration = configuration

	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
	configuration.isVideoCoverSelectionEnabled = false
	configuration.additionalEffectsButtons = [
	  AdditionalEffectsButtonConfiguration(
		identifier: .beauty,
		imageConfiguration: ImageConfiguration(imageName: "ic-beauty"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-beauty-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .sound,
		imageConfiguration: ImageConfiguration(imageName: "ic-mic"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-mic-on"),
		position: .bottom
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .effects,
		imageConfiguration: ImageConfiguration(imageName: "ic-effects"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-effects-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
	    identifier: .sticker,
	    imageConfiguration: ImageConfiguration(imageName: "ic-gifs"),
	    selectedImageConfiguration: ImageConfiguration(imageName: "ic-gifs-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .masks,
		imageConfiguration: ImageConfiguration(imageName: "ic-mask"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-mask-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .color,
		imageConfiguration: ImageConfiguration(imageName: "ic-filter"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-filter-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .muteSound,
		imageConfiguration: ImageConfiguration(imageName: "ic-mic"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic_mic_off")
	  ),
	]
	
	return configuration
  }

func updateAlertViewConfiguration(_ configuration: BanubaVideoEditorSDK.AlertViewConfiguration) -> BanubaVideoEditorSDK.AlertViewConfiguration {
	var config = configuration
	config.cornerRadius = 16.0
	config.buttonRadius = 20.0
	config.refuseButtonTextColor = UIColor.white
	config.refuseButtonBackgroundColor = UIColor.init(red: 1, green: 207, blue: 151) // ablo green
	config.agreeButtonBackgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.02)
	config.agreeButtonTextColor = UIColor.init(red: 1, green: 207, blue: 151) // ablo green
	config.titleAligment = .center
	config.titleFont = UIFont.boldSystemFont(ofSize: 20.0)
	config.buttonsFont = UIFont.systemFont(ofSize: 20.0)
	return config
}

private func updateTrimGalleryVideoConfiguration(_ configuration: TrimGalleryVideoConfiguration) -> TrimGalleryVideoConfiguration {
	var configuration = configuration

	configuration.backButtonConfiguration = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
//	configuration.playerControlConfiguration = PlayerControlConfiguration(
//	  playButtonImageName: "ic_play",
//	  pauseButtonImageName: "ic_trim_pause"
//	)
	

//	configuration.galleryVideoPartsConfiguration.addGalleryVideoPartImageName = "add_video_part"
//	configuration.deleteGalleryVideoPartButtonConfiguration = ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic_delete_video_part"))

	configuration.nextButtonConfiguration.backgroundColor = .clear
	configuration.nextButtonConfiguration.textConfiguration.font = UIFont.boldSystemFont(ofSize: 14.0)
	configuration.nextButtonConfiguration.textConfiguration.color = UIColor(red: 255, green: 227, blue: 23) // sun yellow

	configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 255, green: 0, blue: 0)
	configuration.editedTimeLabelConfiguration.cornerRadius = 12
	configuration.editedTimeLabelConfiguration.defaultColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
	configuration.editedTimeLabelConfiguration.style.color = UIColor.white
	configuration.editedTimeLabelConfiguration.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

	return configuration
}

private func updateMultiTrimConfiguration(_ configuration: MultiTrimConfiguration) -> MultiTrimConfiguration {
	var configuration = configuration

	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
//	configuration.playerControlConfiguration = PlayerControlConfiguration(
//	  playButtonImageName: "ic_play",
//	  pauseButtonImageName: "ic_trim_pause"
//	)

	configuration.saveButton.backgroundColor = .clear
	configuration.saveButton.textConfiguration.font = UIFont.boldSystemFont(ofSize: 14.0)
	configuration.saveButton.textConfiguration.color = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	
	configuration.timeLimeConfiguration.progressBarColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	configuration.timeLimeConfiguration.progressBarSelectColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	
	configuration.trimTimeLineConfiguration.trimControlsColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow

	configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 255, green: 0, blue: 0)
	configuration.editedTimeLabelConfiguration.cornerRadius = 12
	configuration.editedTimeLabelConfiguration.defaultColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
	configuration.editedTimeLabelConfiguration.style.color = UIColor.white
	configuration.editedTimeLabelConfiguration.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
	
//	configuration.rotateButton?.imageConfiguration.

	return configuration
}

private func updateSingleTrimConfiguration(_ configuration: SingleTrimConfiguration) -> SingleTrimConfiguration {
	var configuration = configuration

	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
//	configuration.playerControlConfiguration = PlayerControlConfiguration(
//	  playButtonImageName: "ic_play",
//	  pauseButtonImageName: "ic_trim_pause"
//	)

	configuration.saveButton.backgroundColor = .clear
	configuration.saveButton.textConfiguration.font = UIFont.boldSystemFont(ofSize: 14.0)
	configuration.saveButton.textConfiguration.color = UIColor(red: 255, green: 227, blue: 23) // sun yellow

	configuration.trimTimeLineConfiguration.trimControlsColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow

	configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 255, green: 0, blue: 0)
	configuration.editedTimeLabelConfiguration.cornerRadius = 12
	configuration.editedTimeLabelConfiguration.defaultColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
	configuration.editedTimeLabelConfiguration.style.color = UIColor.white
	configuration.editedTimeLabelConfiguration.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

	return configuration
}

private func updateVideoDurationConfiguration(_ configuration: VideoEditorDurationConfig) -> VideoEditorDurationConfig {
	var configuration = configuration
	configuration.maximumVideoDuration = 15
	return configuration
}

private func updateSpeedSelectionConfiguration(_ configuration: SpeedSelectionConfiguration) -> SpeedSelectionConfiguration {
	var configuration = configuration

	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
	configuration.bottomViewBackgroundColor = UIColor.white
	configuration.bottomViewCornerRadius = 16
	configuration.hideScreenName = false
	configuration.screenName.alignment = .left
	configuration.screenName.color = UIColor(red: 29, green: 34, blue: 42)
	configuration.screenName.font = UIFont.systemFont(ofSize: 20.0)
	configuration.speedBarConfiguration.backgroundColor = UIColor.init(red: 230, green: 232, blue: 235)
	configuration.speedBarConfiguration.cornerRadius = 8
	configuration.speedBarConfiguration.speedItemTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.speedBarConfiguration.selectorColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	configuration.speedBarConfiguration.selectorTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	
	return configuration
}

private func updateHandsFreeConfiguration(_ configuration: HandsfreeConfiguration) -> HandsfreeConfiguration {
	var configuration = configuration

	// configuration.timerOptionBarConfiguration.timerDisabledOptionTitle // text inside selector
	
	// selector (off - 1s - 3s - 5s)
	configuration.timerOptionBarConfiguration.selectorColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
//	configuration.timerOptionBarConfiguration.selectorEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
	configuration.timerOptionBarConfiguration.selectorTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.optionBackgroundColor = UIColor(red: 230, green: 232, blue: 235) // very light blue
	configuration.timerOptionBarConfiguration.optionCornerRadius = 8
	configuration.timerOptionBarConfiguration.optionTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.sliderCornerRadius = 8
	configuration.timerOptionBarConfiguration.backgroundColor = UIColor(red: 230, green: 232, blue: 235) // very light grey
	configuration.timerOptionBarConfiguration.barCornerRadius = 8
		
	configuration.timerOptionBarConfiguration.cornerRadius = 0
	configuration.timerOptionBarConfiguration.backgroundViewColor = .white
	
	configuration.timerOptionBarConfiguration.timerTitleColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.modeTitleColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.dragTitleColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.minimumValueTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.currentValueTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.maximumValueTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.buttonTitleColor = .white
	
//	configuration.timerOptionBarConfiguration.activeThumbAndLineColor = .purple // UIColor(red: 255, green: 227, blue: 23) // sun yellow
//	configuration.timerOptionBarConfiguration.inactiveThumbAndLineColor = .green // UIColor(red: 230, green: 232, blue: 235) // very light grey
//	configuration.timerOptionBarConfiguration.switchOnTintColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	
	// bottom button start recording
	configuration.timerOptionBarConfiguration.buttonBackgroundColor = UIColor.init(red: 1, green: 207, blue: 151) // ablo green
	configuration.timerOptionBarConfiguration.buttonCornerRadius = 20
	
	return configuration
}

// MARK: - Overlay Editor (Gifs, Text)

func updateOverlayEditorConfiguraiton(_ configuration: OverlayEditorConfiguration) -> OverlayEditorConfiguration {
	var configuration = configuration
	
	configuration.mainOverlayViewControllerConfig = updateMainOverlayViewControllerConfig(configuration.mainOverlayViewControllerConfig)
	configuration.interactivesConfig = nil
	
	return configuration
  }
  
func updateMainOverlayViewControllerConfig(_ configuration: MainOverlayViewControllerConfig) -> MainOverlayViewControllerConfig {
	var configuration = configuration

	configuration.addButtons = [
//	  OverlayAddButtonConfig(
//		type: .text,
//		title: "Text",
//		titleColor: .white,
//		font: UIFont.systemFont(ofSize: 14.0),
//		imageName: "ic_AddText"
//	  ),
	  OverlayAddButtonConfig(
		type: .sticker,
		title: "GIFs",
		titleColor: .white,
		font: UIFont.systemFont(ofSize: 12.0),
		imageName: "ic-gifs"
	  )
	]

	configuration.editButtonsHeight = 50.0
	configuration.editButtonsInteritemSpacing = 0.0

	configuration.controlButtons = [
	  OverlayControlButtonConfig(
		type: .reset,
		imageName: "ic_restart",
		selectedImageName: nil
	  ),
	  OverlayControlButtonConfig(
		type: .play,
		imageName: "ic_editor_play",
		selectedImageName: "ic_pause"
	  ),
	  OverlayControlButtonConfig(
		type: .done,
		imageName: "ic-done",
		selectedImageName: nil
	  )
	]

	configuration.editCompositionButtons = [
	  OverlayEditButtonConfig(
		type: .edit,
		title: NSLocalizedString("OverlayEditor.Edit", comment: "edit comment"),
		titleColor: .white,
		font: UIFont.systemFont(ofSize: 14.0),
		imageName: "ic-edit",
		selectedImageName: nil
	  ),
	  
	  OverlayEditButtonConfig(
		type: .delete,
		title: NSLocalizedString("OverlayEditor.Delete", comment: "delete comment"),
		titleColor: .white,
		font: UIFont.systemFont(ofSize: 14.0),
		imageName: "ic-delete",
		selectedImageName: nil
	  )
	]

	configuration.playerControlsHeight = 50.0
	configuration.mainLabelColors = #colorLiteral(red: 0.2350233793, green: 0.7372031212, blue: 0.7565478683, alpha: 1)
	configuration.additionalLabelColors = UIColor.white
	configuration.additionalLabelFonts = UIFont.systemFont(ofSize: 12.0)
	configuration.cursorColor = UIColor.white
	configuration.audioWaveConfiguration.borderColor = UIColor.white
	configuration.resizeImageName = "ic_cut_arrow"
	configuration.draggersHorizontalInset = .zero
	configuration.draggersHeight = 25.0
	configuration.backgroundConfiguration.cornerRadius = .zero
	configuration.playerControlsBackgroundConfiguration.cornerRadius = .zero
	configuration.defaultLinesCount = 2
	configuration.timelineCornerRadius = .zero
	configuration.draggerBackgroundColor = UIColor.white
	configuration.timeLabelsOffset = .zero
	configuration.itemsTopOffset = .zero

	return configuration
}

// MARK: - Music Editor

func updateMusicEditorConfigurtion(_ configuration: MusicEditorConfig) -> MusicEditorConfig {
	var configuration = configuration

	configuration.mainMusicViewControllerConfig = updateMainMusicViewControllerConfig(configuration.mainMusicViewControllerConfig)
	configuration.audioRecorderViewControllerConfig = updateAudioRecorderViewControllerConfig(configuration.audioRecorderViewControllerConfig)
	configuration.audioTrackLineEditControllerConfig = updateAudioTrackLineEditControllerConfig(configuration.audioTrackLineEditControllerConfig)
	configuration.videoTrackLineEditControllerConfig = updateVideoTrackLineEditControllerConfig(configuration.videoTrackLineEditControllerConfig)

	return configuration
}

func updateMainMusicViewControllerConfig(_ configuration: MainMusicViewControllerConfig) -> MainMusicViewControllerConfig {
	var configuration = configuration

	configuration.editButtonsHeight = 50.0
	configuration.editButtons = [
	  EditButtonConfig(
		font: UIFont.systemFont(ofSize: 14.0),
		type: .record,
		title: NSLocalizedString("MusicEditor.Record", comment: "record comment"),
		titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
		imageName: "ic-mic-record"
	  )
	]
	configuration.editCompositionButtons = [
	  EditCompositionButtonConfig(
		font: UIFont.systemFont(ofSize: 14.0),
		type: .edit,
		title: NSLocalizedString("OverlayEditor.Edit", comment: "edit comment"),
		titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
		imageName: "ic-edit",
		selectedImageName: nil
	  ),
	  EditCompositionButtonConfig(
		font: UIFont.systemFont(ofSize: 14.0),
		type: .delete,
		title: NSLocalizedString("OverlayEditor.Delete", comment: "delete comment"),
		titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
		imageName: "ic-delete",
		selectedImageName: nil
	  )
	]

	configuration.controlsBackgroundConfiguration.color = #colorLiteral(red: 0.1176470588, green: 0.1333333333, blue: 0.1607843137, alpha: 1)
	configuration.controlsBackgroundConfiguration.cornerRadius = 0
	configuration.playerControlsHeight = 40.0

	configuration.controlButtons = [
	  ControlButtonConfig(
		type: .reset,
		imageName: "ic-reset",
		selectedImageName: nil
	  ),
	  ControlButtonConfig(
		type: .play,
		imageName: "ic-play",
		selectedImageName: "ic-pause"
	  ),
	  ControlButtonConfig(
		type: .done,
		imageName: "ic-done",
		selectedImageName: nil
	  )
	]

	configuration.audioWaveConfiguration.isRandomWaveColor = true
	configuration.mainLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.additionalLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.speakerImageName = "imageName"
//	configuration.volumeLabel.title = "Title"
	configuration.tracksLimit = 5
	configuration.cursorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.backgroundConfiguration.cornerRadius = 0.0
	configuration.timelineCornerRadius = 0.0

	return configuration
}

func updateAudioRecorderViewControllerConfig(_ configuration: AudioRecorderViewControllerConfig) -> AudioRecorderViewControllerConfig {
	var configuration = configuration

	configuration.playerControlsBackgroundConfiguration.color = #colorLiteral(red: 0.1176470588, green: 0.1333333333, blue: 0.1607843137, alpha: 1)
	configuration.playerControlsBackgroundConfiguration.cornerRadius = 0.0
	configuration.playerControlsHeight = 40

	configuration.rewindToStartButton = ControlButtonConfig(
	  type: .reset,
	  imageName: "ic-reset",
	  selectedImageName: nil
	)

	configuration.playPauseButton = ControlButtonConfig(
	  type: .play,
	  imageName: "ic-play",
	  selectedImageName: "ic-pause"
	)

	configuration.recordButton = ControlButtonConfig(
	  type: .play,
	  imageName: "ic-mic",
	  selectedImageName: "ic-mic-off"
	)
	
	configuration.backButtonImage = "ic-close"
	configuration.doneButtonImage = "ic-done"
	configuration.dimViewColor = #colorLiteral(red: 0.3176470588, green: 0.5960784314, blue: 0.8549019608, alpha: 0.2039811644)
	configuration.additionalLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.startingRecordingTimerSeconds = 0.0
	configuration.timerColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.cursorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.backgroundConfiguration.cornerRadius = 0.0
	configuration.playerControlsBackgroundConfiguration.cornerRadius = 0.0
	configuration.timelineCornerRadius = 0.0

	return configuration
}

func updateVideoTrackLineEditControllerConfig(_ configuration: VideoTrackLineEditViewControllerConfig) -> VideoTrackLineEditViewControllerConfig {
	var configuration = configuration

	configuration.doneButtonImageName = "ic-done"
	configuration.doneButtonTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.sliderTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.mainLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.additionalLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.backgroundConfiguration.cornerRadius = 0.0
	configuration.height = 50.0
	return configuration
}

func updateAudioTrackLineEditControllerConfig(_ configuration: AudioTrackLineEditViewControllerConfig) -> AudioTrackLineEditViewControllerConfig {
	var configuration = configuration

	configuration.audioWaveConfiguration.isRandomWaveColor = true
	configuration.audioWaveConfiguration.waveLinesColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.doneButtonImageName = "ic-done"
	configuration.doneButtonTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.sliderTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	configuration.draggersColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.draggerImageName = "trim_left"
//	configuration.trimHeight = 61.0
//	configuration.trimBorderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.trimBorderWidth = 2.0
//	configuration.cursorHeight = 1.0
//	configuration.dimViewColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//	configuration.mainLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.additionalLabelColors = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.cursorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.draggersWidth = 25.0
//	configuration.draggersLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//	configuration.draggersCornerRadius = 0.0
//	configuration.draggersLineWidth = 2.0
//	configuration.draggersLineHeight = 35.0
//	configuration.numberOfLinesInDraggers = 1
//	configuration.draggerLinesSpacing = 2.0
//	configuration.draggersCornerRadius = 0.0
//	configuration.backgroundConfiguration.cornerRadius = 0.0
//	configuration.voiceFilterConfiguration?.cornerRadius = 4.0

	return configuration
}
