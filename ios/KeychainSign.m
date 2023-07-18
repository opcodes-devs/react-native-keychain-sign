#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KeychainSign, NSObject)


/*
RCT_EXTERN_METHOD(signData:(NSString *)tag withAlgorithm:(NSString *)algorithm data:(NSString *)data
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) */

RCT_EXTERN_METHOD(signData:(NSString *)data withTag:(NSString *)tag withAlgorithm:(NSString *)algorithm 
                  withResolver:(RCTPromiseResolveBlock)resolve 
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(genKeysAndSaveToKeychain:(NSString *)tag withRequiresBiometry:(BOOL)requiresBiometry
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPublicKeyByTag:(NSString *)tag
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
