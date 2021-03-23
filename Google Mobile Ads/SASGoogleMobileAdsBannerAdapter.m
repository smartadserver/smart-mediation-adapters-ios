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
    GoogleMobileAdsType gmaType = [self configureGoogleMobileAdsWithServerParameterString:serverParameterString error:&error];
    
    if (GoogleMobileAdsTypeNotInitialized == gmaType) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    GADAdSize adSize = [self bannerSize:serverParameterString];
    if (GoogleMobileAdsTypeAdMob == gmaType) {
        // Create Google Banner View and configure it.
        self.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];

    } else if (GoogleMobileAdsTypeAdManager == gmaType) {
        // Create Google DFP Banner View and configure it.
        self.bannerView =  [[GAMBannerView alloc] initWithAdSize:adSize];
    }
    
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = self.adUnitID;
    self.bannerView.rootViewController = viewController;

    // Create Google Ad Request
    GADRequest *request = [self requestWithClientParameters:clientParameters];
    
    // Perform ad request
    [self.bannerView loadRequest:request];
}

#pragma mark - GMA Banner size util method

- (GADAdSize)bannerSize:(NSString *)serverParameterString {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"|"];
    NSInteger bannerSizeIndex = 0;
    if ([serverParameters count] > 2) {
        // Extracting banner size
        bannerSizeIndex = ((NSString *)serverParameters[2]).integerValue;
    }
    switch (bannerSizeIndex) {
        case 1:
            return kGADAdSizeMediumRectangle;
        case 2:
            return kGADAdSizeLeaderboard;
        case 3:
            return kGADAdSizeLargeBanner;
        default:
            return kGADAdSizeBanner;
    }
}


#pragma mark - GMA Banner View Delegate

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapter:self didLoadBanner:bannerView];
}

- (void)bannerView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error {
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:(error.code == GADErrorNoFill)];
}

- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapterWillPresentModalView:self];
}

- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate mediationBannerAdapterWillDismissModalView:self];
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    // Nothing to do
}

@end

NS_ASSUME_NONNULL_END
