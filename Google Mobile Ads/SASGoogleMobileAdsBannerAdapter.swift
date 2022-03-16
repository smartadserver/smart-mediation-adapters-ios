//
//  SASGoogleMobileAdsBannerAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASGoogleMobileAdsBannerAdapter)
class SASGoogleMobileAdsBannerAdapter : SASGoogleMobileAdsBaseAdapter, SASMediationBannerAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationBannerAdapterDelegate? = nil
    
    /// The currently loaded Google Mobile Ads banner if any.
    private var bannerView: GADBannerView? = nil
    
    required init(delegate: SASMediationBannerAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestBanner(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any], viewController: UIViewController) {
        
        // Previous state is reset if any
        bannerView = nil
        
        // Parameter retrieval and validation
        do {
            let (gmaType, adUnitID) = try configureGoogleMobileAds(serverParameterString: serverParameterString)
            
            let adSize = bannerSize(serverParameterString: serverParameterString)
            switch (gmaType) {
                case .adManager:
                    bannerView = GAMBannerView(adSize: adSize)
                default:
                    bannerView = GADBannerView(adSize: adSize)
            }
            
            // Banner configuration
            bannerView?.delegate = self
            bannerView?.adUnitID = adUnitID
            bannerView?.rootViewController = viewController
            
            // Create Google Ad Request
            let request = request(clientParameters: clientParameters)
            
            // Perform ad request
            bannerView?.load(request)
        } catch {
            delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
        }
    }
    
    private func bannerSize(serverParameterString: String) -> GADAdSize {
        // IDs are sent as a slash separated string
        let serverParameters = serverParameterString.split(separator: "|")
        
        // Extracting banner size
        guard serverParameters.count > 2, let bannerSizeInt = Int(serverParameters[2]) else {
            return GADAdSizeBanner
        }
        
        switch (bannerSizeInt) {
        case 1:
            return GADAdSizeMediumRectangle
        case 2:
            return GADAdSizeLeaderboard
        case 3:
            return GADAdSizeLargeBanner
        default:
            return GADAdSizeBanner
        }
        
    }
    
}

/**
 Google Mobile Ads delegate implementation.
 */
extension SASGoogleMobileAdsBannerAdapter : GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        delegate?.mediationBannerAdapter(self, didLoadBanner: bannerView)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError:error, noFill:((error as NSError).code == GADErrorCode.noFill.rawValue))
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        delegate?.mediationBannerAdapterWillPresentModalView(self)
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        delegate?.mediationBannerAdapterWillDismissModalView(self)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        // Nothing to do
    }
    
}
