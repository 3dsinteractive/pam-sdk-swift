//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation
import UserNotifications

extension Pam: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.sound, .badge, .banner])
        } else {
            completionHandler([.sound, .badge])
        }
    }

    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if isAppReady {
            dispatch("onPushNotification", data: response.notification.request.content.userInfo)
        } else {
            pendingNotification.append(response.notification.request.content.userInfo)
        }

        completionHandler()
    }
    
}
