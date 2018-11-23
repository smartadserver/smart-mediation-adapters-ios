//
//  SASAdinCubeNativeAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 12/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeBaseAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 AdinCube native ad adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASAdinCubeNativeAdapter : SASAdinCubeBaseAdapter <SASMediationNativeAdAdapter, AdinCubeNativeDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationNativeAdAdapterDelegate> delegate;

/// The currently loaded AdinCube native ad handler if any.
@property (nonatomic, strong, nullable) AdinCubeNative *native;

/// The currently loaded AdinCube native ad if any.
@property (nonatomic, strong, nullable) AdinCubeNativeAd *nativeAd;

/// The view used to handle AdinCube media if any.
@property (nonatomic, strong, nullable) AdinCubeNativeAdMediaView *adInCubeMediaView;

/// The AdinCube ad choices button if any.
@property (nonatomic, strong, nullable) AdinCubeAdChoicesView *adInCubeAdChoiceView;

/// YES if some view are registered with this adapter instance, NO otherwise.
@property (nonatomic, assign) BOOL viewRegistered;

@end

NS_ASSUME_NONNULL_END
