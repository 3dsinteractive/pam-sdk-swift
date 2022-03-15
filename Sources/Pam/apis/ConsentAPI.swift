class ConsentAPI {
    
    typealias OnLoadConsentMessage = ([String: BaseConsentMessage])->Void
    typealias OnSubmitConsent = ([String:AllowConsentResult])->Void
    typealias OnLoadPermission = ([String:UserConsentPermissions])->Void
    
    private var consentMessagesIdQueue: [String]?
    private var isLoading = false
    private var index = 0
    
    private var resultMessages: [String: BaseConsentMessage]?
    private var _onConsentLoadCallBack: OnLoadConsentMessage?
    
    private var submitConsentQueue: [BaseConsentMessage?]?
    private var resultSubmit: [String: AllowConsentResult]?
    private var _onConsentSubmitCallBack: OnSubmitConsent?
    
    private var resultUserConsentLoad: [String: UserConsentPermissions]?
    private var _onPermissionLoadCallBack: OnLoadPermission?
    
    func setOnPermissionLoadCallBack(callBack: @escaping OnLoadPermission){
        _onPermissionLoadCallBack = callBack
    }
    
    func setOnConsentLoaded(callBack: @escaping OnLoadConsentMessage){
        _onConsentLoadCallBack = callBack
    }
    
    func setOnConsentSubmit(callBack: @escaping OnSubmitConsent){
        _onConsentSubmitCallBack = callBack
    }
    
    func loadConsent(consentMessageID: [String]) {
        if (!isLoading) {
            consentMessagesIdQueue = consentMessageID
            index = 0
            resultMessages = [:]
            startLoadConsentMessage()
        }
    }
    
    func submitConsents(consents: [BaseConsentMessage?]){
        if (!isLoading) {
            submitConsentQueue = consents
            index = 0
            resultSubmit = [:]
            startSubmit()
        }
    }
    
    func loadConsentPermissions(consentMessageIDs: [String]){
        if (!isLoading) {
            consentMessagesIdQueue = consentMessageIDs
            index = 0
            resultUserConsentLoad = [:]
            startLoadPermissions()
        }
    }
    
    private func startSubmit(){
        if index == (submitConsentQueue?.count ?? 0){
            if let resultSubmit = resultSubmit{
                _onConsentSubmitCallBack?(resultSubmit)
            }
            isLoading = false
            return
        }
        
        let submitConsent = submitConsentQueue?[index]
        index += 1
        
        if(submitConsent == nil || submitConsent is ConsentMessageError){
            startSubmit()
            return
        }
        isLoading = true
        
        if let consent = submitConsent as? ConsentMessage {
            var payload:[String: Any] = ["_consent_message_id": consent.id]
            
            payload["_version"] = consent.version
            
            consent.permission.forEach{ it in
                payload[it.getSubmitKey()] = it.allow
                
                if let trackingConsentMessageID = Pam.shared.config?.trackingConsentMessageID {
                    if(consent.id == trackingConsentMessageID && it.getSubmitKey() == "_allow_preferences_cookies"){
                        Pam.shared.allowTracking = it.allow
                    }
                }
            }
            
            Pam.track(event: "allow_consent", payload: payload){ res in
                self.resultSubmit?[consent.id] = AllowConsentResult(contactID: res.contactID, database: res.database, consentID: res.consentID)
                self.startSubmit()
            }
        }
    }
    
    private func startLoadConsentMessage(){
        if index == (consentMessagesIdQueue?.count ?? 0){
            if let resultMessages = resultMessages {
                _onConsentLoadCallBack?(resultMessages)
            }
            isLoading = false
            return
        }
        
        let consentMessageID = consentMessagesIdQueue?[index] ?? ""
        
        index += 1
        if consentMessageID == "" {
            startLoadConsentMessage()
            return
        }
        
        isLoading = true
        let pamServerURL = Pam.shared.config?.pamServer ?? ""
      
        HttpClient.getReturnData(url: "\(pamServerURL)/consent-message/\(consentMessageID)", queryString: nil, headers: nil){ data in
            
            if let data = data {
                let json = Json(raw: String(data:data, encoding: .utf8) ?? "{}")
                
                let consentMessage = ConsentMessage.parse(json: json)
                self.resultMessages?[consentMessageID] = consentMessage
                
            }else{
                let error = ConsentMessageError(errorMessage: "Empty Response From Server.", errorCode: "SERVER_EMPTY_RESPONSE")
                self.resultMessages?[consentMessageID] = error
            }
            
            self.startLoadConsentMessage()
        }
        
    }
    
    private func startLoadPermissions(){
        if index == (consentMessagesIdQueue?.count ?? 0) {
            
            if let resultUserConsentLoad = resultUserConsentLoad {
                _onPermissionLoadCallBack?(resultUserConsentLoad)
            }
            isLoading = false
            return
        }
        
        let consentMessageID = consentMessagesIdQueue?[index] ?? ""
        
        index += 1
        if consentMessageID == "" {
            startLoadPermissions()
            return
        }
        
        isLoading = true
        let pamServerURL = Pam.shared.config?.pamServer ?? ""
        if let contactID = Pam.shared.getContactID() {
            
            HttpClient.getReturnData(url: "\(pamServerURL)/contacts/\(contactID)/consents/\(consentMessageID)", queryString: nil, headers: nil){ data in
                
                if let data = data {
                    let json = Json(raw: String(data:data, encoding: .utf8) ?? "{}")
                    
                    let userConsent = UserConsentPermissions.parse(json: json)
                    self.resultUserConsentLoad?[consentMessageID] = userConsent
                }
                
                self.startLoadPermissions()
            }
        }else{
            let userConsent = UserConsentPermissions(consentID: nil,
                                                     type: nil,
                                                     consentMessageId: consentMessageID,
                                                     version: nil,
                                                     permissions: nil,
                                                     needToReview: true,
                                                     lastConsentVersion: nil,
                                                     contactID: nil,
                                                     lastConsentAt: nil)
            self.resultUserConsentLoad?[consentMessageID] = userConsent
            self.startLoadPermissions()
        }
        
    }
    
}
