//
//  SASGoogleMobileAdsBaseAdapter.m
//  SmartAdServer
//
//  Created by Julien Gomez on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsBaseAdapter.h"
#import <CoreLocation/CoreLocation.h>


@implementation SASGoogleMobileAdsBaseAdapter

+ (void)initializeGoogleMobileAdsWithApplicationID:(NSString *)applicationID {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [GADMobileAds configureWithApplicationID:applicationID];
    });
}

- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"|"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 2) {
        *error = [NSError errorWithDomain:SASGoogleMobileAdsAdapterErrorDomain
                                     code:SASGoogleMobileAdsAdapterErrorCode
                                 userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    // Extracting and converting parameters
    self.applicationID = serverParameters[0];
    self.adUnitID = serverParameters[1];
    
    return YES;
}

- (nullable NSDictionary *)additionalParametersFromClientParameters:(NSDictionary *)clientParameters; {
    // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
    if ([[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue]) {
        
        // Due to the fact that Google Mobile Ads is not IAB compliant, it does not accept IAB Consent String, but only a
        // binary consent status.
        // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
        // in NSUserDefault, therefore this adapter will retrieve it from this key.
        // Adapt the code below if your app don't follow this convention.
        NSString *storedBinaryConsentForAdvertising = [[NSUserDefaults standardUserDefaults] objectForKey:@"Smart_advertisingConsentStatus"];
        if (storedBinaryConsentForAdvertising && [storedBinaryConsentForAdvertising isEqualToString:@"1"]) {
            return nil;
        } else {
            return @{@"npa": @"1"}; // 'Non-Personalized Ads' enabled for this user
        }
        
    } else {
        
        // If GDPR does not apply, AdMob user consent can be set to accepted.
        return nil;
        
    }
}

- (GADRequest *)requestWithClientParameters:(NSDictionary *)clientParameters {
    // Initialize the SDK
    [SASGoogleMobileAdsBaseAdapter initializeGoogleMobileAdsWithApplicationID:self.applicationID];
    
    // Creating an Google Mobile Ads ad request
    GADRequest *request = [GADRequest request];
    
    // Test ads will be returned for devices with device IDs specified in this array.
    request.testDevices = @[ kGADSimulatorID /* other UDIDs here */];
    request.requestAgent = SASGoogleMobileAdsAdapterRequestAgent;
    
    CLLocation *location = [clientParameters objectForKey:SASMediationClientParameterLocation];
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
    // Configure additional parameters if necessary (GDPR info)
    NSDictionary *additionalParameters = [self additionalParametersFromClientParameters:clientParameters];
    if (additionalParameters) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = additionalParameters;
        [request registerAdNetworkExtras:extras];
    }

    return request;
}

@end
