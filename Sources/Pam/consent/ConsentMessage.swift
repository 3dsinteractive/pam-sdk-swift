import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

public struct ConsentDialogStyleConfiguration{
    public let icon: String?
    public let primaryColor: UIColor?
    public let secondaryColor: UIColor?
    public let buttonTextColor: UIColor?
    public let textColor: UIColor?
    
}

public struct ConsentStyleConfiguration {
    
    public let backgroundColor: UIColor?
    public let textColor: UIColor?
    public let barBackgroundOpacity: Double?
    public let buttonBackgroundColor: UIColor?
    public let buttonTextColor: UIColor?
    public let dialogStyle: ConsentDialogStyleConfiguration?
    
    static func parse(json: Json?) -> ConsentStyleConfiguration?{
        
        guard let json = json else{ return nil}
        
        let backgroundColor = json[\.bar_background_color].string ?? "#000000"
        let textColor = json[\.bar_text_color].string ?? "#000000"
        let barBackgroundOpacity = (json[\.bar_background_opacity_percentage].double ?? 100.0)/100.0
        let buttonBackgroundColor = json[\.bar_text_color].string ?? "#FFFFFF"
        let buttonTextColor = json[\.button_text_color].string ?? "#000000"
        
        let it = json[\.consent_detail].json
        let icon = it[\.popup_main_icon].string
        let primaryColor = it[\.primary_color].string ?? "#FFFFFF"
        let secondaryColor = it[\.secondary_color].string ?? "#5C5C5C"
        let dialogButtonTextColor = it[\.button_text_color].string ?? "#000000"
        let dialogTextColor = it[\.text_color].string ?? "#000000"
        
        let dialogStyle = ConsentDialogStyleConfiguration(icon: icon,
                                                          primaryColor: UIColor(hex: primaryColor),
                                                          secondaryColor:  UIColor(hex: secondaryColor),
                                                          buttonTextColor: UIColor(hex: dialogButtonTextColor),
                                                          textColor: UIColor(hex: dialogTextColor))
        
        return ConsentStyleConfiguration(backgroundColor: UIColor(hex: backgroundColor),
                                         textColor: UIColor(hex: textColor),
                                         barBackgroundOpacity: barBackgroundOpacity,
                                         buttonBackgroundColor: UIColor(hex: buttonBackgroundColor),
                                         buttonTextColor: UIColor(hex: buttonTextColor),
                                         dialogStyle: dialogStyle)
    }
}

public enum LocaleText{
    case en
    case th
}

public struct Text{
    public let en:String?
    public let th: String?
    
    public func get(prefer: LocaleText)->String?{
        if(prefer == .en){
            if(en != nil){ return en }
            else if(th != nil){return th}
        }else{
            if(th != nil){ return th }
            else if(en != nil){return en}
        }
        return nil
    }
}

public protocol BaseConsentMessage {
    
}

public enum ConsentType{
    case Tracking
    case Contacting
}

public struct ValidationResult{
    public let isValid: Bool
    public let errorMessage: String?
    public let errorField: [String]?
}

public struct ConsentMessage: BaseConsentMessage{
    
    public let id: String
    public let type: ConsentType?
    public let name:String
    public let description: String
    public let style: ConsentStyleConfiguration?
    public let version: Int
    public let revision: Int
    public let displayText: Text?
    public let acceptButtonText: Text?
    public let consentDetailTitle: Text?
    public let availableLanguages: [String]
    public let defaultLanguage: String
    public var permission: [ConsentPermission]
    public let moreInfoButtonText: Text?
    
    public func allowAll(){
        for var item in permission{
            item.allow = true
        }
    }
    
    public func denyAll(){
        for var item in permission{
            item.allow = false
        }
    }
    
    public mutating func setPermission(name: ConsentPermissionName, isAllow: Bool) {
        
        for index in 0..<self.permission.count {
            if self.permission[index].name == name {
                self.permission[index].allow = isAllow
                
                if Pam.shared.isEnableLog {
                    print("SET", self.permission[index].name, "TO" , self.permission[index].allow)
                }
                break
            }
        }
    }
    
    public func validate()-> ValidationResult{
        var pass = true
        var errorField: [String]?
        var errorMessage:String?
        
        for p in permission{
            if(p.require && !p.allow){
                pass = false
                if errorField == nil {
                    errorField = []
                }
                errorField?.append(p.name.nameStr)
            }
        }
        if(!pass){
            let fields = errorField?.joined(separator: ", ") ?? ""
            errorMessage = "You must accept the required permissions (\(fields))"
        }
        return ValidationResult(isValid: pass, errorMessage: errorMessage, errorField: errorField)
    }
    
