//
//  SASGoogleMobileAdsBannerAdapter.m
//  SmartAdServer
//
//  Created by Julien Gomez on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASGoogleMobileAdsBannerAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:( UIViewController *)viewController {
    
    // Previous state is reset if any
    self.bannerView = nil;
    
    // Parameter retrieval and validation
    NSError *error = nil;
    if (![self configureIDWithServerParameterString:serverParameterString error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Loading the ad
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = self.adUnitID;
    self.bannerView.rootViewController = viewController;
    
    GADRequest *request = [self requestWithClientParameters:clientParameters];
    
    [self.bannerView loadRequest:request];
}

#pragma mark - GMA Banner View Delegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapter:self didLoadBanner:bannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:(error.code == kGADErrorNoFill)];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapterWillPresentModalView:self];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapterWillDismissModalView:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    // Nothing to do
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    // In this case, we track the click
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
