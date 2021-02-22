//
//  SASOguryBaseAdapter.m
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASOguryBaseAdapter

- (void)configureOgurySDKWithServerParameterString:(NSString *)serverParameterString
                               andClientParameters:(NSDictionary *)clientParameters
                                 completionHandler:(void(^)(NSError * _Nullable))completionHandler {
    // Retrieve the asset key and the ad unit id
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"|"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 2 && serverParameters.count != 3 && serverParameters.count != 6) {
        NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        completionHandler(error);
        return;
    }
    
    // Parsing generic parameters
    NSString *assetKey = serverParameters[0];
    self.adUnitId = serverParameters[1];
    
    // Banner parameters
    if (serverParameters.count == 3) {
        // Invalid parameter string, the loading will be cancelled with an error
        if (![serverParameters[2] respondsToSelector:@selector(integerValue)]) {
            NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
            completionHandler(error);
            return;
        }
        
        // Setting banner size
        if ([serverParameters[2] integerValue] == 0) {
            self.bannerSize = OguryAdsBannerSize.small_banner_320x50;
        } else if ([serverParameters[2] integerValue] == 1) {
            self.bannerSize = OguryAdsBannerSize.mpu_300x250;
        }
    }
    
    // Thumbnail parameters
    if (serverParameters.count == 6) {
        // Invalid parameter string, the loading will be cancelled with an error
        if (![serverParameters[2] respondsToSelector:@selector(integerValue)]
            || ![serverParameters[3] respondsToSelector:@selector(integerValue)]
            || ![serverParameters[4] respondsToSelector:@selector(integerValue)]
            || ![serverParameters[5] respondsToSelector:@selector(integerValue)]) {
            NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
            completionHandler(error);
            return;
        }
        
        // Setting Thumbnail size
        SASOguryAdapterThumbnailSize size;
        size.maxWidth = [serverParameters[2] integerValue];
        size.maxHeight = [serverParameters[3] integerValue];
        size.leftMargin = [serverParameters[4] integerValue];
        size.topMargin = [serverParameters[5] integerValue];
        
        self.thumbnailSize = size;
    }
 
    // Retrieving IAB TCF Consent String v2 from shared preferences
    NSString *tcfString = [[NSUserDefaults standardUserDefaults] objectForKey:@"IABTCF_TCString"];
    if (tcfString != nil) {
        // Setting the TCF string on the Ogury SDK
        [OguryChoiceManagerExternal setConsentForTCFV2WithAssetKey:assetKey iabString:tcfString andNonIABVendorsAccepted:@[]];
    }
    
    // Initializing Ogury SDK
    [[OguryAds shared] setupWithAssetKey:assetKey andCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // Ogury has been successfully initialized
                completionHandler(nil);
            } else {
                // An error occurred when initializing Ogury
                NSError *handlerError = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeCannotInitializeOgurySDK userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury SDK returned error: %@", error] }];
                completionHandler(handlerError);
            }
        });
    }];
}

@end

NS_ASSUME_NONNULL_END
