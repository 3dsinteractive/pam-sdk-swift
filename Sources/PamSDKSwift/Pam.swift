//
//  swift
//  pam-demo
//
//  Created by narongrit kanhanoi on 2/3/2564 BE.
//

import UIKit
import UserNotifications

struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}

struct PamConfig: Codable {
    var pamServer: String
    let publicDBAlias: String
    let loginDBAlias: String

    enum CodingKeys: String, CodingKey {
        case pamServer = "pam-server"
        case publicDBAlias = "public-db-alias"
        case loginDBAlias = "login-db-alias"
    }
}

public class Pam: NSObject {
    public static var shared = Pam()
    private let userDefault = UserDefaults.standard
    
    internal var config: PamConfig?
    private var custID: String?
    private var publicContactID: String?
    private var loginContactID: String?
    var isEnableLog = false

    public typealias ListenerCallBack = ([AnyHashable: Any]) -> Void

    private var onToken: [ListenerCallBack] = []
    private var onPushNotification: [ListenerCallBack] = []
    private var onConsent: [ListenerCallBack] = []

    internal var pendingNotification: [[AnyHashable: Any]] = []
    internal var isAppReady = false
    
    var queue = TrackerQueueManger()
    
    var sessionID: String?
    var sessionExpire:Date?
    
    var deleteLoginContactAfterPost = false
    var isAppLaunchTracked = false

    var pushToken:String?
    
    var onGetCustomerID:( ()->String? )?
    
