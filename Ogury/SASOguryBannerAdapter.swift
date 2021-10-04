//
//  SASOguryBannerAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import OguryAds

/**
 Ogury banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASOguryBannerAdapter)
class SASOguryBannerAdapter: SASOguryBaseAdapter, SASMediationBannerAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
    private weak var delegate: SASMediationBannerAdapterDelegate? = nil
    
    /// The currently loaded Ogury banner, if any.
    private var banner: OguryAdsBanner? = nil
    
    required init(delegate: SASMediationBannerAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestBanner(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any], viewController: UIViewController) {
        
        // Ogury configuration
        configureOgurySDK(serverParameterString: serverParameterString, clientParameters: clientParameters) { [self] error in
            if let error = error {
                
                // Configuration can fail if the serverParameterString is invalid or if the Ogury SDK does not initialize properly
                delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
                
            } else {
                
                // Checking the bannerSize parameter
                guard let bannerSize = bannerSize else {
                    // Configuration can fail if the serverParameterString does not contains a valid banner size
                    let error = NSError(
                        domain: ErrorConstants.errorDomain,
                        code: ErrorConstants.errorCodeInvalidParameterString,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameterString)"]
                    )
                    delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
                    return
                }
                
                // Banner loading
                banner = OguryAdsBanner(adUnitID: adUnitId)
                banner?.bannerDelegate = self
                
                // Banner resizing to the size of the Smart banner view
                if let smartBannerSize = (clientParameters[SASMediationClientParameterAdViewSize] as? NSValue)?.cgSizeValue {
                    banner?.frame = CGRect(x: 0.0, y: 0.0, width: smartBannerSize.width, height: smartBannerSize.height)
                }
                
                banner?.load(with: bannerSize)
            }
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryBannerAdapter : OguryAdsBannerDelegate {
    
    func oguryAdsBannerAdAvailable(_ bannerAds: OguryAdsBanner!) { }
    
    func oguryAdsBannerAdNotAvailable(_ bannerAds: OguryAdsBanner!) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotAvailable,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Ad not available"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: true)
    }
    
    func oguryAdsBannerAdLoaded(_ bannerAds: OguryAdsBanner!) {
        delegate?.mediationBannerAdapter(self, didLoadBanner: bannerAds)
    }
    
    func oguryAdsBannerAdNotLoaded(_ bannerAds: OguryAdsBanner!) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotLoaded,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Ad not loaded"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func oguryAdsBannerAdDisplayed(_ bannerAds: OguryAdsBanner!) { }
    
    func oguryAdsBannerAdClosed(_ bannerAds: OguryAdsBanner!) { }
    
    func oguryAdsBannerAdClicked(_ bannerAds: OguryAdsBanner!) {
        delegate?.mediationBannerAdapterDidReceiveAdClickedEvent(self)
    }
    
    func oguryAdsBannerAdError(_ errorType: OguryAdsErrorType, for bannerAds: OguryAdsBanner!) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Ad error with type: \(errorType)"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
}
