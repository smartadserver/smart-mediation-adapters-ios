//
//  SASMoPubBannerAdapter.swift
//  SASMoPubBannerAdapter
//
//  Created by Loïc GIRON DIT METAZ on 11/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import MoPubSDK

/**
 MoPub banner adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASMoPubBannerAdapter)
class SASMoPubBannerAdapter : SASMoPubBaseAdapter, SASMediationBannerAdapter {

    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationBannerAdapterDelegate? = nil
    
    /// The view controller currently displayed on screen if any.
    private var viewController: UIViewController? = nil
    
    /// The view that is used to contain the banner view if any.
    ///
    /// More details about this view in the adapter's implementation.
    private var bannerContainerView: UIView? = nil
    
    /// The currently displayed MoPub banner view if any.
    private var bannerView: MPAdView? = nil
    
    required init(delegate: SASMediationBannerAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestBanner(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any], viewController: UIViewController) {
        self.viewController = viewController
        
        // Configuring Application ID is done in the base class
        configureApplicationID(serverParameterString: serverParameterString)
        
        // Configuring GDPR status is done in the base class
        // For banners, we don't have to check if a CMP has been displayed by MoPub because the banner will still
        // be able to load under it anyway.
        let _ = configureGDPR(clientParameters: clientParameters, viewController: viewController)
        
        // Creating a container view to center the MoPub banner:
        // The view returned to the SDK is automatically stretched to fit the SASBannerView instance. But since MoPub
        // banners are always fixed size, it is better to return a view containing the MoPub banner (using the relevant
        // autoresizing mask) instead of the MoPub banner itself.
        let containerSize = (clientParameters[SASMediationClientParameterAdViewSize] as! NSValue).cgSizeValue
        bannerContainerView = UIView(frame: CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height))
        
        // Creating the MoPub banner view
        bannerView = MPAdView(adUnitId: adUnitID)
        bannerView?.delegate = self
        bannerView?.stopAutomaticallyRefreshingContents()
        
        // Positioning the banner on the container
        let actualBannerSize = moPubFromAdViewSize(adViewSize: containerSize)
        bannerView?.frame = CGRect(x: 0, y: (containerSize.height - actualBannerSize.height) / 2, width: containerSize.width, height: actualBannerSize.height)
        bannerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        bannerContainerView?.addSubview(bannerView!)
        
        // Loading the banner after initialization
        initializeMoPubSDK {
            self.bannerView?.loadAd(withMaxAdSize: actualBannerSize)
        }        
    }
    
    private func moPubFromAdViewSize(adViewSize: CGSize?) -> CGSize {
        guard let adViewSize = adViewSize else {
            // Default size
            return kMPPresetMaxAdSize50Height
        }
        
        let bannerWidth = adViewSize.width
        let bannerHeight = adViewSize.height
        
        if bannerHeight > bannerWidth {
            return CGSize(width: kMPFlexibleAdSize, height: 600.0) // Value of the old SKYSCRAPPER size
        } else if bannerHeight >= 300 && bannerWidth >= 250 {
            return kMPPresetMaxAdSize250Height
        } else {
            return kMPPresetMaxAdSize50Height
        }
    }
    
}

/**
 MoPub delegate implementation.
 */
extension SASMoPubBannerAdapter : MPAdViewDelegate {
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return viewController
    }
    
    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        if let bannerContainerView = bannerContainerView {
            delegate?.mediationBannerAdapter(self, didLoadBanner: bannerContainerView) // we are returning the container here, not the actual banner
        }
    }
    
    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: true)
        // Since there is no documented way to know if the error is due to a 'no fill', we send true for this parameter
    }
    
    func willPresentModalView(forAd view: MPAdView!) {
        delegate?.mediationBannerAdapterWillPresentModalView(self)
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        delegate?.mediationBannerAdapterWillDismissModalView(self)
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        delegate?.mediationBannerAdapterDidReceiveAdClickedEvent(self)
    }
    
}
