//
//  SASVungleRewardedVideoAdapter.h
//  SmartAdServer
//
//  Created by glaubier on 21/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASVungleBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Vungle rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASVungleRewardedVideoAdapter : SASVungleBaseAdapter <SASMediationRewardedVideoAdapter>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
@property (nonatomic, weak) id<SASMediationRewardedVideoAdapterDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
