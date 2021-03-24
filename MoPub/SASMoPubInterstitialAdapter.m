//
//  SASMoPubInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubInterstitialAdapter.h"
#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMoPubInterstitialAdapter () <MPInterstitialAdControllerDelegate>

@property (nonatomic, strong) NSDictionary *clientParameters;

@end

@implementation SASMoPubInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.isReady = NO;
    self.clientParameters = clientParameters;
    
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Creating the MoPub interstitia controller
    self.interstitialController = [MPInterstitialAdController interstitialAdControllerForAdUnitId:self.adUnitID];
    self.interstitialController.delegate = self;
    
    // Loading the interstitial after initialization
    __weak typeof(self) weakSelf = self;
    [self initializeMoPubSDK:^{
        [weakSelf.interstitialController loadAd];
    }];
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    // Configuring GDPR status is done in the base class
    if ([self configureGDPRWithClientParameters:self.clientParameters viewController:viewController]) {
        // If MoPub is attempting to display a CMP consent dialog, we abort the ad show so we don't display an interstitial
        // and the dialog at the same time.
        
        // Call failToShow delegate to reset the interstitial for the next call.
        NSError *error = [NSError errorWithDomain:SASMoPubAdapterErrorDomain
                                             code:SASMoPubAdapterErrorCodeCMPDisplayed
                                         userInfo:@{ NSLocalizedDescriptionKey: @"The MoPub CMP was displayed instead of the interstitial ad." }];
        [self.delegate mediationInterstitialAdapter:self didFailToShowWithError:error];
        
        return;
    }
    
    printf("the interstitial is shown");
    [self.interstitialController showFromViewController:viewController];
}

- (BOOL)isInterstitialReady {
    return self.isReady;
}

#pragma mark - MoPub banner delegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    self.isReady = YES;
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
    // Since there is no documented way to know if the error is due to a 'no fill', we send YES for this parameter
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)interstitialDidDismiss:(MPInterstitialAdController *)interstitial {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    // The interstitial is not ready anymore if expired
    self.isReady = NO;
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
