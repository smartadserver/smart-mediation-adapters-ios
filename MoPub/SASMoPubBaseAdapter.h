//
//  SASMoPubBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASMoPubAdapterErrorDomain              @"SASMoPubAdapter"

#define SASMoPubAdapterErrorCodeNoAd            100

NS_ASSUME_NONNULL_BEGIN

/**
 MoPub base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASMoPubBaseAdapter : NSObject

/// MoPub ad unit ID.
@property (nonatomic, copy, nullable) NSString *adUnitID;

/**
 Configure the ad unit ID used by MoPub from the server parameter string provided
 by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 */
- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString;

/**
 Configure GDPR for MoPub SDK from the client parameters dictionary provided by the
 Smart SDK.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 @return YES if MoPub will attempt to show a CMP consent dialog, NO otherwise.
 */
- (BOOL)configureGDPRWithClientParameters:(NSDictionary *)clientParameters;

/**
 Initialize the MoPub SDK if necessary then call a completion block that can be used to perform
 the ad call.
 
 @param completionBlock A block that will be called when the SDK is initialized properly.
 */
- (void)initializeMoPubSDK:(void(^)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
