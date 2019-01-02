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
        
        // Due to the fact that AppLovin is not IAB compliant, it does not accept IAB Consent String, but only a
        // binary consent status.
        // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
        // in NSUserDefault, therefore this adapter will retrieve it from this key.
        // Adapt the code below if your app don't follow this convention.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:@"Smart_advertisingConsentStatus"];
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
