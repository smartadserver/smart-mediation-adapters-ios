//
//  SASAppLovinBaseAdapter.swift
//  AdViewer2-Mediation
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2022.
//  Copyright © 2022 Smart AdServer. All rights reserved.
//

import Foundation
import AppLovinSDK
import SASDisplayKit

/**
 AppLovin base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
class SASAppLovinBaseAdapter: NSObject {
    
    /**
     Constants used to produce errors.
     */
    class ErrorConstants {
        static let errorDomain = "SASAppLovinAdsAdapter"
        static let errorCodeInvalidParameterString = 1
    }
    
    /// true if the AppLovin SDK has been initialized (or is being initialized), false otherwise.
    private static var isAppLovinInitialized = false
    
    /**
     Initialize the AppLovin SDK if necessary then call a completion block that can be used to perform
     the ad call.
     
     @param completion A completion handler that will be called when the SDK is initialized properly.
     */
    static func initializeApplovinSdk(completion: @escaping () -> ()) {
        if isAppLovinInitialized {
            completion()
        } else {
            isAppLovinInitialized = true
            
            ALSdk.initializeSdk { configuration in
                // Uncomment to activate AppLovin Medaition Debugger
                // ALSdk.shared()!.showMediationDebugger()

                completion()
            }
        }
    }
    
    /**
     Method called to configure AppLovin IDs from the server parameter string provided by Smart.
     
     This method can fail and throw an error.
     
     @param serverParameterString The server parameter string provided by Smart.
     @return A tuple containing the adUnitID and the type of banner if available.
     @throws An Error if the method fails.
     */
    func configureAppLovinAds(serverParameterString: String) throws -> (String, MAAdFormat) {
        // IDs are sent as a slash separated string
        let serverParameters = serverParameterString.split(separator: "|")
        guard serverParameters.count == 2 else {
            throw NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeInvalidParameterString,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
            )
        }
        
        // Extracting and converting parameters
        let adUnitID = String(serverParameters[0])
        let adFormat = "MREC" == serverParameters[1] ? MAAdFormat.mrec : MAAdFormat.banner
  
        return (adUnitID, adFormat)
    }
    /**
     Configure GDPR for AppLovin SDK from the client parameters dictionary provided by the
     Smart SDK.
     
     @param clientParameters The client parameters dictionary provided by Smart.
     */
    func configureGDPRWithClientParameters(clientParameters: [AnyHashable : Any]) {
        // Checking the GDPRApplies client parameter to know if asking for consent is relevant for this user.
        if clientParameters[SASMediationClientParameterGDPRApplies] as! Bool {
            // Smart advises app developers to store the binary consent in the 'Smart_advertisingConsentStatus' key
            // in NSUserDefault, therefore this adapter will retrieve it from this key.
            // Adapt the code below if your app don't follow this convention.
            if let storedBinaryConsentForAdvertising = UserDefaults.standard.string(forKey: "Smart_advertisingConsentStatus"),
               storedBinaryConsentForAdvertising == "1" {
                ALPrivacySettings.setHasUserConsent(true)
            } else {
                ALPrivacySettings.setHasUserConsent(false)
            }
        } else {
            // If GDPR does not apply, AppLovin user consent can be set to accepted.
            ALPrivacySettings.setHasUserConsent(true)
        }
    }
}
