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

public struct PamResponse: Codable{
    let code: String?
    let message: String?
    let contactID: String?
    let database: String?
    let consentID:String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case contactID = "contact_id"
        case database = "_database"
        case consentID = "consent_id"
    }
}

struct PamConfig: Codable {
    var pamServer: String
    let publicDBAlias: String
    let loginDBAlias: String
    let trackingConsentMessageID:String?

    enum CodingKeys: String, CodingKey {
        case pamServer = "pam-server"
        case publicDBAlias = "public-db-alias"
        case loginDBAlias = "login-db-alias"
        case trackingConsentMessageID = "pam-tracking-consent-message-id"
    }
}

public typealias TrackerCallback = (PamResponse) -> Void

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
    
    var isAppLaunchTracked = false

    var pushToken:String?
    
    var _allowTracking:Bool = false
    var allowTracking: Bool {
        set{
            self._allowTracking = newValue
            saveValue(value: newValue, key: .allowTracking)
        }
        get{
            return _allowTracking
        }
    }
    
    enum SaveKey: String {
        case customerID = "@pam_customer_id"
        case contactID = "@_pam_contact_id"
        case loginContactID = "@_pam_login_contact_id"
        case pushKey = "@_pam_push_key"
        case allowTracking = "@_pam_allow_tracking"
    }
    
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, enableLog: Bool = false) throws {
        isEnableLog = enableLog
        allowTracking = readBoolValue(key: .allowTracking) ?? false
        
        queue.onQueueStart = {
            self.postTracker(event: $0.event, payload: $0.payload, trackerCallBack: $0.trackerCallBack)
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
            if isEnableLog {
                print(noti)
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func fetchNotificationHistory(callBack: ([NotificationItem])->Void?){
//            if(custID == null && getContactID() == null) {
//                callBack(null)
//            }
//
//            val url = "${options?.pamServer!!}/api/app-notifications"
//
//            val query = mutableMapOf<String, String>(
//                "_database" to (getDatabaseAlias() ?: "")
//            )
//
//            custID?.let{
//                query["customer"] = it
//            }
//
//            getContactID()?.let{
//                query["_contact_id"] = it
//            }
//
//            Http.getInstance().get(
//                url=url,
//                queryString = query
//            ){ result, _ ->
//                val model = Gson().fromJson(result, NotificationList::class.java)
//                CoroutineScope(Dispatchers.Main).launch {
//                    callBack.invoke(model.items)
//                }
//            }
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
    
    func track(event: String, payload: [String: Any]? = nil, trackerCallBack: TrackerCallback? = nil) {
        queue.enqueue(track: TrackQueue(event: event, payload: payload, trackerCallBack: trackerCallBack))
    }
    
    func getLoginContactID()->String?{
        if loginContactID != nil && loginContactID != ""{
            return loginContactID
        }
        
        let loginContactID = readValue(key: .loginContactID)
        if loginContactID != nil && loginContactID != "" {
            return loginContactID
        }
        
        return nil
    }
    
    func getPublicContactID()->String?{
        if publicContactID != nil && publicContactID != ""{
            return publicContactID
        }
        
        let loginContactID = readValue(key: .contactID)
        if loginContactID != nil && loginContactID != "" {
            return loginContactID
        }
        
        return nil
    }
    
    public func getContactID() -> String? {
        let publicContact = publicContactID ?? readValue(key: .contactID)
        let loginContact = loginContactID ?? readValue(key: .loginContactID)
        return loginContact ?? publicContact
    }

    private func postTracker(event: String, payload: [String: Any]? = nil, trackerCallBack: TrackerCallback? = nil) {
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
        
        if let trackingConsentMessageID = config?.trackingConsentMessageID{
            formField["_consent_message_id"] = trackingConsentMessageID
        }
        
        if let contactID = getContactID() {
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
            if let customer = custID ?? readValue(key: .customerID) {
                formField["customer"] = customer
            }
        } else {
            formField["_database"] = config?.publicDBAlias ?? ""
        }
        
        if let uuid = Pam.getDeviceUUID() {
            formField["uuid"] = uuid
        }

        body["form_fields"] = formField

        if isEnableLog {
            print("\n\n🦄 PAM : POST Event = 🍀\(event)🍀")
            print("🦄 PAM : Payload")
            print("🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉\n",PAMHelper.prettify(dict: body), "\n🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉🍉\n\n")
        }

        HttpClient.post(url: url, queryString: nil, headers: nil, json: body) { res in
            if let contactID = res?["contact_id"] as? String {
                
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
                
            }
            
            let response = PamResponse(code: res?["code"] as? String,
                        message: res?["message"] as? String,
                        contactID: res?["contact_id"] as? String,
                        database: res?["database"] as? String,
                        consentID: res?["consent_id"] as? String)
            
            DispatchQueue.main.async {
                trackerCallBack?(response)
                self.queue.next()
            }
            
        }
    }
    
    func userLogin(custID: String) {
        
        track(event: "delete_media", payload: ["_delete_media": ["ios_notification": ""]])
        
        saveValue(value: custID, key: .customerID)
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
        
        track(event: "delete_media", payload: ["_delete_media": ["ios_notification": ""]])
        track(event: "logout"){ _ in
            self.custID = nil
            self.loginContactID = nil
            self.removeValue(key: .customerID)
            self.removeValue(key: .loginContactID)
        }
        
        removeValue(key: .customerID)
        self.custID = nil
    
        if let token = self.pushToken {
            track(event: "save_push", payload: ["ios_notification": token])
        }
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
    
    private func saveValue(value: Bool, key: SaveKey) {
        userDefault.set(value, forKey: key.rawValue)
        userDefault.synchronize()
    }

    private func readValue(key: SaveKey) -> String? {
        return userDefault.string(forKey: key.rawValue)
    }
    
    private func readBoolValue(key: SaveKey)-> Bool? {
        return userDefault.bool(forKey: key.rawValue)
    }

    private func removeValue(key: SaveKey) {
        userDefault.removeObject(forKey: key.rawValue)
        userDefault.synchronize()
    }

    func setDeviceToken(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        setDeviceToken(deviceToken: token)
    }
    
    func setDeviceToken(deviceToken: String) {
        #if DEBUG
            let saveToken = "_\(deviceToken)"
        #else
            let saveToken = deviceToken
        #endif
        track(event: "save_push", payload: ["ios_notification": saveToken])
        if isEnableLog {
            print("🦄 PAM :  Save Push Notification Token=\(saveToken)")
        }
        dispatch("onToken", data: ["token": deviceToken])
    }
    
    
}


