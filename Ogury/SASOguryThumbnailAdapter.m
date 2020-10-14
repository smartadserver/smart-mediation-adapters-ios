//
//  SASOguryThumbnailAdapter.m
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryThumbnailAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASOguryThumbnailAdapter

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
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
    
    // Thumbnail instantiation and loading
    self.thumbnailAd = [[OguryAdsThumbnailAd alloc] initWithAdUnitID:self.adUnitId];
    self.thumbnailAd.thumbnailAdDelegate = self;
    
    [self.thumbnailAd load:CGSizeMake(self.thumbnailSize.maxWidth, self.thumbnailSize.maxHeight)];
}

#pragma mark - Ogury Thumbnail delegate

- (void)oguryAdsThumbnailAdAdAvailable { }

- (void)oguryAdsThumbnailAdAdNotAvailable {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotAvailable userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Thumbnail - Ad not available"] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)oguryAdsThumbnailAdAdLoaded {
    // Sending a fake banner to the Smart SDK
    [self.delegate mediationBannerAdapter:self didLoadBanner:[[UIView alloc] initWithFrame:CGRectZero]];
    
    // Displaying the thumbnail immediately
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.thumbnailAd show:CGPointMake(self.thumbnailSize.leftMargin, self.thumbnailSize.topMargin)];
    });
}

- (void)oguryAdsThumbnailAdAdNotLoaded {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdNotLoaded userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Thumbnail - Ad not loaded"] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsThumbnailAdAdDisplayed {
    NSLog(@"Ogury Thumbnail - Displayed");
}

- (void)oguryAdsThumbnailAdAdClosed {
    NSLog(@"Ogury Thumbnail - Closed");
}

- (void)oguryAdsThumbnailAdAdError:(OguryAdsErrorType)errorType {
    NSError *error = [NSError errorWithDomain:SASOguryAdapterErrorDomain code:SASOguryAdapterErrorCodeAdError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Ogury Thumbnail - Ad error with type: %ld", errorType] }];
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)oguryAdsThumbnailAdAdClicked {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
