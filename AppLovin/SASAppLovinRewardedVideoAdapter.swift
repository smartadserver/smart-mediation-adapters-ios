//
//  SASAppLovinRewardedVideoAdapter.swift
//  AdViewer2-Mediation
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2022.
//  Copyright © 2022 Smart AdServer. All rights reserved.
//

import Foundation
import AppLovinSDK
import SASDisplayKit

/**
 AppLovin rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASAppLovinRewardedVideoAdapter)
class SASAppLovinRewardedVideoAdapter: SASAppLovinBaseAdapter, SASMediationRewardedVideoAdapter, MARewardedAdDelegate {
   
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationRewardedVideoAdapterDelegate? = nil

    /// The currently loaded AppLovin rewarded video if any.
    private var rewardedVideo: MARewardedAd? = nil

    /// YES if an ad is ready to be displayed, NO otherwise.
    private var isReady = false
    
    // MARK: - Mediation adapter protocol implementation
    
    required init(delegate: SASMediationRewardedVideoAdapterDelegate) {
        self.delegate = delegate
    }
    
    func requestRewardedVideo(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        isReady = false
        
        // Parameter retrieval and validation
        do {
            let (adUnitID, _) = try configureAppLovinAds(serverParameterString: serverParameterString)
            // Initializing the SDK is done in the base class
            SASAppLovinBaseAdapter.initializeApplovinSdk { [self] in
                // Configuring GDPR is done in the base class
                configureGDPRWithClientParameters(clientParameters: clientParameters)
                
                // Instantiating & loading a rewarded video ad
                let rewardedVideo = MARewardedAd.shared(withAdUnitIdentifier: adUnitID)
                rewardedVideo.delegate = self
                
                // Load the ad
                rewardedVideo.load()
                
                self.rewardedVideo = rewardedVideo
            }
        } catch {
            delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
        }
    }
    
    func showRewardedVideo(from viewController: UIViewController) {
        rewardedVideo?.show(forPlacement: nil, customData: nil, viewController: viewController)
    }
    
    func isRewardedVideoReady() -> Bool {
        return rewardedVideo?.isReady ?? false
    }
    
    // MARK: - AppLovin delegates
    
    func didStartRewardedVideo(for ad: MAAd) {
        // nothing to do
    }
    
    func didCompleteRewardedVideo(for ad: MAAd) {
        // nothing to do
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        // A reward is provided by AppLovin, we can use it instead of relying on a Smart reward.
        let currency = reward.label
        let amount = NSNumber(floatLiteral: Double(reward.amount))
        
        let reward = SASReward(amount: amount, currency: currency)
        delegate?.mediationRewardedVideoAdapter(self, didCollect: reward)
    }
    
    func didLoad(_ ad: MAAd) {
        delegate?.mediationRewardedVideoAdapterDidLoad(self)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        let error = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Rewarded Error: \(error.code.rawValue)"
        ])
        delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: MAErrorCode.noFill.rawValue == error.code)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.mediationRewardedVideoAdapterDidShow(self)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.mediationRewardedVideoAdapterDidClose(self)
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.mediationRewardedVideoAdapterDidReceiveAdClickedEvent(self)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        let error = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Rewarded Error: \(error.code.rawValue)"
        ])
        delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
    }
    

}
