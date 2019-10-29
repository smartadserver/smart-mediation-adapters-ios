//
//  SASAdinCubeBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * _Nullable _IABString = nil;
static NSArray<NSString *> * _Nullable _nonIABVendorsAccepted = nil;

@implementation SASAdinCubeBaseAdapter

#pragma mark - Static properties

+ (nullable NSString *)IABString {
    return _IABString;
}

+ (void)setIABString:(nullable NSString *)IABString {
    _IABString = IABString;
}

+ (nullable NSArray<NSString *> *)nonIABVendorsAccepted {
    return _nonIABVendorsAccepted;
}

+ (void)setNonIABVendorsAccepted:(nullable NSArray<NSString *> *)nonIABVendorsAccepted {
    _nonIABVendorsAccepted = nonIABVendorsAccepted;
}

#pragma mark - Base class methods

- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"|"];
    
    // Extracting applicationID
    self.applicationID = serverParameters[0];
    [AdinCube setAppKey:self.applicationID];
    
    // The adapter will automatically handles consent forwarding to AdinCube if:
    // - you have provided 'IABString' & 'nonIABVendorsAccepted' to SASAdinCubeBaseAdapter (formatted as described in the Ogury's documentation)
    // - your application is whitelisted by Ogury.
    //
    // You can find more information in Ogury's documentation:
    // https://intelligentmonetization.ogury.co/dashboard/#/docs/ios/objective-c?networks=26226be-26226be#third-party-consent
    if (SASAdinCubeBaseAdapter.IABString != nil && SASAdinCubeBaseAdapter.nonIABVendorsAccepted != nil) {
        [AdinCube.UserConsent.External setConsentWithIABString:SASAdinCubeBaseAdapter.IABString andNonIABVendorsAccepted:SASAdinCubeBaseAdapter.nonIABVendorsAccepted];
    }
    
    // Note:
    // If you don't provide 'IABString' & 'nonIABVendorsAccepted' or if you aren't whitelisted by Ogury, you
    // will need to use 'Ogury Choice Manager' and you will need to implement it by yourself.
    //
    // You can find more information about 'Ogury Choice Manager' in Ogury's documentation:
    // https://intelligentmonetization.ogury.co/dashboard/#/docs/ios/objective-c?networks=26226be-26226be#ogury-choice-manager
}

@end

NS_ASSUME_NONNULL_END
