//
//  TrackingConsentManager.swift
//  
//
//  Created by narongrit kanhanoi on 9/4/2564 BE.
//

import Foundation

class TrackingConsentManager{
    
    private var consentID: String?
    
    init(consentID: String){
        self.consentID = consentID
    }
    
    static func create(consentID: String)-> TrackingConsentManager{
        let manager = TrackingConsentManager(consentID: consentID )
        return manager
    }
    
    func loadConsentMessage() {
//        Pam.shared.config?.pamServer
//        HttpClient.get(url: <#T##String#>, queryString: <#T##[String : String]?#>, headers: <#T##[String : String]?#>, onSuccess: <#T##HttpClient.OnSuccess?##HttpClient.OnSuccess?##([String : Any]?) -> Void#>)
//
//        
    }
    
}
