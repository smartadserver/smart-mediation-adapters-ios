//
//  SASInMobiInterstitialAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASInMobiInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASInMobiInterstitialAdapter

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Start by configuring the InMobi SDK
    NSError *error;
    if (![self configureInMobiSDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Instantiate IMInterstitial
    self.interstitial = [[IMInterstitial alloc] initWithPlacementId:self.placementID delegate:self];
    
    // Load the interstitial
    [self.interstitial load];
}

- (BOOL)isInterstitialReady {
    if (self.interstitial != nil) {
        return [self.interstitial isReady];
    }
    return false;
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial showFromViewController:viewController];
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    [self.delegate mediationInterstitialAdapter:self didFailToShowWithError:error];
}

- (void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