    private static func getType(json:Json)->ConsentType?{
        let type =  json[\.consent_message_type].string
        if type == "tracking_type" {
            return .Tracking
        }else if type == "contacting_type"{
            return .Contacting
        }
        return nil
    }
    
    private static func getText(json:Json?)-> Text?{
        guard let json = json else { return nil}
        return Text(
            en: json[\.en].string,
            th: json[\.th].string
        )
    }
    
    public static func parse(json:Json) -> ConsentMessage{
        let id = json[\.consent_message_id].string ?? ""
        let name = json[\.name].string ?? ""
        let description = json[\.description].string ?? ""
        let style = ConsentStyleConfiguration.parse(json: json[\.style_configuration].json)
        let setting = json[\.setting].json
        
        let type = getType(json: json)
        
        let version = setting[\.version].int ?? 0
        let revision = setting[\.version].int ?? 0
        let displayText = getText(json: setting[\.display_text].json)
        
        let moreInfoButtonText = getText(json: setting[\.more_info.display_text].json)
        
        //let moreInfoCustomURL = getText(json: setting[\.more_info.display_text].json)
        
        let acceptButtonText = getText(json: setting[\.accept_button_text].json)
        let consentDetailTitle = getText(json: setting[\.consent_detail_title])
        
        var availableLanguages:[String] = []
        if let langs = setting[\.available_languages].array {
            for lang in langs {
                if let lang = lang as? String{
                    availableLanguages.append(lang)
                }
            }
        }
        
        
        let defaultLanguage = setting[\.default_language].string ?? ""
        let permissions = ConsentPermission.parse(json: setting)
        
        
        return ConsentMessage(id: id,
                              type: type,
                              name: name,
                              description: description,
                              style: style,
                              version: version,
                              revision: revision,
                              displayText: displayText,
                              acceptButtonText: acceptButtonText,
                              consentDetailTitle: consentDetailTitle,
                              availableLanguages: availableLanguages,
                              defaultLanguage: defaultLanguage,
                              permission: permissions,
                              moreInfoButtonText: moreInfoButtonText
                            )
    }
    
}


public struct ConsentMessageError: BaseConsentMessage{
    public let errorMessage: String
    public let errorCode: String
}

public struct ConsentPermission{
    
    public let name: ConsentPermissionName
    public let shortDescription: Text?
    public let fullDescription: Text?
    public let fullDescriptionEnabled: Bool
    public let require: Bool
    public var allow = false
    
    private static func getText(_ json:Json?)-> Text?{
        guard let json = json else {return nil}
        return Text(
            en: json[\.en].string,
            th: json[\.th].string
        )
    }
    
    private static func parsePermission(json:Json?, key: ConsentPermissionName, require: Bool )-> ConsentPermission?{
        
        if let item = json?[dynamicMember: key.key].json {
            
            let isEnable = item[\.is_enabled].bool ?? false
            if !isEnable {
                return nil
            }
            
            
            let shortDescription = item[\.brief_description].json
            let fullDescription =  item[\.full_description].json
            let fullDescriptionEnabled = item[\.is_full_description_enabled].bool ?? false
            
            return ConsentPermission(name: key,
                                     shortDescription: ConsentPermission.getText(shortDescription),
                                     fullDescription: ConsentPermission.getText(fullDescription),
                                     fullDescriptionEnabled: fullDescriptionEnabled,
                                     require: require,
                                     allow: true)
        }
        
        return nil
    }
    
    static public func parse(json: Json?)-> [ConsentPermission]{
        var list:[ConsentPermission] = []
        
        if let perm = parsePermission(json: json, key: .termsAndConditions, require: true){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .privacyOverview, require: true){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .necessaryCookies, require: true){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .preferencesCookies, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .analyticsCookies, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .marketingCookies, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .socialMediaCookies, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .email, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .sms, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key:.line, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .facebookMessenger, require: false){
            list.append(perm)
        }
        
        if let perm = parsePermission(json: json, key: .pushNotification, require: false){
            list.append(perm)
        }
        
        return list
    }
    
    
    public func getSubmitKey() -> String{
        return "_allow_\(name.key)"
    }
}

