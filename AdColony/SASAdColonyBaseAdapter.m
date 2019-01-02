//
//  SASAdColonyBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 20/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdColonyBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdColonyBaseAdapter

- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"/"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 3 || ![serverParameters[2] respondsToSelector:@selector(intValue)]) {
        *error = [NSError errorWithDomain:SASAdColonyAdapterErrorDomain code:SASAdColonyAdapterErrorCode userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    // Extracting and converting parameters
    self.appID = serverParameters[0];
    self.zoneID = serverParameters[1];
    self.zoneType = [serverParameters[2] intValue];
    
    return YES;
}

- (AdColonyAppOptions *)optionsFromClientParameters:(NSDictionary *)clientParameters {
    // An option object is required to send the right GDPR info.
    AdColonyAppOptions *options = [[AdColonyAppOptions alloc] init];
    options.gdprRequired = [[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue];
    
    // Use binary consent for the moment, will use real consent string later.
    // options.gdprConsentString = [clientParameters objectForKey:SASMediationClientParameterGDPRConsent];
    
    // Due to the fact that AdColony is not IAB compliant, it does not accept IAB Consent String, but only a
    // binary consent status. The Smart Display SDK will retrieve it from the NSUserDefault with the
    // key "Smart_advertisingConsentStatus". Note that this is not an IAB requirement, so you have to set it by yourself.
    NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:SASCMPAdvertisingConsentStatusStorageKey];
    if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
        options.gdprConsentString = @"1";
    } else {
        options.gdprConsentString = @"0";
    }
    
    return options;
}

@end

NS_ASSUME_NONNULL_END
