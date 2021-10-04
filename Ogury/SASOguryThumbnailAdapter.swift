//
//  SASOguryThumbnailAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import OguryAds

/**
 Ogury Thumbnail adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASOguryThumbnailAdapter)
class SASOguryThumbnailAdapter : SASOguryBaseAdapter, SASMediationBannerAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart Display SDK.
    private weak var delegate: SASMediationBannerAdapterDelegate? = nil
    
    /// The currently loaded Ogury Thumbnail, if any.
    private var thumbnailAd: OguryAdsThumbnailAd? = nil
    
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
                
                // Checking the thumbnailSize parameter
                guard let thumbnailSize = thumbnailSize else {
                    // Configuration can fail if the serverParameterString does not contains a valid thumbnail size
                    let error = NSError(
                        domain: ErrorConstants.errorDomain,
                        code: ErrorConstants.errorCodeInvalidParameterString,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameterString)"]
                    )
                    delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
                    return
                }
                
                // Thumbnail loading
                thumbnailAd = OguryAdsThumbnailAd(adUnitID: adUnitId)
                thumbnailAd?.thumbnailAdDelegate = self
                
                thumbnailAd?.load(CGSize(width: thumbnailSize.maxWidth, height: thumbnailSize.maxHeight))
            }
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryThumbnailAdapter : OguryAdsThumbnailAdDelegate {
    
    func oguryAdsThumbnailAdAdAvailable() { }
    
    func oguryAdsThumbnailAdAdNotAvailable() {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotAvailable,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Thumbnail - Ad not available"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: true)
    }
    
    func oguryAdsThumbnailAdAdLoaded() {
        guard let thumbnailSize = thumbnailSize else {
            return
        }
        
        // Sending a fake banner to the Smart SDK
        delegate?.mediationBannerAdapter(self, didLoadBanner: UIView(frame: .zero))
        
        // Displaying the thumbnail immediately
        DispatchQueue.main.async {
            self.thumbnailAd?.show(CGPoint(x: thumbnailSize.leftMargin, y: thumbnailSize.topMargin))
        }
    }
    
    func oguryAdsThumbnailAdAdNotLoaded() {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdNotLoaded,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Thumbnail - Ad not loaded"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func oguryAdsThumbnailAdAdDisplayed() { }
    
    func oguryAdsThumbnailAdAdClosed() { }
    
    func oguryAdsThumbnailAdAdError(_ errorType: OguryAdsErrorType) {
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Thumbnail - Ad error with type: \(errorType)"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
    }
    
    func oguryAdsThumbnailAdAdClicked() {
        delegate?.mediationBannerAdapterDidReceiveAdClickedEvent(self)
    }
    
}
