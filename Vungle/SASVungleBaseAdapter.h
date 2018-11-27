//
//  SASVungleBaseAdapter.h
//  SmartAdServer
//
//  Created by glaubier on 21/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import <VungleSDK/VungleSDK.h>

#define SASVungleAdapterErrorDomain                         @"SASVungleAdapter"

#define SASVungleAdapterErrorCodeInvalidParameterString     100

#define SASCMPAdvertisingConsentStatusStorageKey            @"SmartCMP_advertisingConsentStatus"

NS_ASSUME_NONNULL_BEGIN

/**
 Vungle base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASVungleBaseAdapter : NSObject

/// Vungle Application ID.
@property (nonatomic, strong) NSString *applicationID;

/// Vungle Placement ID.
@property (nonatomic, strong) NSString *placementID;

/// Boolean used to know if the ad is ready or not.
@property (nonatomic, assign) BOOL adIsReady;

/**
 Method called to initialize Vungle IDs from the server parameter string provided by Smart.
 
 This method will fail with error if the IDs can't be retrieved, in this case no ad call should
 be performed.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param error A reference to a NSError that will be filled if the method fails (and returns NO).
 @return YES if the configuration is successful, NO otherwise.
 */
- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error;

/**
 Configure GDPR for AppLovin SDK from the client parameters dictionary provided by the
 Smart SDK.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 */
- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters;

@end

NS_ASSUME_NONNULL_END
