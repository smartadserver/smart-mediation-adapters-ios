//
//  SASVungleRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 21/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASVungleRewardedVideoAdapter.h"
#import <VungleSDK/VungleSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASVungleRewardedVideoAdapter () <VungleSDKDelegate>

@end

@implementation SASVungleRewardedVideoAdapter

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters {
    // First set the Vungle SDK delegate
    [VungleSDK sharedSDK].delegate = self;
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    NSError *error;
    
    if (![self configureAdapterWithServerParameterString:serverParameterString error:&error]) {
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    if (![[VungleSDK sharedSDK] isInitialized]) {
        if (![[VungleSDK sharedSDK] startWithAppId:self.applicationID error:&error]) {
            // Vungle SDK failed to initialize
            [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
            return;
        }
    } else {
        if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID error:&error]) {
            // Vungle SDK failed to load
            [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
            return;
        }
    }
}

- (BOOL)isRewardedVideoReady {
    return self.adIsReady;
}

- (void)showRewardedVideoFromViewController:(nonnull UIViewController *)viewController {
    NSError *error;
    
    if (![[VungleSDK sharedSDK] playAd:viewController options:nil placementID:self.placementID error:&error]) {
        // Vungle SDK failed to show
        [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
    }
}

#pragma mark - Vungle Rewarded Video Delegate

- (void)vungleSDKDidInitialize {
    NSError *error;
    
    if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID error:nil]) {
        // Vungle SDK failed to load
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
    }
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    if (isAdPlayable && [placementID isEqualToString:self.placementID]) {
        // The interstitial is ready to display
        self.adIsReady = YES;
        [self.delegate mediationRewardedVideoAdapterDidLoad:self];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    if ([placementID isEqualToString:self.placementID]) {
        [self.delegate mediationRewardedVideoAdapterDidShow:self];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    // Check if the ad is completed or downloaded
    if ([info.completedView boolValue] || [info.didDownload boolValue]) {
        // No reward are provided by Vungle, so we use the one set on Manage.
        [self.delegate mediationRewardedVideoAdapter:self didCollectReward:nil];
    }
    
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
