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

/// An IAB string that will be forwarded to AdinCube SDK.
///
/// Notes:
/// - this will only be forwarded to AdinCube SDK if 'nonIABVendorsAccepted' is not nil as well
/// - you can find more info here: https://intelligentmonetization.ogury.co/dashboard/#/docs/ios/objective-c?networks=26226be-26226be#ogury-choice-manager
@property (class, nonatomic, copy, nullable) NSString *IABString;

/// An array of non IAB vendors with accepted consent that will be forwarded to AdinCube SDK.
///
/// Notes:
/// - this will only be forwarded to AdinCube SDK if 'IABString' is not nil as well
/// - you can find more info here: https://intelligentmonetization.ogury.co/dashboard/#/docs/ios/objective-c?networks=26226be-26226be#ogury-choice-manager
@property (class, nonatomic, copy, nullable) NSArray<NSString *> *nonIABVendorsAccepted;

/// AdinCube application ID.
@property (nonatomic, copy, nullable) NSString *applicationID;

/**
 Configure the application ID used by AdinCube from the server parameter string provided
 by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 */
- (void)configureApplicationIDWithServerParameterString:(NSString *)serverParameterString;

@end

NS_ASSUME_NONNULL_END
