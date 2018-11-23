//
//  SASMoPubRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASMoPubRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Configuring GDPR status is done in the base class
    if ([self configureGDPRWithClientParameters:clientParameters]) {
        // If MoPub is attempting to display a CMP consent dialog, we abort the ad call so we don't display an interstitial
        // and the dialog at the same time.
        return;
    }
    
    // Rewarded video configuration
    [MPRewardedVideo setDelegate:self forAdUnitId:self.adUnitID];
    
    // An ad might already be ready for this placement, if this is the case, we don't load another one because it will fail
    if ([self isRewardedVideoReady]) {
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
        return;
    }
    
    // Loading the rewarded videoafter initialization
    __weak typeof(self) weakSelf = self;
    [self initializeMoPubSDK:^{
        [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:weakSelf.adUnitID withMediationSettings:@[]];
    }];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    if ([self isRewardedVideoReady]) {
        NSArray *rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.adUnitID];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.adUnitID fromViewController:viewController withReward:rewards.firstObject];
    }
}

- (BOOL)isRewardedVideoReady {
    return [MPRewardedVideo hasAdAvailableForAdUnitID:self.adUnitID];
}

#pragma mark - MoPub banner delegate

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
    }
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
        // Since there is no documented way to know if the error is due to a 'no fill', we send YES for this parameter
    }
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
    }
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidShow:self];
    }
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidClose:self];
    }
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
    }
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didCollectReward:[[SASReward alloc] initWithAmount:reward.amount currency:reward.currencyType]];
    }
}

@end

NS_ASSUME_NONNULL_END
