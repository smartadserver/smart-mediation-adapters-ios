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
        // Create Google Ad Request
        GADRequest *request = [self requestWithClientParameters:clientParameters];
        // Perform ad request
        [GADInterstitialAd loadWithAdUnitID:self.adUnitID request:request completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
              [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:(error.code == GADErrorNoFill)];
              return;
            }
            [self.delegate mediationInterstitialAdapterDidLoad:self];
            self.interstitial = interstitialAd;
            self.interstitial.fullScreenContentDelegate = self;
        }];
    } else if (GoogleMobileAdsTypeAdManager == gmaType) {
        // Create Google Ad Request
        GAMRequest *request = (GAMRequest*)[self requestWithClientParameters:clientParameters];
        // Perform ad request
        [GAMInterstitialAd loadWithAdManagerAdUnitID:self.adUnitID request:request completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
              [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:(error.code == GADErrorNoFill)];
              return;
            }
            [self.delegate mediationInterstitialAdapterDidLoad:self];
            self.interstitial = interstitialAd;
            self.interstitial.fullScreenContentDelegate = self;
        }];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial presentFromRootViewController:viewController];
}

- (BOOL)isInterstitialReady {
    return self.interstitial != nil;
}

#pragma mark - GADFullScreenContentDelegate Delegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    // not used
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToShowWithError:error];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}


@end

NS_ASSUME_NONNULL_END
