//
//  SASMoPubBannerAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASMoPubBannerAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:(UIViewController *)viewController {
    self.viewController = viewController;
    
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Configuring GDPR status is done in the base class
    // For banners, we don't have to check if a CMP has been displayed by MoPub because the banner will still
    // be able to load under it anyway.
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Creating a container view to center the MoPub banner:
    // The view returned to the SDK is automatically stretched to fit the SASBannerView instance. But since MoPub
    // banners are always fixed size, it is better to return a view containing the MoPub banner (using the relevant
    // autoresizing mask) instead of the MoPub banner itself.
    CGSize containerSize = [[clientParameters objectForKey:SASMediationClientParameterAdViewSize] CGSizeValue];
    self.bannerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
    
    // Creating the MoPub banner view
    CGSize actualBannerSize = [self moPubFromAdViewSize:[clientParameters objectForKey:SASMediationClientParameterAdViewSize]];
    self.bannerView = [[MPAdView alloc] initWithAdUnitId:self.adUnitID size:actualBannerSize];
    self.bannerView.delegate = self;
    [self.bannerView stopAutomaticallyRefreshingContents];
    
    // Positioning the banner on the container
    self.bannerView.frame = CGRectMake((containerSize.width - actualBannerSize.width) / 2, (containerSize.height - actualBannerSize.height) / 2, actualBannerSize.width, actualBannerSize.height);
    self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.bannerContainerView addSubview:self.bannerView];
    
    // Loading the banner after initialization
    __weak typeof(self) weakSelf = self;
    [self initializeMoPubSDK:^{
        [weakSelf.bannerView loadAd];
    }];
}

#pragma mark - MoPub banner delegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self.viewController;
}

- (void)adViewDidLoadAd:(MPAdView *)view {
    [self.delegate mediationBannerAdapter:self didLoadBanner:self.bannerContainerView]; // we are returning the container here, not the actual banner
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    NSError *error = [NSError errorWithDomain:SASMoPubAdapterErrorDomain code:SASMoPubAdapterErrorCodeNoAd userInfo:@{ NSLocalizedDescriptionKey: @"Unable to fetch ad from MoPub" }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
    // Since there is no documented way to know if the error is due to a 'no fill', we send YES for this parameter
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    [self.delegate mediationBannerAdapterWillPresentModalView:self];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    [self.delegate mediationBannerAdapterWillDismissModalView:self];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

#pragma mark - Utils methods

- (CGSize)moPubFromAdViewSize:(nullable NSValue *)adViewSize {
    if (adViewSize == nil) {
        // Default size
        return MOPUB_BANNER_SIZE;
    }
    
    CGFloat bannerWidth = [adViewSize CGSizeValue].width;
    CGFloat bannerHeight = [adViewSize CGSizeValue].height;
    
    if (bannerHeight > bannerWidth) {
        return MOPUB_WIDE_SKYSCRAPER_SIZE;
    } else if (bannerHeight >= 300 && bannerWidth >= 250) {
        return MOPUB_MEDIUM_RECT_SIZE;
    } else {
        return MOPUB_BANNER_SIZE;
    }
}

@end

NS_ASSUME_NONNULL_END
