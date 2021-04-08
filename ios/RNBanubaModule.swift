//
//  RNBanubaModule.swift
//  RNBanubaModule
//
//  Copyright © 2021 MassiveMedia. All rights reserved.
//

import Foundation
import React
import BanubaVideoEditorSDK
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK

@objc(RNBanubaModule)
class RNBanubaModule: NSObject, RCTBridgeModule {
  @objc
  func constantsToExport() -> [AnyHashable : Any]! {
    return ["count": 1]
  }

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
    
@objc func openVideoEditor() {
    guard let presentedVC = RCTPresentedViewController() else {
      return
    }
    
    let config = createVideoEditorConfiguration()
    let videoEditor = BanubaVideoEditor(
      token: "place AR token here",
      effectsToken: "j468B3S38YMa1ggmVlk+eixK7fK+1u0DuoAruXXiLp1kBNVx3itLv94Te1eVTAjYzgLTORexzjBxlPY0eq222mdxQPF+iLqgmVpWrC4lBXiEByrb5VpUqsFxaM/K9LLWDiI0bdQWeTy8YYulKgmPXrY=",
      configuration: config,
      externalViewControllerFactory: nil
    )
    DispatchQueue.main.async {
      videoEditor.presentVideoEditor(from: presentedVC, animated: true, completion: nil)
    }
  }
  
  private func createVideoEditorConfiguration() -> VideoEditorConfig {
    let config = VideoEditorConfig()
    // Do customization here
    return config
  }
    
    // MARK: - RCTBridgeModule
     static func moduleName() -> String! {
       return "RNBanubaModule"
     }
}
