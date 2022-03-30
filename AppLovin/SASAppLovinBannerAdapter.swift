//
//  SASAppLovinBannerAdapter.swift
//  AdViewer2-Mediation
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2022.
//  Copyright © 2022 Smart AdServer. All rights reserved.
//

import Foundation
import AppLovinSDK
import SASDisplayKit

/**
 AppLovin banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASAppLovinBannerAdapter)
class SASAppLovinBannerAdapter: SASAppLovinBaseAdapter, SASMediationBannerAdapter, MAAdViewAdDelegate {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationBannerAdapterDelegate? = nil
    
    /// The currently loaded AppLovin banner if any, nil otherwise.
    private var adView: MAAdView? = nil
    
    // MARK: - Mediation adapter protocol implementation
    
    required init(delegate: SASMediationBannerAdapterDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func requestBanner(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any], viewController: UIViewController) {
        adView = nil
        
        // Parameter retrieval and validation
        do {
            let (adUnitID, adFormat) = try configureAppLovinAds(serverParameterString: serverParameterString)
            // Initializing the SDK is done in the base class
            SASAppLovinBaseAdapter.initializeApplovinSdk { [self] in
                // Configuring GDPR is done in the base class
                configureGDPRWithClientParameters(clientParameters: clientParameters)
                
                // Instantiating & loading the AppLovin banner
                let containerSize = (clientParameters[SASMediationClientParameterAdViewSize] as! NSValue).cgSizeValue
                
                let adView = MAAdView(adUnitIdentifier: adUnitID, adFormat: adFormat)
                
                if MAAdFormat.mrec == adFormat {
                    // MREC width and height are 300 and 250
                    adView.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
                } else {
                    adView.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)
                }
                adView.delegate = self
                adView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                adView.loadAd()

                self.adView = adView
            }
        } catch {
            delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
        }
    }
    
    // MARK: - AppLovin delegates
    
    func didLoad(_ ad: MAAd) {
        if let adView = adView {
            delegate?.mediationBannerAdapter(self, didLoadBanner: adView)
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        let smartError = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Banner Error: \(error.code)"
        ])
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: smartError, noFill: error.code == .noFill)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        let smartError = NSError(domain: SASAppLovinBaseAdapter.ErrorConstants.errorDomain, code: error.code.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "AppLovin Banner Error: \(error.code)"
        ])
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: smartError, noFill: error.code == .noFill)
    }
    
    func didExpand(_ ad: MAAd) {
        delegate?.mediationBannerAdapterWillPresentModalView(self)
    }
    
    func didCollapse(_ ad: MAAd) {
        delegate?.mediationBannerAdapterWillDismissModalView(self)
    }
    
    func didDisplay(_ ad: MAAd) {
        // Nothing to do
    }
    
    func didHide(_ ad: MAAd) {
        // Nothing to do
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.mediationBannerAdapterDidReceiveAdClickedEvent(self)
    }
    
}
