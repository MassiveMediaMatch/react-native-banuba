//
//  RNBanubaModuleBridge.m
//  react-native-banuba
//
//  Created by Jovan Stanimirovic on 28/04/2021.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNBanubaModule, NSObject)

// RCT_EXTERN_METHOD(addEvent:(NSString *)name location:(NSString *)location date:(NSNumber *)date)

RCT_EXTERN_METHOD(startEditorWithTokens:(NSString *)videoEditorToken effectToken:(NSString*)effectToken resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
