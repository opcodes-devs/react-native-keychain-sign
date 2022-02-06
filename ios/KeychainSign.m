#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KeychainSign, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signData:(String)tag withAlgorithm:(SecKeyAlgorithm)algorithm data:(Data)data
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end
