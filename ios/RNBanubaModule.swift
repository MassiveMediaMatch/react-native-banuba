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
    DispatchQueue.main.async {
      guard let presentedVC = RCTPresentedViewController() else {
        return
      }
      self.videoEditorSDK?.presentVideoEditor(from: presentedVC, animated: true, completion: nil)
    }
  }

//  func exportVideo() {
//      let manager = FileManager.default
//      let videoURL = manager.temporaryDirectory.appendingPathComponent("tmp.mov")
//      if manager.fileExists(atPath: videoURL.path) {
//        try? manager.removeItem(at: videoURL)
//      }
//
//    videoEditorSDK?.exportVideoWithCoverImage(fileURL: videoURL, completion: { (success, error, cover) in
//      DispatchQueue.main.async {
//        // Clear video editor session data
//        self.videoEditorSDK?.clearSessionData()
//        let dictRes: [String: String] = [
//          "preview": "", // cover is a UIImage, how do i get a path from this?
//          "url": videoURL.absoluteString,
//        ]
//        self.resolver?(dictRes)
//        self.videoEditorSDK = nil
//      }
//    })
//  }
	
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
  
	// Do customization here
	config.recorderConfiguration = updateRecorderConfiguration(config.recorderConfiguration)
	config.editorConfiguration = updateEditorConfiguration(config.editorConfiguration)
//	config.combinedGalleryConfiguration = updateCombinedGalleryConfiguration(config.combinedGalleryConfiguration)
//	config.videoCoverSelectionConfiguration = updateVideCoverSelectionConfiguration(config.videoCoverSelectionConfiguration)
//	config.musicEditorConfiguration = updateMusicEditorConfigurtion(config.musicEditorConfiguration)
//	config.overlayEditorConfiguration = updateOverlayEditorConfiguraiton(config.overlayEditorConfiguration)
//	config.textEditorConfiguration = updateTextEditorConfiguration(config.textEditorConfiguration)
//	config.speedSelectionConfiguration = updateSpeedSelectionConfiguration(config.speedSelectionConfiguration)
//	config.trimGalleryVideoConfiguration = updateTrimGalleryVideoConfiguration(config.trimGalleryVideoConfiguration)
//	config.multiTrimConfiguration = updateMultiTrimConfiguration(config.multiTrimConfiguration)
//	config.singleTrimConfiguration = updateSingleTrimConfiguration(config.singleTrimConfiguration)
//	config.filterConfiguration = updateFilterConfiguration(config.filterConfiguration)
	config.alertViewConfiguration = updateAlertViewConfiguration(config.alertViewConfiguration)
//	config.fullScreenActivityConfiguration = updateFullScreenActivityConfiguration(config.fullScreenActivityConfiguration)
  
  return config
}

private func updateRecorderConfiguration(_ configuration: RecorderConfiguration) -> RecorderConfiguration {
	var configuration = configuration
	
	configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic-back-arrow"))
	configuration.removeButtonImageName = "ic-undo"
	configuration.additionalEffectsButtons = [
	  AdditionalEffectsButtonConfiguration(
		identifier: .beauty,
		imageConfiguration: ImageConfiguration(imageName: "ic-beauty"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-beauty-on")
	  ),
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .sound,
//		imageConfiguration: ImageConfiguration(imageName: "ic_audio_off"),
//		selectedImageConfiguration: ImageConfiguration(imageName: "ic_audio_on"),
//		position: .bottom
//	  ),
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .effects,
//		imageConfiguration: ImageConfiguration(imageName: "ic_filters_off"),
//		selectedImageConfiguration: ImageConfiguration(imageName: "ic_filters_on")
//	  ),
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .masks,
//		imageConfiguration: ImageConfiguration(imageName: "ic_masks_off"),
//		selectedImageConfiguration: ImageConfiguration(imageName: "ic_masks_on")
//	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .toggle,
		imageConfiguration: ImageConfiguration(imageName: "ic-flip-camera"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-flip-camera")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .flashlight,
		imageConfiguration: ImageConfiguration(imageName: "ic-flash-off"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-flash-on")
	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .timer,
		imageConfiguration: ImageConfiguration(imageName: "ic-timer-off"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic-timer-3s")
	  ),
//	  AdditionalEffectsButtonConfiguration(
//		identifier: .speed,
//		imageConfiguration: ImageConfiguration(imageName: "ic_speed_1x"),
//		selectedImageConfiguration: nil
//	  ),
	  AdditionalEffectsButtonConfiguration(
		identifier: .muteSound,
		imageConfiguration: ImageConfiguration(imageName: "ic-mic"),
		selectedImageConfiguration: ImageConfiguration(imageName: "ic_mic_off")
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
	configuration.recordButtonConfiguration.gradientColors = [UIColor(red: 255, green: 0, blue: 0).cgColor]
	configuration.recordButtonConfiguration.circularTimeLineCaptureWidth = 3
	configuration.recordButtonConfiguration.circularTimeLineIdleWidth = 3
	configuration.recordButtonConfiguration.idleStrokeColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3).cgColor
	configuration.recordButtonConfiguration.strokeColor = UIColor(red: 255, green: 227, blue: 23).cgColor
	configuration.recordButtonConfiguration.spacingBetweenButtonAndCircular = 9
	configuration.recordButtonConfiguration.recordingScale = 1.0

	configuration.timeLineConfiguration.isTimeLineHidden = false
	configuration.timeLineConfiguration.timeLineBackgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
//	configuration.timeLineConfiguration.progressBarColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
	configuration.timeLineConfiguration.itemsCornerRadius = 4
	configuration.timeLineConfiguration.progressBarSelectColor = UIColor(red: 255, green: 227, blue: 23) // sun yellow

//	let nextButtonTextConfiguration = TextConfiguration(
//	  kern: 1.0,
//	  font: UIFont.systemFont(ofSize: 12.0),
//	  color: UIColor.white
//	)
//	let inactiveNextButtonTextConfiguration = TextConfiguration(
//	  kern: 1.0,
//	  font: UIFont.systemFont(ofSize: 12.0),
//	  color: UIColor.white.withAlphaComponent(0.5)
//	)
//	configuration.saveButton = SaveButtonConfiguration(
//	  textConfiguration: nextButtonTextConfiguration,
//	  inactiveTextConfiguration: inactiveNextButtonTextConfiguration,
//	  text: "NEXT",
//	  width: 68.0,
//	  height: 41.0,
//	  cornerRadius: 4.0,
//	  backgroundColor: UIColor(red: 6, green: 188, blue: 193),
//	  inactiveBackgroundColor: UIColor(red: 6, green: 188, blue: 193).withAlphaComponent(0.5)
//	)
	
	configuration.galleryButton.borderColor = UIColor.white.cgColor
	configuration.galleryButton.borderWidth = 1
	configuration.galleryButton.cornerRadius = 22
	configuration.galleryButton.width = 40
	configuration.galleryButton.height = 40
	
	return configuration
  }

private func updateEditorConfiguration(_ configuration: EditorConfiguration) -> EditorConfiguration {
	var configuration = configuration

	configuration.isVideoCoverSelectionEnabled = false
	
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
