//
//  SASOguryInterstitialAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 21/07/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import OguryAds

/**
 Ogury interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASOguryInterstitialAdapter)
class SASOguryInterstitialAdapter: SASOguryBaseAdapter, SASMediationInterstitialAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
    private weak var delegate: SASMediationInterstitialAdapterDelegate? = nil
    
    /// The currently loaded Ogury interstitial if any, nil otherwise.
    private var interstitial: OguryInterstitialAd? = nil
    
    required init(delegate: SASMediationInterstitialAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestInterstitial(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        // Ogury configuration
        configureOgurySDK(serverParameterString: serverParameterString, clientParameters: clientParameters) { [self] error in
            if let error = error {
                // Configuration can fail if the serverParameterString is invalid or if the Ogury SDK does not initialize properly
                delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: false)
            } else {
                // Interstitial instantiation and loading
                interstitial = OguryInterstitialAd(adUnitId: adUnitId!)
                interstitial?.delegate = self
                
                interstitial?.load()
            }
        }
    }
    
    func showInterstitial(from viewController: UIViewController) {
        interstitial?.show(in: viewController)
    }
    
    func isInterstitialReady() -> Bool {
        if let interstitial = interstitial {
            return interstitial.isLoaded()
        } else {
            return false
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryInterstitialAdapter: OguryInterstitialAdDelegate {
    
    func didLoad(_ interstitial: OguryInterstitialAd) {
        delegate?.mediationInterstitialAdapterDidLoad(self)
    }
    
    func didDisplay(_ interstitial: OguryInterstitialAd) {
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func didClick(_ interstitial: OguryInterstitialAd) {
        delegate?.mediationInterstitialAdapterDidReceiveAdClickedEvent(self)
    }
    
    func didClose(_ interstitial: OguryInterstitialAd) {
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
    func didFailOguryInterstitialAdWithError(_ error: OguryError, for interstitial: OguryInterstitialAd) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Interstitial - Ad failed with error: \(error)"]
        )
        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: (error.code == ErrorConstants.oguryNoAdErrorCode))
    }
    
    func didTriggerImpressionOguryInterstitialAd(_ interstitial: OguryInterstitialAd) { }
    
}
