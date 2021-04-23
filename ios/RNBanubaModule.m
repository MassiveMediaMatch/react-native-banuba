//
//  RNBanubaModule.m
//  RNBanubaModule
//
//  Copyright © 2021 MassiveMedia. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNBanubaModule, NSObject)

RCT_EXTERN_METHOD(
  startEditorWithTokens: (NSString *)videoEditorToken
  (NSString *)effectToken
  (RCTPromiseResolveBlock)resolve
  rejecter: (RCTPromiseRejectBlock)reject
)

@end
