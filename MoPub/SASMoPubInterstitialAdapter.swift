//
//  SASMoPubInterstitialAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 11/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import MoPubSDK

/**
 MoPub interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASMoPubInterstitialAdapter)
class SASMoPubInterstitialAdapter : SASMoPubBaseAdapter, SASMediationInterstitialAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationInterstitialAdapterDelegate? = nil
    
    /// The currently displayed MoPub interstitial view if any.
    private var interstitialController: MPInterstitialAdController? = nil
    
    /// YES if an interstitial is ready to be displayed, NO otherwise.
    private var isReady: Bool = false
    
    // Client parameters set by the SDK for the current ad request.
    private var clientParameters: [AnyHashable : Any] = [:]
    
    required init(delegate: SASMediationInterstitialAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestInterstitial(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        self.isReady = false
        self.clientParameters = clientParameters
        
        // Configuring Application ID is done in the base class
        configureApplicationID(serverParameterString: serverParameterString)
        
        // Creating the MoPub interstitial controller
        interstitialController = MPInterstitialAdController(forAdUnitId: adUnitID)
        interstitialController?.delegate = self
        
        // Loading the interstitial after initialization
        initializeMoPubSDK {
            self.interstitialController?.loadAd()
        }
    }
    
    func showInterstitial(from viewController: UIViewController) {
        // Configuring GDPR status is done in the base class
        if configureGDPR(clientParameters: self.clientParameters, viewController: viewController) {
            // If MoPub is attempting to display a CMP consent dialog, we abort the ad show so we don't display an interstitial
            // and the dialog at the same time.
            
            // Call failToShow delegate to reset the interstitial for the next call.
            let error = NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeCMPDisplayed,
                userInfo: [NSLocalizedDescriptionKey: "The MoPub CMP was displayed instead of the interstitial ad."]
            )
            delegate?.mediationInterstitialAdapter(self, didFailToShowWithError: error)
            
        } else {
            interstitialController?.show(from: viewController)
        }
    }
    
    func isInterstitialReady() -> Bool {
        return self.isReady
    }
    
}

/**
 MoPub delegate implementation.
 */
extension SASMoPubInterstitialAdapter : MPInterstitialAdControllerDelegate {
    
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        isReady = true
        delegate?.mediationInterstitialAdapterDidLoad(self)
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!, withError error: Error!) {
        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: true)
        // Since there is no documented way to know if the error is due to a 'no fill', we send true for this parameter
    }
    
    func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func interstitialDidDismiss(_ interstitial: MPInterstitialAdController!) {
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
    func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
        // The interstitial is not ready anymore if expired
        isReady = false
    }
    
    func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
        delegate?.mediationInterstitialAdapterDidReceiveAdClickedEvent(self)
    }
    
}
