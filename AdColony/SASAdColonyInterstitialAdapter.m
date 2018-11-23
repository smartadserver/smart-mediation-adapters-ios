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
    
    // AdColony options
    AdColonyAppOptions *options = [self optionsFromClientParameters:clientParameters];
    
    // Loading the ad
    __weak typeof(self) weakSelf = self;
    [AdColony configureWithAppID:self.appID zoneIDs:@[self.zoneID] options:options completion:^(NSArray<AdColonyZone *>* zones) {
        
        [AdColony requestInterstitialInZone:self.zoneID options:nil success:^(AdColonyInterstitial *ad) {
            [weakSelf interstitialDidFinishLoading:ad];
        } failure:^(AdColonyAdRequestError *error) {
            [weakSelf interstitialDidFailWithError:error];
        }];
        
    }];
    
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial showWithPresentingViewController:viewController];
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (BOOL)isInterstitialReady {
    return self.interstitial != nil;
}

#pragma mark - Ad events

- (void)interstitialDidFinishLoading:(AdColonyInterstitial *)ad {
    self.interstitial = ad;
    
    __weak typeof(self) weakSelf = self;
    self.interstitial.close = ^{
        [weakSelf interstitialDidClose];
    };
    self.interstitial.click = ^{
        [weakSelf interstitialDidReceiveClickEvent];
    };
    
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)interstitialDidFailWithError:(AdColonyAdRequestError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
    // Since there is no documented way to to tell if the error is a 'no fill', we always send YES for this parameter.
}

- (void)interstitialDidClose {
    self.interstitial = nil;
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)interstitialDidReceiveClickEvent {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end