    enum SaveKey: String {
        case custID = "cust_id"
        case contactID = "contact_id"
        case loginContactID = "login_contact_id"
    }
    
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, enableLog: Bool = false) throws {
        isEnableLog = enableLog
        
        queue.onQueueStart = {
            self.postTracker(event: $0.event, payload: $0.payload)
        }

        if let filepath = Bundle.main.path(forResource: "pam-config", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                config = try JSONDecoder().decode(PamConfig.self, from: contents.data(using: .utf8)!)
                if config?.pamServer.hasSuffix("/") ?? false {
                    config?.pamServer.removeLast()
                }

                if isEnableLog {
                    print("🦄 PAM :  initialize pamServer =", config?.pamServer ?? "")
                    print("🦄 PAM :  initialize loginDBAlias =", config?.loginDBAlias ?? "")
                    print("🦄 PAM :  initialize publicDBAlias =", config?.publicDBAlias ?? "")
                }
            } catch {
                throw RuntimeError("PAM Error!! Invalid JSON Format 'pam-config.json' \(error)")
            }
        } else {
            throw RuntimeError("PAM Error!! File not found 'pam-config.json'")
        }

        if let noti = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            print(noti)
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func updateCustomerID(){
        if let customerId = onGetCustomerID?() {
            self.userLogin(custID: customerId)
        }
    }

    func listen(_ event: String, callBack: @escaping ListenerCallBack) {
        if event.lowercased() == "ontoken" {
            onToken.append(callBack)
        } else if event.lowercased() == "onpushnotification" {
            onPushNotification.append(callBack)
        } else if event.lowercased() == "onConsent" {
            onConsent.append(callBack)
        }
    }

    internal func appReady() {
        if !isAppLaunchTracked {
            isAppLaunchTracked = true
            track(event: "app_launch")
            isAppReady = true
            pendingNotification.forEach {
                dispatch("onPushNotification", data: $0)
            }
            pendingNotification = []
            
            updateCustomerID()
        }
    }

    internal func dispatch(_ event: String, data: [AnyHashable: Any]) {
        var channel: [ListenerCallBack] = []

        if event.lowercased() == "ontoken" {
            channel = onToken
        } else if event.lowercased() == "onpushnotification" {
            channel = onPushNotification
        } else if event.lowercased() == "onconsent" {
            channel = onConsent
        }

        channel.forEach {
            $0(data)
        }
    }

    func askNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                if self.isEnableLog {
                    print("🦄 PAM :  askNotificationPermission", error)
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func getSessionID() -> String {
        
        let exp = sessionExpire ?? Date(timeIntervalSince1970: 0)
        let now = Date()
        let diff = getDateDiff(start: exp, end: now )

        self.sessionExpire = Date(timeIntervalSinceNow: 3600 )//Expire Next 60 min
        
        if(diff >= 3600){
            self.sessionID = UUID().uuidString
            return sessionID ?? ""
        }
        
        if let sess = sessionID {
            return sess
        }else{
            sessionID = UUID().uuidString
        }
        
        return sessionID ?? ""
    }
    
    private func getDateDiff(start: Date, end: Date) -> Int  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        let seconds = dateComponents.second
        return Int(seconds!)
    }
    
    private func isUserLogin()-> Bool{
        return custID != nil
    }
    
    func track(event: String, payload: [String: Any]? = nil) {
        queue.enqueue(track: TrackQueue(event: event, payload: payload))
    }

    private func postTracker(event: String, payload: [String: Any]? = nil) {
        let url = (config?.pamServer ?? "") + "/trackers/events"

        var body: [String: Any] = [
            "event": event,
            "platform": "iOS: \(osVersion),  \(bundleID): \(versionBuild)",
            "form_fields": [],
        ]

        var formField: [String: Any] = [
            "os_version": "iOS \(osVersion)",
            "app_version": versionBuild,
            "_session_id": getSessionID()
        ]
        
        let publicContact = publicContactID ?? readValue(key: .contactID)
        let loginContact = loginContactID ?? readValue(key: .loginContactID)
        
        if let contactID = loginContact ?? publicContact {
            formField["_contact_id"] = contactID
        }
        
        payload?.forEach {
            if $0.key == "page_url" || $0.key == "page_title" {
                body[$0.key] = $0.value
            }else{
                formField[$0.key] = $0.value
            }
        }

        if isUserLogin() {
            formField["_database"] = config?.loginDBAlias ?? ""
            if let customer = custID ?? readValue(key: .custID) {
                formField["customer"] = customer
            }
        } else {
            formField["_database"] = config?.publicDBAlias ?? ""
        }

        body["form_fields"] = formField

        if isEnableLog {
            print("\n\n🦄 PAM : POST Event = 🍀\(event)🍀")
            print("🦄 PAM : Payload")
            print("🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉\n",PAMHelper.prettify(dict: body), "\n🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉\n\n")
        }

        HttpClient.post(url: url, queryString: nil, headers: nil, json: body) {
            if let contactID = $0?["contact_id"] as? String {
                
                if self.isUserLogin() {
                    self.saveValue(value: contactID, key: .loginContactID)
                    self.loginContactID = contactID
                } else {
                    self.saveValue(value: contactID, key: .contactID)
                    self.publicContactID = contactID
                }
                
                if self.isEnableLog {
                    print("🦄 PAM :Login=\(self.isUserLogin())  Received Contact ID=", contactID)
                }
                
                if self.deleteLoginContactAfterPost {
                    self.deleteLoginContactAfterPost = false
                    self.custID = nil
                    self.loginContactID = nil
                    self.removeValue(key: .custID)
                    self.removeValue(key: .loginContactID)
                }
                
                DispatchQueue.main.async {
                    self.queue.next()
                }
                
            }
        }
    }
    
    func userLogin(custID: String) {
        saveValue(value: custID, key: .custID)
        self.custID = custID
    
        track(event: "login")
        if let token = self.pushToken {
            track(event: "save_push", payload: ["ios_notification": token])
        }
    }

    func userLogout() {
        if isEnableLog {
            print("🦄 PAM :  Logout")
        }
        
        track(event: "logout", payload: ["_delete_media": ["ios_notification": ""]])
        if let token = self.pushToken {
            track(event: "save_push", payload: ["ios_notification": token])
        }
        
        deleteLoginContactAfterPost = true
    }

    public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        if userInfo["pam"] != nil {
            if isAppReady {
                dispatch("onPushNotification", data: userInfo)
            } else {
                pendingNotification.append(userInfo)
            }

            fetchCompletionHandler(.newData)
            return false
        }

        return true
    }

    private func saveValue(value: String, key: SaveKey) {
        userDefault.set(value, forKey: key.rawValue)
        userDefault.synchronize()
    }

    private func readValue(key: SaveKey) -> String? {
        return userDefault.string(forKey: key.rawValue)
    }

    private func removeValue(key: SaveKey) {
        userDefault.removeObject(forKey: key.rawValue)
        userDefault.synchronize()
    }

    func setDeviceToken(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        #if DEBUG
            let saveToken = "_" + token
        #else
            let saveToken = token
        #endif
        pushToken = saveToken
        track(event: "save_push", payload: ["ios_notification": saveToken])

        if isEnableLog {
            print("🦄 PAM :  Save Push Notification Token=\(saveToken)")
        }

        dispatch("onToken", data: ["token": token])
    }
}


