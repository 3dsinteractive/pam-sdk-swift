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
    
    static func loadPushNotifications(mobile: String, onLoad: OnLoadNotifications? = nil ){
        let db = Pam.getDatabaseAlias()
        let contactID = Pam.getContactID() ?? "-"
        let pamServerURL = Pam.shared.config?.pamServer ?? ""

        let endpoint = "\(pamServerURL)/api/app-notifications/"
        
        let queryString = [
            "_contact_id": contactID,
            "sms": mobile,
            "_database": db
        ]
        
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
    
    static func loadPushNotifications(email: String, onLoad: OnLoadNotifications? = nil){
        let db = Pam.getDatabaseAlias()
        let contactID = Pam.getContactID() ?? "-"
        let pamServerURL = Pam.shared.config?.pamServer ?? ""

        let endpoint = "\(pamServerURL)/api/app-notifications/"
        
        let queryString = [
            "_contact_id": contactID,
            "email": email,
            "_database": db
        ]
        
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
    
    static func loadPushNotifications(customerID: String, onLoad: OnLoadNotifications? = nil){
        let db = Pam.getDatabaseAlias()
        let contactID = Pam.getContactID() ?? "-"
        let pamServerURL = Pam.shared.config?.pamServer ?? ""

        let endpoint = "\(pamServerURL)/api/app-notifications/"
        
        let queryString = [
            "_contact_id": contactID,
            "customer": customerID,
            "_database": db
        ]
        
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
