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
    
    /// The currently loaded Ogury banner if any, nil otherwise.
    private var banner: OguryBannerAd? = nil
    
    /// The view controller currently used to display the banner if any, nil otherwise.
    private var viewController: UIViewController? = nil
    
    required init(delegate: SASMediationBannerAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestBanner(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any], viewController: UIViewController) {
        
        self.viewController = viewController
        
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
                banner = OguryBannerAd(adUnitId: adUnitId!)
                banner?.delegate = self
                
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
extension SASOguryBannerAdapter : OguryBannerAdDelegate {
    
    func didLoad(_ banner: OguryBannerAd) {
        delegate?.mediationBannerAdapter(self, didLoadBanner: banner)
    }
    
    func didDisplay(_ banner: OguryBannerAd) { }
    
    func didClick(_ banner: OguryBannerAd) {
        delegate?.mediationBannerAdapterDidReceiveAdClickedEvent(self)
    }
    
    func didClose(_ banner: OguryBannerAd) { }
    
    func didFailOguryBannerAdWithError(_ error: OguryError, for banner: OguryBannerAd) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Ad failed with error: \(error)"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: (error.code == ErrorConstants.oguryNoAdErrorCode))
    }
    
    func didTriggerImpressionOguryBannerAd(_ banner: OguryBannerAd) { }

    func presentingViewController(forOguryAdsBannerAd banner: OguryBannerAd) -> UIViewController {
        return viewController!;
    }
    
}
