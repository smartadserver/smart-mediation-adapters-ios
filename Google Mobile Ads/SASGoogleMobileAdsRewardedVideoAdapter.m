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
    return self.rewardedAd != nil;
}

- (void)requestRewardedVideoWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters { 
    
    // Previous state is reset if any
    self.rewardedAd = nil;
    
    // Parameter retrieval and validation
    NSError *error = nil;
    GoogleMobileAdsType gma = [self configureGoogleMobileAdsWithServerParameterString:serverParameterString error:&error];

    if (GoogleMobileAdsTypeNotInitialized == gma) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Create Google Ad Request
    GADRequest *request = [self requestWithClientParameters:clientParameters];
    
    // Create Google Rewarded Video
    [GADRewardedAd loadWithAdUnitID:self.adUnitID request:request completionHandler:^(GADRewardedAd *rewardedAd, NSError *error) {
        // No ad fetched
        if (error) {
            [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:(error.code == GADErrorNoFill)];
            return;
        }
        
        // Ad fetched
        self.rewardedAd = rewardedAd;
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
    }];
    
}

- (void)showRewardedVideoFromViewController:(nonnull UIViewController *)viewController {
    if ([self isRewardedVideoReady]) {
        self.rewardedAd.fullScreenContentDelegate = self;
        [self.rewardedAd presentFromRootViewController:viewController userDidEarnRewardHandler:^{
            SASReward *sasReward = [[SASReward alloc] initWithAmount:[self.rewardedAd.adReward.amount copy] currency:[self.rewardedAd.adReward.type copy]];
            [self.delegate mediationRewardedVideoAdapter:self didCollectReward:sasReward];
        }];
    } else {
        // We will send the error if the reward-based video ad has already been presented.
        NSError *error = [NSError errorWithDomain:SASGoogleMobileAdsAdapterErrorDomain
                                             code:SASGoogleMobileAdsAdapterRewardedVideoExpiredOrAlreadyDisplayedErrorCode
                                         userInfo:@{NSLocalizedDescriptionKey: @"Reward video ad has already been shown."}];
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
    }
}

#pragma mark - GMA Fullscreen ad delegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    // not used
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
