//
//  SASOguryOptinVideoAdapter.m
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryOptinVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASOguryOptinVideoAdapter

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters {
    // Ogury configuration
    NSError *error = nil;
    if (![self configureOgurySDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Optin video instantiation and loading
    self.optInVideo = [[OguryAdsOptinVideo alloc] initWithAdUnitID:self.adUnitId];
    self.optInVideo.optInVideoDelegate = self;
    
    [self.optInVideo load];
}

- (void)showRewardedVideoFromViewController:(nonnull UIViewController *)viewController {
    [self.optInVideo showInViewController:viewController];
}

- (BOOL)isRewardedVideoReady {
    if (self.optInVideo != nil) {
        return [self.optInVideo isLoaded];
    } else {
        return NO;
    }
}

#pragma mark - Ogury optin video delegate

- (void)oguryAdsOptinVideoAdAvailable { }

- (void)oguryAdsOptinVideoAdNotAvailable {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotAvailable userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Rewarded Video - Ad not available"] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)oguryAdsOptinVideoAdLoaded {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)oguryAdsOptinVideoAdNotLoaded {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotLoaded userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Rewarded Video - Ad not loaded"] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsOptinVideoAdDisplayed {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)oguryAdsOptinVideoAdClosed {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
    
    if (self.reward != nil) {
        [self.delegate mediationRewardedVideoAdapter:self didCollectReward:self.reward];
    }
}

- (void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *amount = [formatter numberFromString:item.rewardValue];

    if (amount != nil) {
        self.reward = [[SASReward alloc] initWithAmount:amount currency:item.rewardName];
    }
}

- (void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Rewarded Video - Ad error with type: %ld", errorType] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsOptinVideoAdClicked {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
