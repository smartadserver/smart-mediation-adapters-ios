//
//  SASInMobiBannerAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASInMobiBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASInMobiBannerAdapter

- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:(UIViewController *)viewController {
    // Start by configuring the InMobiSDK
    NSError *error = nil;
    if (![self configureInMobiSDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    CGSize bannerSize = [clientParameters[@"adViewSize"] CGSizeValue];
    
    // Instantiate IMBanner
    self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, bannerSize.width, bannerSize.height) placementId:self.placementID delegate:self];
    
    // Load banner
    [self.banner load];
}

#pragma mark - IMBannerDelegate

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    if (error.code == kIMStatusCodeNoFill) {
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
    } else {
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
    }
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params {
    [self.delegate mediationBannerAdapterDidReceiveAdClickedEvent:self];
}

- (void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    // Nothing to do here
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    // Nothing to do here
}

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    [self.delegate mediationBannerAdapter:self didLoadBanner:banner];
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
    // Nothing to do here
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    // Nothing to do here
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    // Nothing to do here
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    // Nothing to do here
}

@end

NS_ASSUME_NONNULL_END
