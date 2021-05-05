//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//
import UIKit

public class PamNoti{
    
    public var flex: String?
    public var pixel: String?
    public var url: String?
    public var title: String?
    public var message: String?
    
    public static func create(noti: [AnyHashable: Any])->PamNoti?{
        
        if let pam = noti["pam"] as? [AnyHashable:Any] {
            
            let pamNoti = PamNoti()
            pamNoti.flex = pam["flex"] as? String
            pamNoti.pixel = pam["pixel"] as? String
            pamNoti.url = pam["url"] as? String
            
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
    
    public func markAsRead(){
        if let url = URL(string: pixel ?? "") {
            let sess = URLSession.shared
            sess.dataTask(with: url).resume()
        }
    }
}
