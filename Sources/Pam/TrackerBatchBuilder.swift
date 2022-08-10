//
//  TrackerBatchBuilder.swift
//  
//
//  Created by narongrit kanhanoi on 29/6/2565 BE.
//

import Foundation

//{ "events": [..] }

struct TrackerItem {
    let event: String
    let payload: [String: Any]
}
class TrackerBatchBuilder {
    
    var trackers: [TrackerItem] = []
    
    func addEvent(event: String, payload: [String: Any]? = nil){
        trackers.append(TrackerItem(event: event, payload: payload ?? [:]))
    }
    
    func build() -> [String: Any]{
//        var events:[[String:Any]] = [[:]]
//
//        trackers.forEach { item in
//
//            var formField: [String: Any] = [
//                "os_version": "iOS \(Pam.shared.osVersion)",
//                "app_version": Pam.shared.versionBuild,
//                "_session_id": Pam.shared.getSessionID()
//            ]
//
//            if let trackingConsentMessageID = Pam.shared.config?.trackingConsentMessageID{
//               // Pam.shared.tracking
//                formField["_consent_message_id"] = trackingConsentMessageID
//            }
//
//            if let contactID = Pam.shared.getContactID() {
//                formField["_contact_id"] = contactID
//            }
//
//            var event:[String:Any] = [
//                "event": event,
//                "platform": "iOS: \(Pam.shared.osVersion),  \(Pam.shared.bundleID): \(Pam.shared.versionBuild)"
//            ]
//
//            item.payload?.forEach {
//                if $0.key == "page_url" || $0.key == "page_title" {
//                    event[$0.key] = $0.value
//                }else{
//                    formField[$0.key] = $0.value
//                }
//            }
//
//            if Pam.shared.isUserLogin() {
//                formField["_database"] = Pam.shared.config?.loginDBAlias ?? ""
//                if let customer = Pam.shared.getCustomerID() ?? Pam.shared.readValue(key: .customerID) {
//                    formField["customer"] = customer
//                }
//            } else {
//                formField["_database"] = Pam.shared.config?.publicDBAlias ?? ""
//            }
//
//            if let uuid = Pam.getDeviceUUID() {
//                formField["uuid"] = uuid
//            }
//
//            event["form_fields"] = formField
//
//            events.append(event)
       // }
        
        let res: [String: Any] = [
            "events": [:]
        ]
    
        return res
    }
    
}
