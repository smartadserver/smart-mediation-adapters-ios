//
//  SASGoogleMobileAdsBaseAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 04/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASGoogleMobileAdsBaseAdapter)
class SASGoogleMobileAdsBaseAdapter : NSObject {
    
    /**
     Constants used to produce errors.
     */
    class ErrorConstants {
        static let errorDomain = "SASGoogleMobileAdsAdapter"
        
        static let errorCodeInvalidParameterString = 1
        static let rewardedVideoExpiredOrAlreadyDisplayedErrorCode = 2
    }
    
    /// Enum that defines all the possible Google Mobile Ads type at initialization.
    enum GoogleMobileAdsType: Int {
        case notInitialized = 0
        case adMob = 1
        case adManager = 2
    }
    
    /// The key used by GMA creatives.
    static let adManagerKey = "admanager"
    
    /// Google Mobile Ads init status.
    var googleMobileAdsInitStatus: GoogleMobileAdsType = .notInitialized
    
    /// Google Mobile Ads Application ID.
    var applicationID: String? = nil
    
    /**
     Initalize the Google Mobile Ads SDK.
     
     This method will only initialize the SDK once, no matter how many time it is called.
     */
    static func initializeGoogleMobileAds() {
        // TODO not sure this method is still useful?
    }
    
    /**
     Method called to configure Google Mobile Ads IDs from the server parameter string provided by Smart.
     
     This method can fail and return GoogleMobileAdsTypeNotInitialized and an error, in this case no ad
     call should be performed.
     
     @param serverParameterString The server parameter string provided by Smart.
     @return A tuple containing the Google Mobile Ads type after configuration and the adUnitID.
     @throws An Error if the method fails (and returns GoogleMobileAdsTypeNotInitialized).
     */
    func configureGoogleMobileAds(serverParameterString: String) throws -> (GoogleMobileAdsType, String) {
        // IDs are sent as a slash separated string
        let serverParameters = serverParameterString.split(separator: "|")
        
        // Invalid parameter string, the loading will be cancelled with an error
        guard serverParameters.count == 2 || serverParameters.count == 3 else {
            throw NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeInvalidParameterString,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
            )
        }
        
        // Extracting and converting parameters
        let appID = String(serverParameters[0])
        let adUnitID = String(serverParameters[1])
        
        if appID == SASGoogleMobileAdsBaseAdapter.adManagerKey {
            googleMobileAdsInitStatus = .adManager
        } else {
            SASGoogleMobileAdsBaseAdapter.initializeGoogleMobileAds()
            googleMobileAdsInitStatus = .adMob
        }
        
        return (googleMobileAdsInitStatus, adUnitID)
    }
    
    /**
     Return a dictionary of additional parameters that will include GDPR information.
     
     @param clientParameters The client parameters dictionary provided by Smart.
     @return A dictionary of additional parameters.
     */
    private func additionalParameters(clientParameters: [AnyHashable : Any]) -> [AnyHashable : Any]? {
        // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
        if let gdprApplies = (clientParameters[SASMediationClientParameterGDPRApplies] as? NSString)?.boolValue, gdprApplies {
            
            // Due to the fact that Google Mobile Ads is not IAB compliant, it does not accept IAB Consent String, but only a
            // binary consent status.
            // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
            // in NSUserDefault, therefore this adapter will retrieve it from this key.
            // Adapt the code below if your app don't follow this convention.
            if let statusString = UserDefaults.standard.object(forKey: "Smart_advertisingConsentStatus") as? String, statusString == "1" {
                return nil
            } else {
                return ["npa": "1"] // 'Non-Personalized Ads' enabled for this user
            }
        } else {
            // If GDPR does not apply, AdMob user consent can be set to accepted.
            return nil
        }
    }
    
    /**
     Method called to initialize Google Mobile Ads request from the client parameters provided by Smart.
     
     @param clientParameters The client parameters string provided by Smart.
     */
    func request<T: GADRequest>(clientParameters: [AnyHashable : Any]) -> T {
        // Creating an Google Mobile Ads ad request
        let request = T()
        
        // Test ads will be returned for devices with device IDs specified in this array.
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID /* other test devices can be added here */ ]

        request.requestAgent = "SmartAdServer"
        
        // Configure additional parameters if necessary (GDPR info)
        if let additionalParameters = additionalParameters(clientParameters: clientParameters) {
            let extras = GADExtras()
            extras.additionalParameters = additionalParameters
            request.register(extras)
        }
        
        return request
    }
    
}
