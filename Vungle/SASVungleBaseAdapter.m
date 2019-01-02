//
//  SASVungleBaseAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 21/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASVungleBaseAdapter.h"

@interface SASVungleBaseAdapter () <VungleSDKDelegate>
@end

@implementation SASVungleBaseAdapter

- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError * _Nullable __autoreleasing *)error {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"/"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 2 || ![serverParameters[0] isKindOfClass:[NSString class]] || ![serverParameters[1] isKindOfClass:[NSString class]]) {
        *error = [NSError errorWithDomain:SASVungleAdapterErrorDomain code:SASVungleAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    // Extracting and converting parameters
    self.applicationID = serverParameters[0];
    self.placementID = serverParameters[1];
    
    return YES;
}

- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Due to the fact that Vungle is not IAB compliant, it does not accept IAB Consent String, but only a
        // binary consent status.
        // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
        // in NSUserDefault, therefore this adapter will retrieve it from this key.
        // Adapt the code below if your app don't follow this convention.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:@"Smart_advertisingConsentStatus"];
        if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
            [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentAccepted];
        } else {
            [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentDenied];
        }
        
    } else {
        
        // If GDPR does not apply, AppLovin user consent can be set to accepted.
        [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentAccepted];
        
    }
}

@end
