//
//  SASAdColonyBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 20/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASAdColonyAdapterErrorDomain               @"SASAdColonyAdapter"
#define SASAdColonyAdapterErrorCode                 1

NS_ASSUME_NONNULL_BEGIN

/**
 AdColony base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAdColonyBaseAdapter : NSObject

/// AdColony app ID.
@property (nonatomic, strong, nullable) NSString *appID;

/// AdColony zone ID.
@property (nonatomic, strong, nullable) NSString *zoneID;

/// AdColony zone type.
@property (nonatomic, assign) AdColonyZoneType zoneType;

/**
 Method called to initialize AdColony IDs from the server parameter string provided by Smart.
 
 This method will fail with error if the IDs can't be retrieved, in this case no ad call should
 be performed.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param error A reference to a NSError that will be filled if the method fails (and returns NO).
 @return YES if the configuration is successful, NO otherwise.
 */
- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
