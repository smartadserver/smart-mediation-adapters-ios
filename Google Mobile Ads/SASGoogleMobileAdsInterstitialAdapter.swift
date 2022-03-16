//
//  SASGoogleMobileAdsInterstitialAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 04/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads interstitial adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASGoogleMobileAdsInterstitialAdapter)
class SASGoogleMobileAdsInterstitialAdapter : SASGoogleMobileAdsBaseAdapter, SASMediationInterstitialAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Smart SDK.
    private weak var delegate: SASMediationInterstitialAdapterDelegate? = nil
    
    /// The currently loaded Google Mobile Ads interstitial if any.
    private var interstitial: GADInterstitialAd? = nil
    
    required init(delegate: SASMediationInterstitialAdapterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func requestInterstitial(withServerParameterString serverParameterString: String, clientParameters: [AnyHashable : Any]) {
        // Previous state is reset if any
        interstitial = nil
        
        // Parameter retrieval and validation
        do {
            let (gmaType, adUnitID) = try configureGoogleMobileAds(serverParameterString: serverParameterString)
            
            switch (gmaType) {
            case .adManager:
                // Create Google Ad Request
                let request = request(clientParameters: clientParameters) as GAMRequest
                
                // Perform ad request
                GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID, request: request) { [self] interstitialAd, error in
                    if let error = error as NSError? {
                        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError:error, noFill:(error.code == GADErrorCode.noFill.rawValue))
                    } else {
                        interstitial = interstitialAd
                        interstitial?.fullScreenContentDelegate = self
                        
                        delegate?.mediationInterstitialAdapterDidLoad(self)
                    }
                }
                
            default:
                // Create Google Ad Request
                let request = request(clientParameters: clientParameters)
                
                // Perform ad request
                GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [self] interstitialAd, error in
                    if let error = error as NSError? {
                        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError:error, noFill:(error.code == GADErrorCode.noFill.rawValue))
                    } else {
                        interstitial = interstitialAd
                        interstitial?.fullScreenContentDelegate = self
                        
                        delegate?.mediationInterstitialAdapterDidLoad(self)
                    }
                }
            }
        } catch {
            delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: false)
            return
        }
    }
    
    func showInterstitial(from viewController: UIViewController) {
        interstitial?.present(fromRootViewController: viewController)
    }
    
    func isInterstitialReady() -> Bool {
        return interstitial != nil
    }
    
}

/**
 Google Mobile Ads delegate implementation.
 */
extension SASGoogleMobileAdsInterstitialAdapter : GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        // not used
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        delegate?.mediationInterstitialAdapter(self, didFailToShowWithError: error)
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
}
