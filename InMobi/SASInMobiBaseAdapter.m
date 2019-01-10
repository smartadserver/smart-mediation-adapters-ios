//
//  SASInMobiBaseAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASInMobiBaseAdapter.h"

#define kInMobiGDPRAppliesKey   @"gdpr"
#define kInMobiGDPRGrantedKey   @"gdpr_consent_available"

NS_ASSUME_NONNULL_BEGIN

@implementation SASInMobiBaseAdapter

- (BOOL)configureInMobiSDKWithServerParameterString:(NSString *)serverParameterString andClientParameters:(NSDictionary *)clientParameters error:(NSError **)error {
    
    // Retrieve GDPR consent
    NSMutableDictionary *consentDictionary = [NSMutableDictionary dictionary];
    
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Set that GDPR applies
        [consentDictionary setObject:@1 forKey:kInMobiGDPRAppliesKey];
        
        // InMobiSDK does not accept IAB GDPR Consent String. It only accepts a binary consent string.
        // By default, the adapter will trying to retrieve it in the NSUserDefault with the key
        // "Smart_advertisingConsentStatus", but you will have to set it by yourself.
        //
        // You can change the code below if you are using a different solution.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:SmartAdvertisingConsentStatusStorageKey];
        
        if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
            [consentDictionary setObject:@"true" forKey:kInMobiGDPRGrantedKey];
        } else {
            [consentDictionary setObject:@"false" forKey:kInMobiGDPRGrantedKey];
        }
    
    } else {
        
        // Set that GDPR does not apply
        [consentDictionary setObject:@0 forKey:kInMobiGDPRAppliesKey];
        
    }
    
    // Retrieve the account id from the serverParameterString
    // IDs are sent ad a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"/"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 2 || ![serverParameters[1] respondsToSelector:@selector(longLongValue)]) {
        *error = [NSError errorWithDomain:SASInMobiAdapterErrorDomain code:SASInMobiAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    NSString *accountID = serverParameters[0];
    self.placementID = [serverParameters[1] longLongValue];
    
    // Init InMobi SDK
    [IMSdk initWithAccountID:accountID consentDictionary:consentDictionary];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
