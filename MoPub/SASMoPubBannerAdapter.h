//
//  SASMoPubBannerAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 25/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMoPubBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MoPub banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASMoPubBannerAdapter : SASMoPubBaseAdapter <SASMediationBannerAdapter, MPAdViewDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationBannerAdapterDelegate> delegate;

/// The view controller currently displayed on screen if any.
@property (nonatomic, weak, nullable) UIViewController *viewController;

/// The view that is used to contain the banner view if any.
///
/// More details about this view in the adapter's implementation.
@property (nonatomic, strong, nullable) UIView *bannerContainerView;

/// The currently displayed MoPub banner view if any.
@property (nonatomic, strong, nullable) MPAdView *bannerView;

@end

NS_ASSUME_NONNULL_END
