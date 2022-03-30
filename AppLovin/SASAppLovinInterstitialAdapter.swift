//
//  SASAppLovinInterstitialAdapter.swift
//  AdViewer2-Mediation
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2022.
//  Copyright © 2022 Smart AdServer. All rights reserved.
//

import Foundation
import AppLovinSDK
import SASDisplayKit

/**
 AppLovin interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASAppLovinInterstitialAdapter)
class SASAppLovinInterstitialAdapter: SASAppLovinBaseAdapter, SASMediationInterstitialAdapter, MAAdDelegate {

    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationInterstitialAdapterDelegate? = nil

    /// The currently loaded AppLovin interstitial if any, nil otherwise.
    private var interstitial: MAInterstitialAd? = nil

    /// The currently loaded AppLovin ad if any.
    private var currentAd: MAAd? = nil
    
    // MARK: - Mediation adapter protocol implementation
    
    required init(delegate: SASMediationInterstitialAdapterDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func requestInterstitial(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        self.currentAd = nil
        
        // Parameter retrieval and validation
        do {
            let (adUnitID, _) = try configureAppLovinAds(serverParameterString: serverParameterString)
            // Initializing the SDK is done in the base class
            SASAppLovinBaseAdapter.initializeApplovinSdk { [self] in
                // Configuring GDPR is done in the base class
                configureGDPRWithClientParameters(clientParameters: clientParameters)
                
                // Initializing a new interstitial instance
                let interstitial = MAInterstitialAd(adUnitIdentifier: adUnitID)
                
                interstitial.delegate = self

                // Load the ad
                interstitial.load()
                
                self.interstitial = interstitial
            }
        } catch {
            delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: false)
        }
    }
    
    func showInterstitial(from viewController: UIViewController) {
        interstitial?.show()
    }
    
    func isInterstitialReady() -> Bool {
        return interstitial?.isReady ?? false
    }
    
    // MARK: - AppLovin delegates
    
    func didLoad(_ ad: MAAd) {
        currentAd = ad;
    }
    
    // this is never called in case of no fill error
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        let error = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Interstitial Error: \(error.code.rawValue)"
        ])
        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: MAErrorCode.noFill.rawValue == error.code)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.mediationInterstitialAdapterDidReceiveAdClickedEvent(self)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        let error = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Interstitial Error: \(error.code.rawValue)"
        ])
        delegate?.mediationInterstitialAdapter(self, didFailToShowWithError: error)
    }
    
}
