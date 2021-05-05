//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation
import UIKit

extension Pam {
    
    public static func track(event: String, payload: [String: Any]? = nil) {
        Pam.shared.track(event: event, payload: payload)
    }

    public static func userLogin() {
        Pam.shared.updateCustomerID()
    }

    public static func userLogout() {
        Pam.shared.userLogout()
    }

    public static func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, enableLog: Bool = false) throws {
        try Pam.shared.initialize(launchOptions: launchOptions, enableLog: enableLog)
    }
    
    public static func getCustomerID(){
        
    }
    
    public static func listen(_ event: String, callBack: @escaping ListenerCallBack) {
        Pam.shared.listen(event, callBack: callBack)
    }

    public static func setDeviceToken(deviceToken: Data) {
        Pam.shared.setDeviceToken(deviceToken: deviceToken)
    }

    public static func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        return Pam.shared.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: fetchCompletionHandler)
    }

    public static func askNotificationPermission() {
        Pam.shared.askNotificationPermission()
    }

    public static func appReady() {
        Pam.shared.appReady()
    }
}
