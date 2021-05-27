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
      effectsToken: effectToken,
	  isFaceAREnabled: false,
      configuration: config,
      externalViewControllerFactory: nil
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
		
		videoEditorSDK?.exportVideo(fileURL: videoURL, completion: { (success, error) in
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
	featureConfiguration.isAudioBrowserEnabled = false
	featureConfiguration.isMuteCameraAudioEnabled = true
	config.updateFeatureConfiguration(featureConfiguration: featureConfiguration)
	
	config.isHandfreeEnabled = true
  
	// Do customization here
	config.recorderConfiguration = updateRecorderConfiguration(config.recorderConfiguration)
	config.editorConfiguration = updateEditorConfiguration(config.editorConfiguration)
//	config.combinedGalleryConfiguration = updateCombinedGalleryConfiguration(config.combinedGalleryConfiguration)
//	config.videoCoverSelectionConfiguration = updateVideCoverSelectionConfiguration(config.videoCoverSelectionConfiguration)
//	config.musicEditorConfiguration = updateMusicEditorConfigurtion(config.musicEditorConfiguration)
//	config.overlayEditorConfiguration = updateOverlayEditorConfiguraiton(config.overlayEditorConfiguration)
//	config.textEditorConfiguration = updateTextEditorConfiguration(config.textEditorConfiguration)
	config.speedSelectionConfiguration = updateSpeedSelectionConfiguration(config.speedSelectionConfiguration)
	config.handsfreeConfiguration = updateHandsFreeConfiguration(config.handsfreeConfiguration!)
	config.trimGalleryVideoConfiguration = updateTrimGalleryVideoConfiguration(config.trimGalleryVideoConfiguration)
	config.multiTrimConfiguration = updateMultiTrimConfiguration(config.multiTrimConfiguration)
	config.singleTrimConfiguration = updateSingleTrimConfiguration(config.singleTrimConfiguration)
//	config.filterConfiguration = updateFilterConfiguration(config.filterConfiguration)
	config.alertViewConfiguration = updateAlertViewConfiguration(config.alertViewConfiguration)
//	config.fullScreenActivityConfiguration = updateFullScreenActivityConfiguration(config.fullScreenActivityConfiguration)
	config.gifPickerConfiguration = updateGifPickerConfiguration(config.gifPickerConfiguration)
  
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
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .sound,
//		imageConfiguration: ImageConfiguration(imageName: "ic-mic"),
//		selectedImageConfiguration: ImageConfiguration(imageName: "ic-mic-off"),
//		position: .bottom
//	  ),
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
//		title: TextButtonConfiguration(
//			style: TextConfiguration(
//				font: UIFont.systemFont(ofSize: 12.0),
//				color: UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(1)
//			),
//			text: "Flip"
//		)
//		titlePosition: .bottom,
//		width: 100,
//		height: 100,
//		position: .top,
//		imageTitleSpacing: 0
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
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .muteSound,
//		imageConfiguration: ImageConfiguration(imageName: "ic-mic"),
//		selectedImageConfiguration: ImageConfiguration(imageName: "ic_mic_off")
//	  ),
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
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-mic-off"),
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

private func updateGifPickerConfiguration(_ configuration: GifPickerConfiguration) -> GifPickerConfiguration {
	var configuration = configuration

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
	configuration.speedBarConfiguration.selectorColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	configuration.speedBarConfiguration.selectorTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	
	return configuration
}

private func updateHandsFreeConfiguration(_ configuration: HandsfreeConfiguration) -> HandsfreeConfiguration {
	var configuration = configuration

	configuration.timerOptionBarConfiguration.backgroundColor = .white
	configuration.timerOptionBarConfiguration.barCornerRadius = 8
	configuration.timerOptionBarConfiguration.activeThumbAndLineColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow
	configuration.timerOptionBarConfiguration.inactiveThumbAndLineColor = UIColor.init(red: 230, green: 232, blue: 235)
	configuration.timerOptionBarConfiguration.switchOnTintColor = UIColor.init(red: 230, green: 232, blue: 235)
	configuration.timerOptionBarConfiguration.buttonBackgroundColor = UIColor.init(red: 1, green: 207, blue: 151) // ablo green
	configuration.timerOptionBarConfiguration.buttonCornerRadius = 24
	configuration.timerOptionBarConfiguration.optionTextColor = UIColor(red: 29, green: 34, blue: 42) // dark grey
	configuration.timerOptionBarConfiguration.optionCornerRadius = 8
	configuration.timerOptionBarConfiguration.sliderCornerRadius = 8
	
	return configuration
}
