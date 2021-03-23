//
//  SASGoogleMobileAdsInterstitialAdapter.h
//  SmartAdServer
//
//  Created by Julien Gomez on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Google Mobile Ads interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASGoogleMobileAdsInterstitialAdapter : SASGoogleMobileAdsBaseAdapter <SASMediationInterstitialAdapter, GADFullScreenContentDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationInterstitialAdapterDelegate> delegate;

/// The currently loaded Google Mobile Ads interstitial if any.
@property (nonatomic, strong, nullable) GADInterstitialAd *interstitial;

@end

NS_ASSUME_NONNULL_END
