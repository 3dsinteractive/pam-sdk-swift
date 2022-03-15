//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation
import UserNotifications

public class PAMUtils {
    static func prettify(dict: [String: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    static func dateFrom(string: String?) -> Date?{
        guard let date = string else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from:date)
        return dateObj
    }
    
    public static func isPamNotification(_ notification: UNNotification) -> Bool{
        if notification.request.content.userInfo["pam"] != nil {
            return true
        }
        return false
    }
    
    public static func convertUNNotificationToPam(_ notification: UNNotification) -> PamPushMessage? {
        if let data = notification.request.content.userInfo["pam"] as? NSDictionary {
            let url = data.object(forKey: "url") as? String
            let popupType = data.object(forKey: "popupType") as? String
            let pixel = data.object(forKey: "pixel") as? String
            let flex = data.object(forKey: "flex") as? String
            
            let aps = notification.request.content.userInfo["aps"] as? [String: Any]
            let alert = aps?["alert"] as? [String: String]
            let title = alert?["title"]
            let body = alert?["body"]
            
            var payload:[String: Any] = [:]
            for (value, key) in data {
                payload[key as! String] = value
            }
            
            return PamPushMessage(
                deliverID: nil,
                pixel: pixel,
                title: title,
                description: body,
                thumbnailUrl: nil,
                flex: flex,
                url: url,
                popupType: popupType,
                isRead: false,
                date: Date(),
                data: payload,
                pam: nil)
        }
        
        return nil
    }
}

