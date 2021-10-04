//
//  SASMoPubRewardedVideoAdapter.swift
//  SASMoPubRewardedVideoAdapter
//
//  Created by Loïc GIRON DIT METAZ on 11/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import MoPubSDK

/**
 MoPub rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASMoPubRewardedVideoAdapter)
class SASMoPubRewardedVideoAdapter : SASMoPubBaseAdapter, SASMediationRewardedVideoAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationRewardedVideoAdapterDelegate? = nil
    
    // Client parameters set by the SDK for the current ad request.
    private var clientParameters: [AnyHashable : Any] = [:]
    
    required init(delegate: SASMediationRewardedVideoAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }

    func requestRewardedVideo(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        self.clientParameters = clientParameters
        
        // Configuring Application ID is done in the base class
        configureApplicationID(serverParameterString: serverParameterString)
        
        // Rewarded video configuration
        MPRewardedAds.setDelegate(self, forAdUnitId: adUnitID)
        
        // An ad might already be ready for this placement, if this is the case, we don't load another one because it will fail
        guard !isRewardedVideoReady() else {
            delegate?.mediationRewardedVideoAdapterDidLoad(self)
            return
        }
        
        // Loading the rewarded video after initialization
        initializeMoPubSDK {
            MPRewardedAds.loadRewardedAd(withAdUnitID: self.adUnitID, withMediationSettings: [])
        }
    }

    func showRewardedVideo(from viewController: UIViewController) {
        // Configuring GDPR status is done in the base class
        if configureGDPR(clientParameters: self.clientParameters, viewController: viewController) {
            // If MoPub is attempting to display a CMP consent dialog, we abort the ad show so we don't display an interstitial
            // and the dialog at the same time.
            
            // Call failToShow delegate to reset the interstitial for the next call.
            let error = NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeCMPDisplayed,
                userInfo: [NSLocalizedDescriptionKey: "The MoPub CMP was displayed instead of the interstitial rewarded video."]
            )
            delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
            
        } else {
            guard let reward = MPRewardedAds.availableRewards(forAdUnitID: adUnitID).first as? MPReward else {
                // Call failToShow delegate if there is no valid reward
                let error = NSError(
                    domain: ErrorConstants.errorDomain,
                    code: ErrorConstants.errorCodeNoReward,
                    userInfo: [NSLocalizedDescriptionKey: "Cannot retrieve reward for ad unit: '\(adUnitID)'"]
                )
                delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
                return
            }
            
            MPRewardedAds.presentRewardedAd(forAdUnitID: adUnitID, from: viewController, with: reward)
        }
    }

    func isRewardedVideoReady() -> Bool {
        return MPRewardedAds.hasAdAvailable(forAdUnitID: adUnitID)
    }
    
}

/**
 MoPub delegate implementation.
 */
extension SASMoPubRewardedVideoAdapter : MPRewardedAdsDelegate {
    
    func rewardedAdDidLoad(forAdUnitID adUnitID: String!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapterDidLoad(self)
        }
    }
    
    func rewardedAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: true)
            // Since there is no documented way to know if the error is due to a 'no fill', we send true for this parameter
        }
    }
    
    func rewardedAdDidFailToShow(forAdUnitID adUnitID: String!, error: Error!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
        }
    }
    
    func rewardedAdDidPresent(forAdUnitID adUnitID: String!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapterDidShow(self)
        }
    }
    
    func rewardedAdDidDismiss(forAdUnitID adUnitID: String!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapterDidClose(self)
        }
    }
    
    func rewardedAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        if adUnitID == self.adUnitID {
            delegate?.mediationRewardedVideoAdapterDidReceiveAdClickedEvent(self)
        }
    }
    
    func rewardedAdShouldReward(forAdUnitID adUnitID: String!, reward: MPReward!) {
        if adUnitID == self.adUnitID {
            let smartReward = SASReward(amount: reward.amount, currency: reward.currencyType)
            delegate?.mediationRewardedVideoAdapter(self, didCollect: smartReward)
        }
    }
    
}
