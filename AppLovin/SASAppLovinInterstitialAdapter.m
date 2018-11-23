//
//  SASAppLovinInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAppLovinInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.currentAd = nil;
    
    // Initializing the SDK is done in the base class
    [SASAppLovinBaseAdapter initializeAppLovin];
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Initializing a new interstitial instance
    self.interstitial = [[ALInterstitialAd alloc] initWithSdk:[ALSdk shared]];
    self.interstitial.adDisplayDelegate = self;
    self.interstitial.adLoadDelegate = self;
    
    // And loading an ad using a separate AdService so the ad is not presented immediately
    [[[ALSdk shared] adService] loadNextAd:ALAdSize.sizeInterstitial andNotify:self];
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial showOver:[[UIApplication sharedApplication] keyWindow] andRender:self.currentAd];
}

- (BOOL)isInterstitialReady {
    return self.currentAd != nil;
}

#pragma mark - AppLovin interstitial delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    self.currentAd = ad;
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {    
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:code userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AppLovin Interstitial Error: %ld", (long)code] }];
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:(code == kALErrorCodeNoFill)];
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    self.currentAd = nil;
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
