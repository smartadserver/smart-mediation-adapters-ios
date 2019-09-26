//
//  SASGoogleMobileAdsRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Julien Gomez on 26/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASGoogleMobileAdsRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)isRewardedVideoReady { 
    return [self.rewarded isReady];
}

- (void)requestRewardedVideoWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters { 
    
    // Previous state is reset if any
    self.rewarded = nil;
    
    // Parameter retrieval and validation
    NSError *error = nil;
    GoogleMobileAdsType gma = [self configureGoogleMobileAdsWithServerParameterString:serverParameterString error:&error];

    if (GoogleMobileAdsTypeNotInitialized == gma) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Create Google Rewarded Video
    self.rewarded = [GADRewardBasedVideoAd sharedInstance];
    self.rewarded.delegate = self;

    // Create Google Ad Request
    GADRequest *request = [self requestWithClientParameters:clientParameters];
    
    [self.rewarded loadRequest:request withAdUnitID:self.adUnitID];
}

- (void)showRewardedVideoFromViewController:(nonnull UIViewController *)viewController {
    if ([self.rewarded isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:viewController];
    } else {
        // We will send the error if the reward-based video ad has already been presented.
        NSError *error = [NSError errorWithDomain:SASGoogleMobileAdsAdapterErrorDomain
                                             code:SASGoogleMobileAdsAdapterRewardedVideoExpiredOrAlreadyDisplayedErrorCode
                                         userInfo:@{NSLocalizedDescriptionKey: @"Reward video ad has already been shown."}];
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
    }
}

#pragma mark - GADRewardBasedVideoAdDelegate methods

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:(error.code == kGADErrorNoFill)];
}

- (void)rewardBasedVideoAd:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(nonnull GADAdReward *)reward {
    // Convert to SASReward
    SASReward *sasReward = [[SASReward alloc] initWithAmount:[reward.amount copy] currency:[reward.type copy]];
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:sasReward];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    // Nothing to do
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    // Nothing to do
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    // In this case, we track the click
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
