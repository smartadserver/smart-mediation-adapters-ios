//
//  SASFacebookRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASFacebookRewardedVideoAdapter.h"

@implementation SASFacebookRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Configuring Application ID is done in the base class
    [self configurePlacementIDWithServerParameterString:serverParameterString];
    
    // Loading the ad
    self.rewardedVideo = [[FBRewardedVideoAd alloc] initWithPlacementID:self.placementID];
    self.rewardedVideo.delegate = self;
    [self.rewardedVideo loadAd];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    // Showing the rewarded video
    [self.rewardedVideo showAdFromRootViewController:viewController];
    
    // Warning the delegate that the rewarded video has been shown
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (BOOL)isRewardedVideoReady {
    return [self.rewardedVideo isAdValid];
}

#pragma mark - Facebook rewarded video delegate

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:(error.code == SASFacebookAdapterNoFillErrorCode)];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    // Smart AdServer server side reward is used
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:nil];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {
    // Nothing to do because Smart AdServer server side reward is used
}

- (void)rewardedVideoAdServerRewardDidFail:(FBRewardedVideoAd *)rewardedVideoAd {
    // Nothing to do because Smart AdServer server side reward is used
}

@end
