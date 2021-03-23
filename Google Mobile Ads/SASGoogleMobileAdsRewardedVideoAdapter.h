//
//  SASGoogleMobileAdsRewardedVideoAdapter.h
//  SmartAdServer
//
//  Created by Julien Gomez on 26/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Google Mobile Ads rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASGoogleMobileAdsRewardedVideoAdapter : SASGoogleMobileAdsBaseAdapter <SASMediationRewardedVideoAdapter, GADFullScreenContentDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationRewardedVideoAdapterDelegate> delegate;

/// The currently loaded (and ready) Google Mobile Ads rewarded ad if any.
@property (nonatomic, strong, nullable) GADRewardedAd *rewardedAd;

@end

NS_ASSUME_NONNULL_END
