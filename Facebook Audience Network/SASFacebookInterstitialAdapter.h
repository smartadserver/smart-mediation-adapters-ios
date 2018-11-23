//
//  SASFacebookInterstitialAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASFacebookBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Facebook interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASFacebookInterstitialAdapter : SASFacebookBaseAdapter <SASMediationInterstitialAdapter, FBInterstitialAdDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationInterstitialAdapterDelegate> delegate;

/// The currently loaded Facebook interstitial ad if any.
@property (nonatomic, strong, nullable) FBInterstitialAd *interstitial;

@end

NS_ASSUME_NONNULL_END
