//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation


public class PamStandardEvent {
    
    public static func pageView(pageName:String,  pageURL:String?, contentID: String?, payload: [String:Any]?) {
        
        var payload = payload
        payload?["page_title"] = pageName
        payload?["page_url"] = pageURL
        
        if let id = contentID {
            payload?["id"] = id
        }
            
        Pam.track(event: "page_view",
                  payload: payload)
    }
}
