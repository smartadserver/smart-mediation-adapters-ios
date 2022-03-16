//
//  SASGoogleMobileAdsRewardedVideoAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads rewarded video adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASGoogleMobileAdsRewardedVideoAdapter)
class SASGoogleMobileAdsRewardedVideoAdapter : SASGoogleMobileAdsBaseAdapter, SASMediationRewardedVideoAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationRewardedVideoAdapterDelegate? = nil
    
    /// The currently loaded (and ready) Google Mobile Ads rewarded ad if any.
    private var rewardedAd: GADRewardedAd? = nil
    
    required init(delegate: SASMediationRewardedVideoAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestRewardedVideo(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        // Previous state is reset if any
        rewardedAd = nil
        
        // Parameter retrieval and validation
        do {
            let (gmaType, adUnitID) = try configureGoogleMobileAds(serverParameterString: serverParameterString)
            
            // Create Google Ad Request
            let request = { () -> GADRequest in
                switch (gmaType) {
                case .adManager :
                    return self.request(clientParameters: clientParameters) as GAMRequest
                default:
                    return self.request(clientParameters: clientParameters)
                }
            }()
            
            // Create Google Rewarded Video
            GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { [self] rewardedAd, error in
                if let error = error as NSError? {
                    delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError:error, noFill:(error.code == GADErrorCode.noFill.rawValue))
                } else {
                    self.rewardedAd = rewardedAd
                    delegate?.mediationRewardedVideoAdapterDidLoad(self)
                }
            }
            
        } catch {
            delegate?.mediationRewardedVideoAdapter(self, didFailToLoadWithError: error, noFill: false)
            return
        }
    }
    
    func showRewardedVideo(from viewController: UIViewController) {
        if isRewardedVideoReady() {
            rewardedAd?.fullScreenContentDelegate = self
            
            rewardedAd?.present(fromRootViewController: viewController, userDidEarnRewardHandler: { [self] in
                if let rewardAmount = rewardedAd?.adReward.amount,
                   let rewardType = rewardedAd?.adReward.type {
                    let reward = SASReward(amount: rewardAmount, currency: rewardType)
                    delegate?.mediationRewardedVideoAdapter(self, didCollect: reward)
                }
            })
        } else {
            // We will send the error if the reward-based video ad has already been presented.
            let error = NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.rewardedVideoExpiredOrAlreadyDisplayedErrorCode,
                userInfo: [NSLocalizedDescriptionKey: "Reward video ad has already been shown."]
            )
            delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
        }
    }
    
    func isRewardedVideoReady() -> Bool {
        return rewardedAd != nil
    }
    
}

/**
 Google Mobile Ads delegate implementation.
 */
extension SASGoogleMobileAdsRewardedVideoAdapter : GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        // not used
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        delegate?.mediationRewardedVideoAdapter(self, didFailToShowWithError: error)
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.mediationRewardedVideoAdapterDidShow(self)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.mediationRewardedVideoAdapterDidClose(self)
    }
    
}
