//
//  SASFacebookInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASFacebookInterstitialAdapter.h"

@implementation SASFacebookInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Configuring Application ID is done in the base class
    [self configurePlacementIDWithServerParameterString:serverParameterString];
    
    // Loading the ad
    self.interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.placementID];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    // Showing the interstitial
    [self.interstitial showAdFromRootViewController:viewController];
    
    // Warning the delegate that the interstitial has been shown
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (BOOL)isInterstitialReady {
    return [self.interstitial isAdValid];
}

#pragma mark - Facebook interstitial delegate

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:(error.code == SASFacebookAdapterNoFillErrorCode)];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

@end
