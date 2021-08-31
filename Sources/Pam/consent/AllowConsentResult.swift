
public struct AllowConsentResult{
    
    let contactID: String?
    let database: String?
    let consentID: String?
    
    static func parse(json: Json)-> AllowConsentResult{
        let contactID = json[\.contact_id].string
        let database = json[\._database].string
        let consentID = json[\.consent_id].string
        
        return AllowConsentResult(contactID: contactID,
                                  database: database,
                                  consentID: consentID)
    }
}
