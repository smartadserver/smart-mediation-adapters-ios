//
//  SASFacebookBannerAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASFacebookBannerAdapter.h"

@implementation SASFacebookBannerAdapter

#pragma mark - Mediation adapter protocol implementation

- (void)dealloc {
    [self.bannerView removeFromSuperview];
}

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:(UIViewController *)viewController {
    self.viewController = viewController;
    
    // Configuring Application ID is done in the base class
    [self configurePlacementIDWithServerParameterString:serverParameterString];
    
    // Loading the ad
    self.bannerView = [[FBAdView alloc] initWithPlacementID:self.placementID adSize:[self FBAdSizeFromAdViewSize:[clientParameters objectForKey:SASMediationClientParameterAdViewSize]] rootViewController:viewController];
    self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

#pragma mark - Facebook ad view delegate

- (void)adViewDidLoad:(FBAdView *)adView {
    [self.delegate mediationBannerAdapter:self didLoadBanner:adView];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:(error.code == SASFacebookAdapterNoFillErrorCode)];
}

- (void)adViewDidClick:(FBAdView *)adView {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self.viewController;
}

#pragma mark - Utils methods

- (FBAdSize)FBAdSizeFromAdViewSize:(nullable NSValue *)adViewSize {
    if (adViewSize == nil) {
        // Default size
        return kFBAdSizeHeight50Banner;
    }
    
    CGFloat bannerWidth = [adViewSize CGSizeValue].width;
    CGFloat bannerHeight = [adViewSize CGSizeValue].height;
    
    if (bannerHeight >= 250 && bannerWidth >= 250) {
        return kFBAdSizeHeight250Rectangle;
    } else if (bannerHeight >= 90) {
        return kFBAdSizeHeight90Banner;
    } else {
        return kFBAdSizeHeight50Banner;
    }
}

@end
