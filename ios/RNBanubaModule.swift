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
  
  private func createVideoEditorConfiguration() -> VideoEditorConfig {
    let config = VideoEditorConfig()
    // Do customization here
    return config
  }
  

  func exportVideo() {
      let manager = FileManager.default
      let videoURL = manager.temporaryDirectory.appendingPathComponent("tmp.mov")
      if manager.fileExists(atPath: videoURL.path) {
        try? manager.removeItem(at: videoURL)
      }
      
    videoEditorSDK?.exportVideoWithCoverImage(fileURL: videoURL, completion: { (success, error, cover) in
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
