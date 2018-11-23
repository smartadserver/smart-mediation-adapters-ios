//
//  SASAdinCubeInterstitialAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 07/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SASMediationInterstitialAdapterDelegate;

/**
 AdinCube interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAdinCubeInterstitialAdapter : SASAdinCubeBaseAdapter <SASMediationInterstitialAdapter, AdinCubeInterstitialDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationInterstitialAdapterDelegate> delegate;

/// The currently loaded AdinCube interstitial if any.
@property (nonatomic, strong, nullable) AdinCubeInterstitial *interstitial;

@end

NS_ASSUME_NONNULL_END
