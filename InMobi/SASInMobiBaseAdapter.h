//
//  SASInMobiBaseAdapter.h
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InMobiSDK/InMobiSDK.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SmartAdvertisingConsentStatusStorageKey             @"Smart_advertisingConsentStatus"
#define SASInMobiAdapterErrorDomain                         @"SASInMobiAdapter"
#define SASInMobiAdapterErrorCodeInvalidParameterString     100

NS_ASSUME_NONNULL_BEGIN

/**
 InMobi base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASInMobiBaseAdapter : NSObject

/// InMobi placement ID.
@property (nonatomic, assign) long placementID;

/**
 Configure the account ID and the placement ID used by InMobi from the server parameter string provided
 by the Smart SDK. Also handle GDPR consent which can be stored in the client parameters dictionary
 provided by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param clientParameters      The client parameters dictionary provided by Smart.
 */
- (BOOL)configureInMobiSDKWithServerParameterString:(NSString *)serverParameterString andClientParameters:(NSDictionary *)clientParameters error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
