//
//  SASMoPubInterstitialAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MoPub interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASMoPubInterstitialAdapter : SASMoPubBaseAdapter <SASMediationInterstitialAdapter, MPInterstitialAdControllerDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationInterstitialAdapterDelegate> delegate;

/// The view controller currently displayed on screen if any.
@property (nonatomic, weak, nullable) UIViewController *viewController;

/// The currently displayed MoPub interstitial view if any.
@property (nonatomic, strong, nullable) MPInterstitialAdController *interstitialController;

/// YES if an interstitial is ready to be displayed, NO otherwise.
@property (nonatomic, assign) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
