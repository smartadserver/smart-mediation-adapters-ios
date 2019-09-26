//
//  SASGoogleMobileAdsInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Julien Gomez on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASGoogleMobileAdsInterstitialAdapter

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
    GoogleMobileAdsType gmaType = [self configureGoogleMobileAdsWithServerParameterString:serverParameterString error:&error];
    
    if (GoogleMobileAdsTypeNotInitialized == gmaType) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    if (GoogleMobileAdsTypeAdMob == gmaType) {
        // Create Google Interstitial
        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitID];
    } else if (GoogleMobileAdsTypeAdManager == gmaType) {
        // Create Google DFP Interstitial
        self.interstitial =  [[DFPInterstitial alloc] initWithAdUnitID:self.adUnitID];
    }
    
    self.interstitial.delegate = self;

    // Create Google Ad Request
    GADRequest *request = [self requestWithClientParameters:clientParameters];
    
    // Perform ad request
    [self.interstitial loadRequest:request];
   
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial presentFromRootViewController:viewController];
}

- (BOOL)isInterstitialReady {
    return [self.interstitial isReady];
}

#pragma mark - GMA Banner View Delegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:(error.code == kGADErrorNoFill)];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    // In this case, we track the click
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
