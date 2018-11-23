//
//  SASAdinCubeBannerAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 06/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdinCubeBannerAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:(UIViewController *)viewController {
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Loading ad…
    self.bannerView = [[AdinCube Banner] createView:[self adSize] rootViewController:viewController];
    self.bannerView.delegate = self;
    [self.bannerView load];
}

- (AdinCubeBannerSize)adSize {
    return AdinCubeBannerSizeAuto;
}

#pragma mark - AdinCube banner delegate

- (void)didLoadBanner:(AdinCubeBannerView *)bannerView {
    [self.delegate mediationBannerAdapter:self didLoadBanner:bannerView];
}


- (void)didFailToLoadBanner:(AdinCubeBannerView *)bannerView withError:(NSString *)errorCode {
    NSError *error = [NSError errorWithDomain:SASAdinCubeAdapterErrorDomain code:[errorCode integerValue] userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AdInCube Banner Error: %@", errorCode] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:[errorCode isEqualToString:SASAdinCubeAdapterNoFillErrorCode]];
}


- (void)didShowBanner:(AdinCubeBannerView *)bannerView {
    // Nothing to do here
}


- (void)didFailToShowBanner:(AdinCubeBannerView *)bannerView withError:(NSString*)errorCode {
    // Nothing to do here
}


- (void)didClickOnBanner:(AdinCubeBannerView *)bannerView {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
