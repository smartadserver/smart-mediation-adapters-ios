//
//  SASOguryOptinVideoAdapter.h
//  AdViewer
//
//  Created by Loïc GIRON DIT METAZ on 30/09/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASOguryBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Ogury rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@interface SASOguryOptinVideoAdapter : SASOguryBaseAdapter <SASMediationRewardedVideoAdapter, OguryAdsOptinVideoDelegate>

/// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
@property (nonatomic, weak, nullable) id<SASMediationRewardedVideoAdapterDelegate> delegate;

/// The currently loaded Ogury Optin Video, if any.
@property (nonatomic, strong, nullable) OguryAdsOptinVideo *optInVideo;

/// The current reward if any.
@property (nonatomic, strong, nullable) SASReward *reward;

@end

NS_ASSUME_NONNULL_END
