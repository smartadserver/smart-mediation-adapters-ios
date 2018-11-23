//
//  SASFacebookBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASFacebookAdapterErrorDomain               @"SASFacebookAdapter"
#define SASFacebookAdapterNoFillErrorCode           1001

NS_ASSUME_NONNULL_BEGIN

/**
 Facebook base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASFacebookBaseAdapter : NSObject

/// Facebook placement ID.
@property (nonatomic, copy, nullable) NSString *placementID;

/**
 Configure the placement ID used by Facebook from the server parameter string provided
 by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 */
- (void)configurePlacementIDWithServerParameterString:(NSString *)serverParameterString;

@end

NS_ASSUME_NONNULL_END
