//
//  SASVungleInterstitialAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 21/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASVungleInterstitialAdapter.h"
#import <VungleSDK/VungleSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASVungleInterstitialAdapter () <VungleSDKDelegate>

@end

@implementation SASVungleInterstitialAdapter

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)requestInterstitialWithServerParameterString:(nonnull NSString *)serverParameterString clientParameters:(nonnull NSDictionary *)clientParameters {
    // First set the Vungle SDK delegate
    [VungleSDK sharedSDK].delegate = self;
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    NSError *error;
    
    if (![self configureAdapterWithServerParameterString:serverParameterString error:&error]) {
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    if (![[VungleSDK sharedSDK] isInitialized]) {
        if (![[VungleSDK sharedSDK] startWithAppId:self.applicationID error:&error]) {
            // Vungle SDK failed to initialize
            [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
            return;
        }
    } else {
        if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID error:&error]) {
            // Vungle SDK failed to load
            [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
            return;
        }
    }
}

- (BOOL)isInterstitialReady {
    return self.adIsReady;
}

- (void)showInterstitialFromViewController:(nonnull UIViewController *)viewController {
    NSError *error;
    
    if (![[VungleSDK sharedSDK] playAd:viewController options:nil placementID:self.placementID error:&error]) {
        // Vungle SDK failed to show
        [self.delegate mediationInterstitialAdapter:self didFailToShowWithError:error];
    }
}

#pragma mark - Vungle Interstitial Delegate

- (void)vungleSDKDidInitialize {
    NSError *error;
    
    if (![[VungleSDK sharedSDK] loadPlacementWithID:self.placementID error:&error]) {
        // Vungle SDK failed to load
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
    }
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    if (isAdPlayable && [placementID isEqualToString:self.placementID]) {
        // The interstitial is ready to display
        self.adIsReady = YES;
        [self.delegate mediationInterstitialAdapterDidLoad:self];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    if ([placementID isEqualToString:self.placementID]) {
        [self.delegate mediationInterstitialAdapterDidShow:self];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
