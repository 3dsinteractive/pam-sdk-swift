//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//
import UIKit

public enum NotiReaderType {
    case popup
    case webLink
    case appLink
    case noLink
}

public enum NotiURLType {
    case http
    case scheme
    case noUrl
}


public class PamNoti{
    
    public var flex: String?
    public var pixel: String?
    public var url: String?
    public var title: String?
    public var message: String?
    public var popupType: String?
    
    public static func create(noti: [AnyHashable: Any])->PamNoti?{
        
        if let pam = noti["pam"] as? [AnyHashable:Any] {
            
            let pamNoti = PamNoti()
            pamNoti.flex = pam["flex"] as? String
            pamNoti.pixel = pam["pixel"] as? String
            pamNoti.url = pam["url"] as? String
            pamNoti.popupType = pam["popupType"] as? String
            
            if let aps = noti["aps"] as? [AnyHashable: Any] {
                if let alert = aps["alert"] as? [AnyHashable: Any] {
                    pamNoti.title = alert["title"] as? String
                    pamNoti.message = alert["body"] as? String
                }
            }
            
            return pamNoti
        }
        
        return nil
    }
    
    public func createPopup() -> UIViewController{
        let view = UIViewController()
        if let flex = flex{
            let pamView = Pamson.parse(flex)
            _ = Pamson.renderView(element: pamView, parent: view.view)
        }
        return view
    }
    
    public func getURLType() -> NotiURLType {
        guard let url = url else {return .noUrl}
        if url.lowercased().hasPrefix("http") {
            return .http
        }
        return .scheme
    }
    
    public func getNotiType() -> NotiReaderType{
        if popupType == "Fullscreen Popup" {
            return .popup
        }else if  popupType == "No Popup" {
            let urlType = getURLType()
            if getURLType() == .http {
                return .webLink
            }else if urlType == .scheme{
                return .appLink
            }
        }
        return .noLink
        // "Fullscreen Popup", "No Popup"
    }
    
    public func markAsRead(){
        if let url = URL(string: pixel ?? "") {
            let sess = URLSession.shared
            sess.dataTask(with: url).resume()
        }
    }
}
