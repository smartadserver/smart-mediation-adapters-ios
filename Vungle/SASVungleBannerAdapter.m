//
//  SASVungleBannerAdapter.m
//  AdViewer
//
//  Created by glaubier on 27/10/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASVungleBannerAdapter.h"
#import <VungleSDK/VungleSDK.h>

@interface SASVungleBannerAdapter () <VungleSDKDelegate>

@property (nonatomic, assign) VungleAdSize bannerAdSize;

@end

@implementation SASVungleBannerAdapter

- (instancetype)initWithDelegate:(nonnull id<SASMediationBannerAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)requestBannerWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters viewController:(nonnull UIViewController *)viewController {
    // First set the Vungle SDK delegate
    [VungleSDK sharedSDK].delegate = self;
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    NSError *error;
    
    if (![self configureAdapterWithServerParameterString:serverParameterString error:&error]) {
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // init banner ad size
    switch (self.bannerAdSizeIndex) {
        case 1:
            self.bannerAdSize = VungleAdSizeBannerShort;
            break;
        case 2:
            self.bannerAdSize = VungleAdSizeBannerLeaderboard;
            break;
        default:
            self.bannerAdSize = VungleAdSizeBanner;
    }
    
    if (![[VungleSDK sharedSDK] isInitialized]) {
        if (![[VungleSDK sharedSDK] startWithAppId:self.applicationID error:&error]) {
            // Vungle SDK failed to initialize
            [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
            return;
        }
    } else {
        if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID withSize:self.bannerAdSize error:&error]) {
            // Vungle SDK failed to load
            [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
            return;
        }
    }
}

#pragma mark - Vungle Banner Delegate

- (void)vungleSDKDidInitialize {
    NSError *error;
    
    if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID withSize:self.bannerAdSize error:&error]) {
        // Vungle SDK failed to load
        [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:YES];
    }
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error {
    if (isAdPlayable && [placementID isEqualToString:self.placementID]) {
        // The banner is ready to display
        
        CGRect bannerSize;
        
        switch (self.bannerAdSize) {
            case VungleAdSizeBannerShort:
                bannerSize = CGRectMake(0, 0, 300, 50);
                break;
            case VungleAdSizeBannerLeaderboard:
                bannerSize = CGRectMake(0, 0, 728, 90);
                break;
            default:
                bannerSize = CGRectMake(0, 0, 320, 50);
        }
        
        UIView *bannerView = [[UIView alloc] initWithFrame:bannerSize];
        
        NSError *error;
        
        if (![[VungleSDK sharedSDK] addAdViewToView:bannerView withOptions:nil placementID:self.placementID error:&error]) {
            [self.delegate mediationBannerAdapter:self didFailToLoadWithError:error noFill:NO];
        } else {
            [self.delegate mediationBannerAdapter:self didLoadBanner:bannerView];
        }
    }
}

@end
