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
    self.applicationID = serverParameterString;
    [AdinCube setAppKey:self.applicationID];
}

- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Consent is loaded from the binary consent key stored by SmartCMP.
        // You can change the code below if you are using a different CMP solution.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:SASCMPAdvertisingConsentStatusStorageKey];
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
