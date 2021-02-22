//
//  SASOguryBaseAdapter.h
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import <OguryAds/OguryAds.h>
#import <OguryChoiceManager/OguryChoiceManager.h>

#define SASOguryAdapterErrorDomain                          @"SASOguryAdapter"
#define SASOguryAdapterErrorCodeInvalidParameterString      1
#define SASOguryAdapterErrorCodeAdNotAvailable              2
#define SASOguryAdapterErrorCodeAdNotLoaded                 3
#define SASOguryAdapterErrorCodeAdError                     4
#define SASOguryAdapterErrorCodeCannotInitializeOgurySDK    5

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
 @param completionHandler     Handler called when the Ogury SDK setup is finished (it will return an error in case of failure, nil if successful).
 */
- (void)configureOgurySDKWithServerParameterString:(NSString *)serverParameterString
                               andClientParameters:(NSDictionary *)clientParameters
                                 completionHandler:(void(^)(NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
