//
//  SASAppLovinBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASAppLovinAdapterErrorDomain               @"SASAppLovinAdapter"

NS_ASSUME_NONNULL_BEGIN

/**
 AppLovin base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAppLovinBaseAdapter : NSObject

/**
 Initalize the AppLovin SDK.
 
 This method will only initialize the SDK once, no matter how many time it is called.
 */
+ (void)initializeAppLovin;

/**
 Configure GDPR for AppLovin SDK from the client parameters dictionary provided by the
 Smart SDK.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 */
- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters;

@end

NS_ASSUME_NONNULL_END
