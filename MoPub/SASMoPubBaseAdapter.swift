//
//  SASMoPubBaseAdapter.swift
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 11/08/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

import UIKit
import SASDisplayKit
import MoPubSDK

/**
 MoPub base adapter class for Smart SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Smart.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
class SASMoPubBaseAdapter : NSObject {
    
    /**
     Constants used to produce errors.
     */
    class ErrorConstants {
        static let errorDomain = "SASMoPubAdapter"
        
        static let errorCodeNoAd = 100
        static let errorCodeCMPDisplayed = 200
        static let errorCodeNoReward = 300
    }
    
    /// MoPub ad unit ID.
    var adUnitID: String = ""
    
    /**
     Configure the ad unit ID used by MoPub from the server parameter string provided
     by the Smart SDK.
     
     @param serverParameterString The server parameter string provided by Smart.
     */
    func configureApplicationID(serverParameterString: String) {
        self.adUnitID = serverParameterString
    }
    
    /**
     Configure GDPR for MoPub SDK from the client parameters dictionary provided by the
     Smart SDK.
     
     @param clientParameters The client parameters dictionary provided by Smart.
     @return true if MoPub will attempt to show a CMP consent dialog, false otherwise.
     */
    func configureGDPR(clientParameters: [AnyHashable : Any], viewController: UIViewController) -> Bool {
        if MoPub.sharedInstance().shouldShowConsentDialog {
            MoPub.sharedInstance().loadConsentDialog { error in
                if error == nil {
                    MoPub.sharedInstance().showConsentDialog(from: viewController, completion: nil)
                }
            }
            return true
        } else {
            return false
        }
    }
    
    /**
     Initialize the MoPub SDK if necessary then call a completion block that can be used to perform
     the ad call.
     
     @param completion A completion handler that will be called when the SDK is initialized properly.
     */
    func initializeMoPubSDK(completion: @escaping () -> ()) {
        if MoPub.sharedInstance().isSdkInitialized {
            completion()
        } else {
            MoPub.sharedInstance().initializeSdk(with: MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID)) {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}
