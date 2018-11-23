//
//  SASAppLovinNativeAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 18/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 AppLovin native ad adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAppLovinNativeAdAdapter : SASAppLovinBaseAdapter <SASMediationNativeAdAdapter, ALNativeAdLoadDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationNativeAdAdapterDelegate> delegate;

/// An array of gesture recognizers that have been associated with the ad views, or nil if no views are currently registered.
@property (nonatomic, strong, nullable) NSMutableArray *registeredGestureRecognizers;

/// The currently loaded AppLovin native if any.
@property (nonatomic, strong, nullable) ALNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
