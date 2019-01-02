//
//  SASGoogleMobileAdsBaseAdapter.h
//  SmartAdServer
//
//  Created by Julien Gomez on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASGoogleMobileAdsAdapterErrorDomain                                        @"SASGoogleMobileAdsAdapter"
#define SASGoogleMobileAdsAdapterErrorCode                                          1
#define SASGoogleMobileAdsAdapterRewardedVideoExpiredOrAlreadyDisplayedErrorCode    2

#define SASGoogleMobileAdsAdapterRequestAgent                                       @"SmartAdServer"


NS_ASSUME_NONNULL_BEGIN

/**
 Google Mobile Ads base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASGoogleMobileAdsBaseAdapter : NSObject

/// Google Mobile Ads Application ID.
@property (nonatomic, strong, nullable) NSString *applicationID;

/// Google Mobile Ads Ad Unit ID.
@property (nonatomic, strong, nullable) NSString *adUnitID;

/**
 Initalize the Google Mobile Ads SDK.
 
 This method will only initialize the SDK once, no matter how many time it is called.
 */
+ (void)initializeGoogleMobileAdsWithApplicationID:(NSString *)applicationID;

/**
 Method called to initialize Google Mobile Ads IDs from the server parameter string provided by Smart.
 
 This method will fail with error if the ID can't be retrieved, in this case no ad call should
 be performed.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param error A reference to a NSError that will be filled if the method fails (and returns NO).
 @return YES if the configuration is successful, NO otherwise.
 */
- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error;

/**
 Return a dictionary of additional parameters that will include GDPR information.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 @return A dictionary of additional parameters.
 */
- (nullable NSDictionary *)additionalParametersFromClientParameters:(NSDictionary *)clientParameters;

/**
 Method called to initialize Google Mobile Ads request from the client parameters provided by Smart.
 
 @param clientParameters The client parameters string provided by Smart.
 */
- (GADRequest *)requestWithClientParameters:(NSDictionary *)clientParameters;


@end

NS_ASSUME_NONNULL_END
