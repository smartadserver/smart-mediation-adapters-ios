//
//  SASAdinCubeBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdinCubeBaseAdapter

- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"|"];
    
    // Extracting applicationID
    self.applicationID = serverParameters[0];
    [AdinCube setAppKey:self.applicationID];
}


- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Due to the fact that AdinCube is not IAB compliant, it does not accept IAB Consent String, but only a
        // binary consent status.
        // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
        // in NSUserDefault, therefore this adapter will retrieve it from this key.
        // Adapt the code below if your app don't follow this convention.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:@"Smart_advertisingConsentStatus"];
        if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
            [[AdinCube UserConsent] setAccepted];
        } else {
            [[AdinCube UserConsent] setDeclined];
        }
        
    } else {
        
        // If GDPR does not apply, AdinCube user consent can be set to accepted.
        [[AdinCube UserConsent] setAccepted];
        
    }
}

@end

NS_ASSUME_NONNULL_END
