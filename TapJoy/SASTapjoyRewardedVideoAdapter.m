//
//  SASTapjoyRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASTapjoyRewardedVideoAdapter.h"
#import <Tapjoy/Tapjoy.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASTapjoyRewardedVideoAdapter () <TJPlacementDelegate, TJPlacementVideoDelegate>

@end

@implementation SASTapjoyRewardedVideoAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Extracting various IDs from the server parameter string is done in the base class
    NSError *error;
    if (![self configureIDWithServerParameterString:serverParameterString error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Configuring GDPR status is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Handling connection is done in the base class
    [self connectTapjoySDK];
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.placement showContentWithViewController:viewController];
}

- (BOOL)isRewardedVideoReady {
    return [self.placement isContentReady];
}

#pragma mark - Connection methods

- (void)connectionDidSucceed {
    // The Tapjoy SDK is connected, an ad request can be made
    self.placement = [TJPlacement placementWithName:self.placementName delegate:self];
    self.placement.videoDelegate = self;
    [self.placement requestContent];
}

- (void)connectionDidFailWithError:(NSError *)error {
    // No connection is considered as a loading error
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
}

#pragma mark - Tapjoy events

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (![placement isContentAvailable]) {
        NSError *error = [NSError errorWithDomain:SASTapjoyAdapterErrorDomain
                                             code:SASTapjoyAdapterErrorCodeFailedToLoadRewardedAd
                                         userInfo:@{NSLocalizedDescriptionKey: SASTapjoyAdapterErrorMessageFailedToLoadRewardedAd}];
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
    }
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)contentIsReady:(TJPlacement *)placement {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

#pragma mark - Tapjoy video delegate

- (void)videoDidComplete:(TJPlacement *)placement {
    // Using Smart server side reward since Tapjoy don't provide any reward value
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:nil];
}

@end

NS_ASSUME_NONNULL_END
