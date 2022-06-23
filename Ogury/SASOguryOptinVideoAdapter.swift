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
    
    /// The currently loaded Ogury Optin Video if any, nil otherwise.
    private var optInVideo: OguryOptinVideoAd? = nil
    
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
                optInVideo = OguryOptinVideoAd(adUnitId: adUnitId!)
                optInVideo?.delegate = self
                
                optInVideo?.load()
            }
        }
    }
    
    func showRewardedVideo(from viewController: UIViewController) {
        optInVideo?.show(in: viewController)
    }
    
    func isRewardedVideoReady() -> Bool {
        if let optInVideo = optInVideo {
            return optInVideo.isLoaded()
        } else {
            return false
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryOptinVideoAdapter : OguryOptinVideoAdDelegate {
    
    func didLoad(_ optinVideo: OguryOptinVideoAd) {
        delegate?.mediationRewardedVideoAdapterDidLoad(self)
    }
    
    func didDisplay(_ optinVideo: OguryOptinVideoAd) {
        delegate?.mediationRewardedVideoAdapterDidShow(self)
    }
    
    func didClick(_ optinVideo: OguryOptinVideoAd) {
        
    }
    
    func didClose(_ optinVideo: OguryOptinVideoAd) {
        delegate?.mediationRewardedVideoAdapterDidClose(self)
        
        if let reward = reward {
            delegate?.mediationRewardedVideoAdapter(self, didCollect: reward)
        }
    }
    
    func didRewardOguryOptinVideoAd(with item: OGARewardItem, for optinVideo: OguryOptinVideoAd) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
       
        if let amount = formatter.number(from: item.rewardValue) {
            reward = SASReward(amount: amount, currency: item.rewardName)
        }
    }
    
    func didFailOguryOptinVideoAdWithError(_ error: OguryError, for optinVideo: OguryOptinVideoAd) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury OptIn Video - Ad failed with error: \(error)"]
        )
        delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func didTriggerImpressionOguryOptinVideoAd(_ optinVideo: OguryOptinVideoAd) { }
    
}
