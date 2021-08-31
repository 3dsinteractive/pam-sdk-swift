//
//  NotificationItem.swift
//  
//
//  Created by narongrit kanhanoi on 30/6/2564 BE.
//

import Foundation

public struct Payload: Codable {
    let message: String?
    let pam: PamPayload?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case pam = "pam"
        case title = "title"
    }
}


public struct PamPayload: Codable {
    let createdDate: String?
    let flex: String?
    let pixel: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case flex = "flex"
        case pixel = "pixel"
        case url = "url"
    }
}

public struct NotificationItem: Codable {
    
    let createdDate: String?
    let deliverId: String?
    let description: String?
    let flex: String?
    let isOpen: Bool?
    let payload: Payload?
    let pixel: String?
    let thumbnailUrl: String?
    let title: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case deliverId = "deliver_id"
        case description = "description"
        case flex = "flex"
        case isOpen = "is_open"
        case payload = "json_data"
        case pixel = "pixel"
        case thumbnailUrl = "thumbnail_url"
        case title = "title"
        case url = "url"
    }
    
    public func trackOpen(){
        if let pixel = pixel {
            HttpClient.get(url: pixel, queryString: nil, headers: nil, onSuccess: nil)
        }
    }
    
}
