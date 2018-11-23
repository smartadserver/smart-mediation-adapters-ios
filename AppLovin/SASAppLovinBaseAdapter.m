//
//  SASAppLovinBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAppLovinBaseAdapter

+ (void)initializeAppLovin {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [ALSdk initializeSdk];
        [ALSdk shared].settings.muted = YES; // all ads are muted by default
    });
}

- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Consent is loaded from the binary consent key stored by SmartCMP.
        // You can change the code below if you are using a different CMP solution.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:SASCMPAdvertisingConsentStatusStorageKey];
        if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
            [ALPrivacySettings setHasUserConsent:YES];
        } else {
            [ALPrivacySettings setHasUserConsent:NO];
        }
        
    } else {
        
        // If GDPR does not apply, AppLovin user consent can be set to accepted.
        [ALPrivacySettings setHasUserConsent:YES];
        
    }
}

@end

NS_ASSUME_NONNULL_END
