//
//  SASAdColonyRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 20/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdColonyRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdColonyRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    
    // Previous state is reset if any
    self.interstitial = nil;
    
    // Parameter retrieval and validation
    NSError *error = nil;
    if (![self configureIDWithServerParameterString:serverParameterString error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // AdColony options
    AdColonyAppOptions *options = [self optionsFromClientParameters:clientParameters];
    
    // Loading the ad
    __weak typeof(self) weakSelf = self;
    [AdColony configureWithAppID:self.appID zoneIDs:@[self.zoneID] options:options completion:^(NSArray<AdColonyZone *>* zones) {
        
        // Fetching reward
        AdColonyZone *zone = [zones firstObject];
        zone.reward = ^(BOOL success, NSString *name, int amount) {
            if (success) {
                [weakSelf rewardedVideoDidCollectRewardWithCurrency:name amount:amount];
            }
        };
        
        // Ad loading
        [AdColony requestInterstitialInZone:self.zoneID options:nil success:^(AdColonyInterstitial *ad) {
            [weakSelf rewardedVideoDidFinishLoading:ad];
        } failure:^(AdColonyAdRequestError *error) {
            [weakSelf rewardedVideoDidFailWithError:error];
        }];
        
    }];
    
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.interstitial showWithPresentingViewController:viewController];
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (BOOL)isRewardedVideoReady {
    return self.interstitial != nil;
}

#pragma mark - Ad events

- (void)rewardedVideoDidFinishLoading:(AdColonyInterstitial *)ad {
    self.interstitial = ad;
    
    __weak typeof(self) weakSelf = self;
    self.interstitial.close = ^{
        [weakSelf rewardedVideoDidClose];
    };
    self.interstitial.click = ^{
        [weakSelf rewardedVideoDidReceiveClickEvent];
    };
    
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)rewardedVideoDidFailWithError:(AdColonyAdRequestError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
    // Since there is no documented way to to tell if the error is a 'no fill', we always send YES for this parameter.
}

- (void)rewardedVideoDidCollectRewardWithCurrency:(NSString *)currency amount:(int)amount {
    SASReward *reward = [[SASReward alloc] initWithAmount:[NSNumber numberWithInteger:amount] currency:currency];
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:reward];
}

- (void)rewardedVideoDidClose {
    self.interstitial = nil;
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

- (void)rewardedVideoDidReceiveClickEvent {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
