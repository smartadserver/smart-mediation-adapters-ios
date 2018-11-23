//
//  SASAppLovinRewardedVideoAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

#define SASAppLovinAdapterErrorCodeUserDeclinedToViewAd         1000
#define SASAppLovinAdapterErrorMessageUserDeclinedToViewAd      @"User declined to view rewarded video ad"

#define SASAppLovinAdapterErrorCodeUnableToGetReward            1001
#define SASAppLovinAdapterErrorMessageUnableToGetReward         @"Unable to get a valid reward from AppLovin"

NS_ASSUME_NONNULL_BEGIN

/**
 AppLovin rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAppLovinRewardedVideoAdapter : SASAppLovinBaseAdapter <SASMediationRewardedVideoAdapter, ALAdLoadDelegate, ALAdDisplayDelegate, ALAdRewardDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationRewardedVideoAdapterDelegate> delegate;

/// The currently loaded AppLovin rewarded video if any.
@property (nonatomic, strong, nullable) ALIncentivizedInterstitialAd *rewardedVideo;

/// YES if an ad is ready to be displayed, NO otherwise.
@property (nonatomic, assign) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
