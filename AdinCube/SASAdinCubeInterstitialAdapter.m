//
//  SASAdinCubeInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 07/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeInterstitialAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdinCubeInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Loading ad…
    self.interstitial = [AdinCube Interstitial];
    self.interstitial.delegate = self;
    [self.interstitial initialize];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller {
    [self.interstitial show:controller];
}

- (BOOL)isInterstitialReady {
    return [self.interstitial isReady];
}

#pragma mark - AdinCube interstitial delegate

- (void)didCacheInterstitial {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)didShowInterstitial {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)didFailToShowInterstitial:(nonnull NSString *)errorCode {
    NSError *error = [NSError errorWithDomain:SASAdinCubeAdapterErrorDomain code:[errorCode integerValue] userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AdInCube Banner Error: %@", errorCode] }];
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:[errorCode isEqualToString:SASAdinCubeAdapterNoFillErrorCode]];
}

- (void)didClickOnInterstitial {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

- (void)didHideInterstitial {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
