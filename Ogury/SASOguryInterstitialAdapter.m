//
//  SASOguryInterstitialAdapter.m
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 29/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASOguryInterstitialAdapter

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Ogury configuration
    NSError *error = nil;
    if (![self configureOgurySDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Interstitial instantiation and loading
    self.interstitial = [[OguryAdsInterstitial alloc] initWithAdUnitID:self.adUnitId];
    self.interstitial.interstitialDelegate = self;
    
    [self.interstitial load];
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.interstitial showInViewController:viewController];
}

- (BOOL)isInterstitialReady {
    if (self.interstitial != nil) {
        return self.interstitial.isLoaded;
    } else {
        return NO;
    }
}

#pragma mark - Ogury interstitial delegate

- (void)oguryAdsInterstitialAdAvailable { }

- (void)oguryAdsInterstitialAdNotAvailable {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotAvailable userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Interstitial - Ad not available"] }];
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)oguryAdsInterstitialAdLoaded {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)oguryAdsInterstitialAdNotLoaded {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotLoaded userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Interstitial - Ad not loaded"] }];
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsInterstitialAdDisplayed {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)oguryAdsInterstitialAdClosed {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

- (void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Interstitial - Ad error with type: %ld", errorType] }];
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsInterstitialAdClicked {
    [self.delegate mediationInterstitialAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
