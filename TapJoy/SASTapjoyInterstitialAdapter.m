//
//  SASTapjoyInterstitialAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASTapjoyInterstitialAdapter.h"
#import <Tapjoy/Tapjoy.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASTapjoyInterstitialAdapter () <TJPlacementDelegate>

@end

@implementation SASTapjoyInterstitialAdapter

#pragma mark - Mediation adapter protocol implementation

- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Extracting various IDs from the server parameter string is done in the base class
    NSError *error;
    if (![self configureIDWithServerParameterString:serverParameterString error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Configuring GDPR status is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Handling connection is done in the base class
    [self connectTapjoySDK];
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    [self.placement showContentWithViewController:viewController];
}

- (BOOL)isInterstitialReady {
    return [self.placement isContentReady];
}

#pragma mark - Connection methods

- (void)connectionDidSucceed {
    // The Tapjoy SDK is connected, an ad request can be made
    self.placement = [TJPlacement placementWithName:self.placementName delegate:self];
    [self.placement requestContent];
}

- (void)connectionDidFailWithError:(NSError *)error {
    // No connection is considered as a loading error
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
}

#pragma mark - Tapjoy events

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (![placement isContentAvailable]) {
        NSError *error = [NSError errorWithDomain:SASTapjoyAdapterErrorDomain
                                             code:SASTapjoyAdapterErrorCodeFailedToLoadInterstitialAd
                                         userInfo:@{NSLocalizedDescriptionKey: SASTapjoyAdapterErrorMessageFailedToLoadInterstitialAd}];
        [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:YES];
    }
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    [self.delegate mediationInterstitialAdapter:self didFailToLoadWithError:error noFill:NO];
}

- (void)contentIsReady:(TJPlacement *)placement {
    [self.delegate mediationInterstitialAdapterDidLoad:self];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    [self.delegate mediationInterstitialAdapterDidShow:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    [self.delegate mediationInterstitialAdapterDidClose:self];
}

@end

NS_ASSUME_NONNULL_END
