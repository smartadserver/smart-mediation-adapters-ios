//
//  SASAdinCubeRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 10/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdinCubeRewardedVideoAdapter

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
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Loading ad…
    self.rewarded = [AdinCube Rewarded];
    self.rewarded.delegate = self;
    [self.rewarded fetch];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)controller {
    [self.rewarded show:controller];
}

- (BOOL)isRewardedVideoReady {
    return [self.rewarded isReady];
}

#pragma mark - AdinCube rewarded video delegate

- (void)didCompleteRewarded {
     // Using Smart server side reward since AdinCube don't provide any reward value
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:nil];
}

- (void)didFetchRewarded {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)didFailToFetchRewarded:(nonnull NSString *)errorCode {
    NSError *error = [NSError errorWithDomain:SASAdinCubeAdapterErrorDomain code:[errorCode integerValue] userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AdInCube Banner Error: %@", errorCode] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:[errorCode isEqualToString:SASAdinCubeAdapterNoFillErrorCode]];
}

- (void)didShowRewarded {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)didFailToShowRewarded:( NSString *)errorCode {
    NSError *error = [NSError errorWithDomain:SASAdinCubeAdapterErrorDomain code:[errorCode integerValue] userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AdInCube Banner Error: %@", errorCode] }];
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)didClickOnRewarded {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

- (void)didHideRewarded {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
