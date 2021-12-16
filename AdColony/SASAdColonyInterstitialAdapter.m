//
//  SASAdColonyInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 20/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdColonyInterstitialAdapter.h"

@implementation SASAdColonyInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    
    // Previous state is reset if any
    self.interstitial = nil;
    
    // Parameter retrieval and validation
    NSError *error = nil;
    if (![self configureIDWithServerParameterString:serverParameterString error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Loading the ad
    [AdColony configureWithAppID:self.appID zoneIDs:@[self.zoneID] options:nil completion:^(NSArray<AdColonyZone *>* zones) {
        [AdColony requestInterstitialInZone:self.zoneID options:nil andDelegate:self];
    }];
    
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial showWithPresentingViewController:viewController];
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (BOOL)isInterstitialReady {
    return self.interstitial != nil;
}

#pragma mark - AdColonyInterstitialDelegate implementation

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
    // Since there is no documented way to to tell if the error is a 'no fill', we always send YES for this parameter.
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    self.interstitial = interstitial;
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial {
    self.interstitial = nil;
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial *)interstitial {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end
