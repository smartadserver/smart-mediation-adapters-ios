//
//  SASOguryBaseAdapter.h
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASdisplayKit.h>
#import <OguryAds/OguryAds.h>
#import <OguryChoiceManager/OguryChoiceManager.h>

#define SASOguryAdapterErrorDomain                          @"SASOguryAdapter"
#define SASOguryAdapterErrorCodeInvalidParameterString      1
#define SASOguryAdapterErrorCodeAdNotAvailable              2
#define SASOguryAdapterErrorCodeAdNotLoaded                 3
#define SASOguryAdapterErrorCodeAdError                     4

NS_ASSUME_NONNULL_BEGIN

/**
 Hold the different sizes needed to display an Ogury Thumbnail.
 */
typedef struct SASOguryAdapterThumbnailSize {
    NSInteger maxWidth;
    NSInteger maxHeight;
    NSInteger leftMargin;
    NSInteger topMargin;
} SASOguryAdapterThumbnailSize;

/**
 Ogury base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASOguryBaseAdapter : NSObject

/// Ogury Ad Unit ID.
@property (nonatomic, strong, nullable) NSString *adUnitId;

/// Ogury Thumbnail sizes.
@property (nonatomic, assign) SASOguryAdapterThumbnailSize thumbnailSize;

/// Ogury Banner size.
@property (nonatomic, strong, nullable) OguryAdsBannerSize *bannerSize;

/**
 Configure the Asset Key and the Ad Unit Id used by Ogury from the server parameter string provided
 by the Smart SDK.
 
 @param serverParameterString The server parameter string provided by Smart.
 @param clientParameters      The client parameters dictionary provided by Smart.
 @param error                 A reference to an error that will be returned if the configuration fails.
 @return YES if the configuration is successful, NO otherwise.
 */
- (BOOL)configureOgurySDKWithServerParameterString:(NSString *)serverParameterString andClientParameters:(NSDictionary *)clientParameters error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
