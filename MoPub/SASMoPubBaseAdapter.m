//
//  SASMoPubBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASMoPubBaseAdapter

- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString {
    self.adUnitID = serverParameterString;
}

- (BOOL)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    if ([[MoPub sharedInstance] shouldShowConsentDialog]) {
        [[MoPub sharedInstance] loadConsentDialogWithCompletion:^(NSError * _Nullable error) {
            if (!error) {
                [[MoPub sharedInstance] showConsentDialogFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController completion:nil];
            }
        }];
        return YES;
    } else {
        return NO;
    }
}

- (void)initializeMoPubSDK:(void(^)())completionBlock {
    if ([[MoPub sharedInstance] isSdkInitialized]) {
        completionBlock();
    } else {
        [[MoPub sharedInstance] initializeSdkWithConfiguration:[[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitID] completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }];
    }
}

@end

NS_ASSUME_NONNULL_END
