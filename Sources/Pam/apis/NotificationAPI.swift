//
//  NotificationAPI.swift
//  
//
//  Created by narongrit kanhanoi on 1/3/2565 BE.
//

import Foundation

class NotificationAPI {
    
    typealias OnLoadNotifications = ([PamPushMessage])->Void
    
    static func read(message:PamPushMessage?){
        guard let pixel = message?.pixel else { return }
        
        HttpClient.getReturnData(url: pixel, queryString: nil, headers: nil,onSuccess: nil)
    }
    
    static func loadPushNotifications(mobile: String? = nil, email: String? = nil, customerID: String? = nil, contactID: String? = nil, onLoad: OnLoadNotifications? = nil ){
        
        let db = Pam.getDatabaseAlias()
        
        var _contactID: String?
        if contactID == nil {
            _contactID = Pam.getContactID()
        }else{
            _contactID = contactID
        }
        
        let pamServerURL = Pam.shared.config?.pamServer ?? ""

        let endpoint = "\(pamServerURL)/api/app-notifications"
        
        var queryString = [
            "_database": db
        ]
        
        if let mobile = mobile {
            queryString["sms"] = mobile
        }
        
        if let email = email {
            queryString["email"] = email
        }
        
        if let customerID = customerID {
            queryString["customer"] = customerID
        }
        
        if let _contactID = _contactID {
            queryString["_contact_id"] = _contactID
        }
        
        HttpClient.getReturnData(url: endpoint, queryString: queryString, headers: nil){ data in
            guard let data = data else {
                onLoad?([])
                return
            }
            
            let res = String(data:data, encoding: .utf8)
            let messages = PamPushMessage.parse(json: res)
            onLoad?(messages)
        }
    }
    
    
}
