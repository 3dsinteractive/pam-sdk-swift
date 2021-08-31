//
//  TrackingConsentManager.swift
//  
//
//  Created by narongrit kanhanoi on 9/4/2564 BE.
//

import Foundation
import UIKit

public class TrackingConsentManager{
    public typealias OnAcceptConsent = (String, [String:Bool]?) -> Void
    public typealias OnReady = () -> Void
    
    private var consentID: String?
    public var onAcceptConsent: OnAcceptConsent?
    public var onReady:OnReady?
    
    var _isReady = false
    public var isReady: Bool {
        return _isReady
    }
    
    var consentMessage: TrackingConsentModel?
    var consentAllowModel: ConsentAllowModel?
    
    public init(){
        self.consentID = ""
        loadConsentMessage()
    }
    
    private func ready(){
        self._isReady = true
        self.onReady?()
    }
    
    func showConsentRequestPopup() {
        DispatchQueue.main.async {
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController, let consentMessage = self.consentMessage else{return}
            
            let vc = TrackingConsentRequestViewController.create(consentMessage: consentMessage )
            rootViewController.present(vc, animated: true) {
                
            }
        }
    }
    
    func loadConsentMessage() {
        let url = "\(Pam.shared.config?.pamServer ?? "")/consent-message/\(Pam.shared.config?.trackingConsentMessageID ?? "")"
        
        HttpClient.getReturnData(url: url, queryString: nil, headers: nil) { data in
            guard let data = data else{return}
            let decoder = JSONDecoder()
            self.consentMessage = try? decoder.decode(TrackingConsentModel.self, from: data)
            self.checkConsentPermission()
        }
    }
    
    func checkConsentPermission() {
        if let contactID = Pam.shared.getContactID() {
            let url = "\(Pam.shared.config?.pamServer ?? "")/contacts/\(contactID)/consents/\(Pam.shared.config?.trackingConsentMessageID ?? "")"
            
            HttpClient.getReturnData(url: url, queryString: nil, headers: nil) { data in
                guard let data = data else{return}
                
                let decoder = JSONDecoder()
                self.consentAllowModel = try? decoder.decode(ConsentAllowModel.self, from: data)

                if (self.consentAllowModel?.code == "NOT_FOUND" || self.consentAllowModel?.needConsentReview == true) {
                    self.showConsentRequestPopup()
                }else{
                    var allow: [String: Bool] = [:]
                   
                    if let it = self.consentAllowModel?.trackingPermission?.analyticsCookies {
                        allow["_allow_analytics_cookies"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.marketingCookies {
                        allow["_allow_marketing_cookies"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.necessaryCookies {
                        allow["_allow_necessary_cookies"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.preferencesCookies {
                        allow["_allow_preferences_cookies"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.privacyOverview {
                        allow["_allow_privacy_overview"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.socialMediaCookies {
                        allow["_allow_social_media_cookies"] = it
                    }

                    if let it = self.consentAllowModel?.trackingPermission?.termsAndConditions{
                        allow["_allow_terms_and_conditions"] = it
                    }
                    
                    self.onAcceptConsent?(Pam.shared.config?.trackingConsentMessageID ?? "", allow)
                }
                
                self.ready()
            }
        }
    }
    
}
