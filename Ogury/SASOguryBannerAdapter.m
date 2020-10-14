//
//  SASOguryBannerAdapter.m
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASOguryBannerAdapter

- (nonnull instancetype)initWithDelegate:(nonnull id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters viewController:(nonnull UIViewController *)viewController {
    // Ogury configuration
    NSError *error = nil;
    if (![self configureOgurySDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Checking the bannerSize parameter
    if (self.bannerSize == nil) {
        // Configuration can fail if the serverParameterString does not contains a valid banner size
        NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Banner loading
    self.banner = [[OguryAdsBanner alloc] initWithAdUnitID:self.adUnitId];
    self.banner.bannerDelegate = self;
    
    [self.banner loadWithSize:self.bannerSize];
}

#pragma mark - Ogury banner delegate

- (void)oguryAdsBannerAdAvailable:(OguryAdsBanner*)bannerAds { }

- (void)oguryAdsBannerAdNotAvailable:(OguryAdsBanner*)bannerAds {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotAvailable userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Banner - Ad not available"] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)oguryAdsBannerAdLoaded:(OguryAdsBanner*)bannerAds {
    [self.delegate mediationBannerAdapter:self didLoadBanner:self.banner];
}

- (void)oguryAdsBannerAdNotLoaded:(OguryAdsBanner*)bannerAds {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotLoaded userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Banner - Ad not loaded"] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsBannerAdDisplayed:(OguryAdsBanner*)bannerAds { }

- (void)oguryAdsBannerAdClosed:(OguryAdsBanner*)bannerAds { }

- (void)oguryAdsBannerAdClicked:(OguryAdsBanner*)bannerAds {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

- (void)oguryAdsBannerAdError:(OguryAdsErrorType)errorType forBanner:(OguryAdsBanner*)bannerAds {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Banner - Ad error with type: %ld", errorType] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
}

@end

NS_ASSUME_NONNULL_END
