//
//  SASTapjoyBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASTapjoyAdapterErrorDomain                             @"SASTapjoyAdapter"

#define SASTapjoyAdapterErrorCodeInvalidParameterString         100
#define SASTapjoyAdapterErrorCodeUnableToConnect                200

#define SASTapjoyAdapterErrorCodeFailedToLoadInterstitialAd     300
#define SASTapjoyAdapterErrorMessageFailedToLoadInterstitialAd  @"No Tapjoy interstitial available"

#define SASTapjoyAdapterErrorCodeFailedToLoadRewardedAd         400
#define SASTapjoyAdapterErrorMessageFailedToLoadRewardedAd      @"No Tapjoy rewarded video available"

NS_ASSUME_NONNULL_BEGIN

/**
 Tapjoy base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASTapjoyBaseAdapter : NSObject

/// The Tapjoy application ID for ad calls.
@property (nonatomic, strong, nullable) NSString *applicationID;

/// The Tapjoy placement name for ad calls.
@property (nonatomic, strong, nullable) NSString *placementName;

/**
 Method called to initialize Tapjoy IDs from the server parameter string provided by Smart.
 
 This method will fail with error if the IDs can't be retrieved, in this case no ad call should
 be performed.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param error A reference to a NSError that will be filled if the method fails (and returns NO).
 @return YES if the configuration is successful, NO otherwise.
 */
- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error;

/**
 Configure GDPR for Tapjoy SDK from the client parameters dictionary provided by the
 Smart SDK.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 */
- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters;

/**
 Connect the Tapjoy SDK if necessary.
 
 This convenient method must be called before making any ad call.
 
 @warning Calling this method from a subclass requires to override both 'connectionDidSucceed' and
 'connectionDidFailWithError' methods.
 */
- (void)connectTapjoySDK;

@end

NS_ASSUME_NONNULL_END
