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
    public let isOpen: Bool
    public let date: Date?
    public let payload: [String: Any]?
    public let bannerUrl: String?
    
    public func read(){
        NotificationAPI.read(message: self)
    }
    
    static func parse(json: String?)-> [PamPushMessage] {
        guard let data = json?.data(using: .utf8) else{ return [] }
        
        var arr: [PamPushMessage]?
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            if let items = json["items"] as? [[String: Any]] {
                arr = items.map { item in
                    let deliverID = item["deliver_id"] as? String
                    let pixel = item["pixel"] as? String
                    let title = item["title"] as? String
                    let description = item["description"] as? String
                    let thumbnailUrl = item["thumbnail_url"] as? String
                    let flex = item["flex"] as? String
                    let url = item["url"] as? String
                    
                    var payload = item["json_data"] as? [String: Any]
                    payload = payload?["pam"] as? [String: Any]
                    
                    let popupType = payload?["popupType"] as? String
                    let date = item["created_date"] as? String
                    let isOpen = item["is_open"] as? Bool
                    var bannerUrl: String?
                    
                    if let flex = flex {
                        if let flexView = FlexParser.shared.parse(flex: flex) as? PContainer {
                            if let img = flexView.childs[0] as? PImage {
                                bannerUrl = img.props["src"]
                            }
                        }
                    }
                    
                    
                    
                    return PamPushMessage(
                        deliverID: deliverID,
                        pixel: pixel,
                        title: title,
                        description: description,
                        thumbnailUrl: thumbnailUrl,
                        flex: flex,
                        url: url,
                        popupType: popupType,
                        isOpen: isOpen ?? true,
                        date: PAMUtils.dateFrom(string: date),
                        payload: payload,
                        bannerUrl: bannerUrl
                    )
                }
            }
            
        }
        
        return arr ?? []
    }
}
