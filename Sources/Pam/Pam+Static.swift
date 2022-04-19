//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation
import UIKit

extension Pam {
    
    public static func getDatabaseAlias() -> String {
        return Pam.shared.getDatabaseAlias()
    }
    
    public static func track(event: String, payload: [String: Any]? = nil, trackerCallBack: TrackerCallback? = nil) {
        Pam.shared.track(event: event, payload: payload, trackerCallBack: trackerCallBack)
    }
    
    public static func onSyncLoginState(callBack:()->CustomerID){
        
    }
    
    public static func getContactID()->String?{
        return Pam.shared.getContactID()
    }
    
    public static func getDeviceUUID()->String?{
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    public static func userLogin(customerID: String) {
        Pam.shared.userLogin(custID: customerID)
    }
    
    public static func userLogout() {
        Pam.shared.userLogout()
    }
    
    public static func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, enableLog: Bool = false) throws {
        try Pam.shared.initialize(launchOptions: launchOptions, enableLog: enableLog)
    }
    
    public static func getCustomerID(){
        return Pam.shared.getCustomerID()
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
    
    public static func loadConsentPermissions(consentMessageIds: [String], onLoad: @escaping ([String: UserConsentPermissions]) -> Void) {
        let api = ConsentAPI()
        api.setOnPermissionLoadCallBack {
            $0.forEach { (key, value) in
                if key == (Pam.shared.config?.trackingConsentMessageID ?? "-empty-"){
                    value.permissions?.forEach{ perm in
                        if perm.name == .preferencesCookies {
                            Pam.shared.allowTracking = perm.allow
                        }
                    }
                }
            }
            onLoad($0)
        }
        api.loadConsentPermissions(consentMessageIDs: consentMessageIds)
    }
    
    public static func loadConsentPermissions(
        consentMessageIds: String,
        onLoad: @escaping (UserConsentPermissions) -> Void
    ) {
        loadConsentPermissions(consentMessageIds: [consentMessageIds]) { result in
            if let  userPermissions = result[consentMessageIds]{
                DispatchQueue.main.async {
                    onLoad(userPermissions)
                }
            }
        }
    }
    
    public static func loadConsentDetails(
        consentMessageIds: [String],
        onLoad: @escaping ([String: ConsentMessage]) -> Void
    ) {
        let api = ConsentAPI()
        api.setOnConsentLoaded{
            var messages:[String: ConsentMessage] = [:]
            $0.forEach{ key, consentMsg in
                if let consentMsg = consentMsg as? ConsentMessage{
                    messages[key] = consentMsg
                }
            }
            onLoad(messages)
        }
        api.loadConsent(consentMessageID: consentMessageIds)
    }
    
    public static func loadConsentDetails(consentMessageIds: String, onLoad: @escaping (ConsentMessage?) -> Void) {
        loadConsentDetails(consentMessageIds: [consentMessageIds]) { result in
            DispatchQueue.main.async {
                onLoad(result[consentMessageIds])
            }
        }
    }
    
    public static func submitConsent(
        consents: [BaseConsentMessage?],
        onSubmit: @escaping ([String: AllowConsentResult], String) -> Void
    ) {
        let api = ConsentAPI()
        api.setOnConsentSubmit { consentIDs in
            var ids:[String] = []
            consentIDs.forEach{ k, v in
                if let consentID = v.consentID {
                    ids.append(consentID)
                }
            }
            DispatchQueue.main.async {
                setAllowTracking(consents: consents)
                onSubmit(consentIDs, ids.joined(separator: ","))
            }
        }
        api.submitConsents(consents: consents)
    }
    
    private static func setAllowTracking(consents: [BaseConsentMessage?]){
        
        var consentMsgs = consents.compactMap { msg in
            msg as? ConsentMessage
        }
        
        consentMsgs = consentMsgs.filter{ msg in
            msg.id == (Pam.shared.config?.trackingConsentMessageID ?? "-empty-")
        }
        
        consentMsgs.forEach { msg in
            msg.permission.forEach { perm in
                if perm.name == .preferencesCookies  {
                    Pam.shared.allowTracking = perm.allow
                }
            }
        }
    }
    
    public static func submitConsent(
        consent: BaseConsentMessage?,
        onSubmit: @escaping (AllowConsentResult, String) -> Void
    ) {
        submitConsent(consents: [consent]) { result, consentIDs in
            if let consentMessage = consent as? ConsentMessage {
                if let result = result[consentMessage.id] {
                    DispatchQueue.main.async {
                        onSubmit(result, consentIDs)
                    }
                }
            }
        }
    }
    
    public static func setPushNotificationToken(token: String){
        Pam.shared.setDeviceToken(deviceToken: token)
    }
    
    public static func setPushNotificationToken(token: Data){
        Pam.shared.setDeviceToken(deviceToken: token)
    }
        
    static public func createNotificationReader(notificationData: [String: Any]?) -> PAMNotificationReader? {
        
        if let pamNoti = notificationData?["pam"] as? [String: String] {
            let url = pamNoti["url"]
            let flex = pamNoti["flex"]
            let pixel = pamNoti["pixel"]

            if let flex = flex {
                let parser = FlexLangParser()
                if let flexVC = parser.parse(flex: flex)?.render() {
                    return PAMNotificationReader(.reader, pixel: pixel, viewController: flexVC)
                }
            }

            if let url = url {
                if url.hasPrefix("http") {
                    return PAMNotificationReader(.url, pixel: pixel, url: url)
                } else {
                    return PAMNotificationReader(.scheme, pixel: pixel, url: url)
                }
            }
        }

        return nil
    }
    
    public static func resolvePixel(_ url: String?){
        guard let url = url else{return}
        HttpClient.getReturnData(url: url, queryString: nil, headers: nil, onSuccess: nil)
    }
    
    public static func loadPushNotifications(email: String, onLoad: @escaping ([PamPushMessage])->Void){
        NotificationAPI.loadPushNotifications(email: email){ list in
            onLoad(list)
        }
    }
    
    public static func loadPushNotifications(mobile: String, onLoad: @escaping ([PamPushMessage])->Void){
        NotificationAPI.loadPushNotifications(mobile: mobile){ list in
            onLoad(list)
        }
    }
    
    public static func loadPushNotifications(customerID: String, onLoad: @escaping ([PamPushMessage])->Void){
        NotificationAPI.loadPushNotifications(customerID: customerID){ list in
            onLoad(list)
        }
    }
    
}
