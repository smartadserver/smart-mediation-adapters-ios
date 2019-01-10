//
//  SASInMobiBannerAdapter.h
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASInMobiBaseAdapter.h"
#import <SASDisplayKit/SASdisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 InMobi banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASInMobiBannerAdapter : SASInMobiBaseAdapter <SASMediationBannerAdapter, IMBannerDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
@property (nonatomic, weak) id<SASMediationBannerAdapterDelegate> delegate;

/// The currently loaded InMobi banner, if any.
@property (nonatomic, strong, nullable) IMBanner *banner;

@end

NS_ASSUME_NONNULL_END
