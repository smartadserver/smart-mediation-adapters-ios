//
//  SASAppLovinRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAppLovinRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.isReady = NO;
    
    // Initializing the SDK is done in the base class
    [SASAppLovinBaseAdapter initializeAppLovin];
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Instantiating & loading a rewarded video ad
    self.rewardedVideo = [[ALIncentivizedInterstitialAd alloc] initWithSdk:[ALSdk shared]];
    self.rewardedVideo.adDisplayDelegate = self;
    [self.rewardedVideo preloadAndNotify:self];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.rewardedVideo showAndNotify:self];
}

- (BOOL)isRewardedVideoReady {
    return self.isReady;
}

#pragma mark - AppLovin rewarded video delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    self.isReady = YES;
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:code userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AppLovin RewardedVideo Error: %ld", (long)code] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:(code == kALErrorCodeNoFill)];
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    self.isReady = NO;
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    // A reward is provided by AppLovin, we can use it instead of relying on a Smart reward.
    NSString *currency = [response objectForKey: @"currency"];
    NSNumber *amount = [NSNumber numberWithFloat:[[response objectForKey: @"amount"] floatValue]];
    
    SASReward *reward = [[SASReward alloc] initWithAmount:amount currency:currency];
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:reward];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    // If the reward fails for any reason, the adapter should fail to show with a relevant error
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:SASAppLovinAdapterErrorCodeUnableToGetReward userInfo:@{ NSLocalizedDescriptionKey: SASAppLovinAdapterErrorMessageUnableToGetReward }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    // If the reward fails for any reason, the adapter should fail to show with a relevant error
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:SASAppLovinAdapterErrorCodeUnableToGetReward userInfo:@{ NSLocalizedDescriptionKey: SASAppLovinAdapterErrorMessageUnableToGetReward }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    // If the reward fails for any reason, the adapter should fail to show with a relevant error
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:SASAppLovinAdapterErrorCodeUnableToGetReward userInfo:@{ NSLocalizedDescriptionKey: SASAppLovinAdapterErrorMessageUnableToGetReward }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)userDeclinedToViewAd:(ALAd *)ad {
    // If the reward fails for any reason, the adapter should fail to show with a relevant error
    self.isReady = NO;
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:SASAppLovinAdapterErrorCodeUserDeclinedToViewAd userInfo:@{ NSLocalizedDescriptionKey: SASAppLovinAdapterErrorMessageUserDeclinedToViewAd }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

@end

NS_ASSUME_NONNULL_END
