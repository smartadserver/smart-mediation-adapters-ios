//
//  SASMoPubRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubRewardedVideoAdapter.h"
#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMoPubRewardedVideoAdapter () <MPRewardedAdsDelegate>

@property (nonatomic, strong) NSDictionary *clientParameters;

@end

@implementation SASMoPubRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.clientParameters = clientParameters;
    
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Rewarded video configuration
    [MPRewardedAds setDelegate:self forAdUnitId:self.adUnitID];
    
    // An ad might already be ready for this placement, if this is the case, we don't load another one because it will fail
    if ([self isRewardedVideoReady]) {
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
        return;
    }
    
    // Loading the rewarded videoafter initialization
    __weak typeof(self) weakSelf = self;
    [self initializeMoPubSDK:^{
        [MPRewardedAds loadRewardedAdWithAdUnitID:weakSelf.adUnitID withMediationSettings:@[]];
    }];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    // Configuring GDPR status is done in the base class
    if ([self configureGDPRWithClientParameters:self.clientParameters viewController:viewController]) {
        // If MoPub is attempting to display a CMP consent dialog, we abort the ad show so we don't display an interstitial
        // and the dialog at the same time.
        
        // Call failToShow delegate to reset the rewarded video for the next call.
        NSError *error = [NSError errorWithDomain:SASMoPubAdapterErrorDomain
                                             code:SASMoPubAdapterErrorCodeCMPDisplayed
                                         userInfo:@{ NSLocalizedDescriptionKey: @"The MoPub CMP was displayed instead of the rewarded video ad." }];
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
        
        return;
    }
    
    if ([self isRewardedVideoReady]) {
        NSArray *rewards = [MPRewardedAds availableRewardsForAdUnitID:self.adUnitID];
        [MPRewardedAds presentRewardedAdForAdUnitID:self.adUnitID fromViewController:viewController withReward:rewards.firstObject];
    }
}

- (BOOL)isRewardedVideoReady {
    return [MPRewardedAds hasAdAvailableForAdUnitID:self.adUnitID];
}

#pragma mark - MoPub banner delegate

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
    }
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
        // Since there is no documented way to know if the error is due to a 'no fill', we send YES for this parameter
    }
}

- (void)rewardedAdDidFailToShowForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
    }
}

- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidShow:self];
    }
}

- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidClose:self];
    }
}

- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
    }
}

- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward {
    if ([adUnitID isEqualToString:self.adUnitID]) {
        [self.delegate mediationRewardedVideoAdapter:self didCollectReward:[[SASReward alloc] initWithAmount:reward.amount currency:reward.currencyType]];
    }
}

@end

NS_ASSUME_NONNULL_END
