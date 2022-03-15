//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 15/3/2565 BE.
//

import Foundation

public struct PamPushMessage {
    public let deliverID:String?
    public let pixel:String?
    public let title:String?
    public let description:String?
    public let thumbnailUrl:String?
    public let flex:String?
    public let url:String?
    public let popupType:String?
    public let isRead: Bool
    public let date: Date?
    public let data: NSDictionary?
    public let pam: NSDictionary?
    
    public func read(){
        NotificationAPI.read(message: self)
    }
    
    static func parse(json: String?)-> [PamPushMessage] {
        guard let data = json?.data(using: .utf8) else{ return [] }
        
        var arr: [PamPushMessage]?
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? NSDictionary{
            
            if let items = json.object(forKey:"items") as? [NSDictionary] {
                arr = items.map { item in
                    
                    let deliverID = item.object(forKey:"deliver_id") as? String
                    let pixel = item.object(forKey:"pixel") as? String
                    let title = item.object(forKey:"title") as? String
                    let description = item.object(forKey:"description") as? String
                    let thumbnailUrl = item.object(forKey:"thumbnail_url") as? String
                    let flex = item.object(forKey:"flex") as? String
                    let url = item.object(forKey:"url") as? String
                    let data = item.object(forKey:"json_data") as? NSDictionary
                    let pam = item.object(forKey:"pam") as? NSDictionary
                    let popupType = item.object(forKey:"popupType") as? String
                    let date = item.object(forKey:"created_date") as? String
                    let isRead = item.object(forKey:"is_open") as? Bool
                    
                    return PamPushMessage(
                        deliverID: deliverID,
                        pixel: pixel,
                        title: title,
                        description: description,
                        thumbnailUrl: thumbnailUrl,
                        flex: flex,
                        url: url,
                        popupType: popupType,
                        isRead: isRead ?? true,
                        date: PAMHelper.dateFrom(string: date),
                        data: data,
                        pam: pam)
                }
            }
        }
        
        return arr ?? []
    }
}
