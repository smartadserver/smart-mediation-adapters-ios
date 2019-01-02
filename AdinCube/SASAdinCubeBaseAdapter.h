//
//  SASAdinCubeBaseAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdinCube/AdinCube.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASAdinCubeAdapterErrorDomain               @"SASAdinCubeAdapter"
#define SASAdinCubeAdapterNoFillErrorCode           @"NO_FILL"

NS_ASSUME_NONNULL_BEGIN

/**
 AdinCube base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAdinCubeBaseAdapter : NSObject

/// AdinCube application ID.
@property (nonatomic, copy, nullable) NSString *applicationID;

/**
 Configure the application ID used by AdinCube from the server parameter string provided
 by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 */
- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString;

/**
 Configure GDPR for AdinCube SDK from the client parameters dictionary provided by the
 Smart SDK.
 
 @param clientParameters The client parameters dictionary provided by Smart.
 */
- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters;

@end

NS_ASSUME_NONNULL_END
