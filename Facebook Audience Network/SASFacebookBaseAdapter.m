//
//  SASFacebookBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASFacebookBaseAdapter.h"

@implementation SASFacebookBaseAdapter

+ (void)initializeFacebook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Setting the mediation service
        [FBAdSettings setMediationService:@"Smart AdServer"];
    });
}

- (void)configurePlacementIDWithServerParameterString:(NSString *)serverParameterString {
    // Initialize the Facebook SDK if necessary
    [SASFacebookBaseAdapter initializeFacebook];
    
    // Retrieving the placement ID from the server parameter string
    self.placementID = serverParameterString;
}

@end
