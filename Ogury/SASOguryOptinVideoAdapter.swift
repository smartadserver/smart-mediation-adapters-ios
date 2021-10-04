//
//  SASOguryOptinVideoAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import OguryAds

/**
 Ogury rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASOguryOptinVideoAdapter)
class SASOguryOptinVideoAdapter : SASOguryBaseAdapter, SASMediationRewardedVideoAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
    private weak var delegate: SASMediationRewardedVideoAdapterDelegate? = nil
    
    /// The currently loaded Ogury Optin Video, if any.
    private var optInVideo: OguryAdsOptinVideo? = nil
    
    /// The current reward if any.
    private var reward: SASReward? = nil
    
    required init(delegate: SASMediationRewardedVideoAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestRewardedVideo(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        
        // Ogury configuration
        configureOgurySDK(serverParameterString: serverParameterString, clientParameters: clientParameters) { [self] error in
            if let error = error {
                // Configuration can fail if the serverParameterString is invalid or if the Ogury SDK does not initialize properly
                delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
            } else {
                // Optin video instantiation and loading
                optInVideo = OguryAdsOptinVideo(adUnitID: adUnitId)
                optInVideo?.optInVideoDelegate = self
                
                optInVideo?.load()
            }
        }
    }
    
    func showRewardedVideo(from viewController: UIViewController) {
        optInVideo?.showAd(in: viewController)
    }
    
    func isRewardedVideoReady() -> Bool {
        if let optInVideo = optInVideo {
            return optInVideo.isLoaded
        } else {
            return false
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryOptinVideoAdapter : OguryAdsOptinVideoDelegate {
    
    func oguryAdsOptinVideoAdAvailable() { }
    
    func oguryAdsOptinVideoAdNotAvailable() {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotAvailable,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Rewarded Video - Ad not available"]
        )
        delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: true)
    }
    
    func oguryAdsOptinVideoAdLoaded() {
        delegate?.mediationRewardedVideoAdapterDidLoad(self)
    }
    
    func oguryAdsOptinVideoAdNotLoaded() {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotLoaded,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Rewarded Video - Ad not loaded"]
        )
        delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func oguryAdsOptinVideoAdDisplayed() {
        delegate?.mediationRewardedVideoAdapterDidShow(self)
    }
    
    func oguryAdsOptinVideoAdClosed() {
        delegate?.mediationRewardedVideoAdapterDidClose(self)
        
        if let reward = reward {
            delegate?.mediationRewardedVideoAdapter(self, didCollect: reward)
        }
    }
    
    func oguryAdsOptinVideoAdRewarded(_ item: OGARewardItem!) {
         let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let amount = formatter.number(from: item.rewardValue) {
            reward = SASReward(amount: amount, currency: item.rewardName)
        }
    }
    
    func oguryAdsOptinVideoAdError(_ errorType: OguryAdsErrorType) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Rewarded Video - Ad error with type: \(errorType)"]
        )
        delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func oguryAdsOptinVideoAdClicked() {
        delegate?.mediationRewardedVideoAdapterDidReceiveAdClickedEvent(self)
    }
    
}
