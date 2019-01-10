//
//  SASInMobiRewardedVideoAdapter.m
//  SmartAdServer
//
//  Created by glaubier on 26/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASInMobiRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASInMobiRewardedVideoAdapter

- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    // Start by configuring the InMobi SDK
    NSError *error;
    if (![self configureInMobiSDKWithServerParameterString:serverParameterString andClientParameters:clientParameters error:&error]) {
        // Configuration can fail if the serverParameterString is invalid
        [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:NO];
        return;
    }
    
    // Instantiate IMInterstitial
    self.interstitial = [[IMInterstitial alloc] initWithPlacementId:self.placementID delegate:self];
    
    // Load the interstitial
    [self.interstitial load];
}

- (BOOL)isRewardedVideoReady {
    if (self.interstitial != nil) {
        return [self.interstitial isReady];
    }
    return false;
}

- (void)showRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.interstitial showFromViewController:viewController];
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    [self.delegate mediationRewardedVideoAdapterDidLoad:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToLoadWithError:error noFill:YES];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    [self.delegate mediationRewardedVideoAdapterDidShow:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    [self.delegate mediationRewardedVideoAdapter:self didFailToShowWithError:error];
}

- (void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    [self.delegate mediationRewardedVideoAdapterDidClose:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    [self.delegate mediationRewardedVideoAdapterDidReceiveAdClickedEvent:self];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    // Collect reward currency and amount
    SASReward *reward;
    NSString *currency = [[rewards allKeys] objectAtIndex:0];

    NSString *rewardString = [[rewards allValues] objectAtIndex:0];
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
    // Check if reward is convertible to a number
    if ([rewardString rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        // rewardString consists only of the digits 0 through 9. We can now create the SASReward
        reward = [[SASReward alloc] initWithAmount:[NSNumber numberWithLong:[rewardString longLongValue]] currency:currency];
    }
        
    // Inform delegate
    [self.delegate mediationRewardedVideoAdapter:self didCollectReward:reward];
}

@end

NS_ASSUME_NONNULL_END
