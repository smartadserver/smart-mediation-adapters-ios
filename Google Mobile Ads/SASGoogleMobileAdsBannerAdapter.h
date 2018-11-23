//
//  SASGoogleMobileAdsBannerAdapter.h
//  SmartAdServer
//
//  Created by Julien Gomez on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGoogleMobileAdsBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Google Mobile Ads banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASGoogleMobileAdsBannerAdapter : SASGoogleMobileAdsBaseAdapter <SASMediationBannerAdapter, GADBannerViewDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationBannerAdapterDelegate> delegate;

/// The currently loaded Google Mobile Ads interstitial if any.
@property (nonatomic, strong, nullable) GADBannerView *bannerView;

@end

NS_ASSUME_NONNULL_END
