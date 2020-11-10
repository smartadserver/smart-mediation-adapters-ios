//
//  SASVungleBannerAdapter.h
//  AdViewer
//
//  Created by glaubier on 27/10/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASVungleBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Vungle banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASVungleBannerAdapter : SASVungleBaseAdapter <SASMediationBannerAdapter>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationBannerAdapterDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
