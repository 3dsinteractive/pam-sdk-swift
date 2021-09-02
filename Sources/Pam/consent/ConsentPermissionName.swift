//
//  ConsentPermissionKey.swift
//  
//
//  Created by narongrit kanhanoi on 1/9/2564 BE.

public enum ConsentPermissionName: String {
    case termsAndConditions = "terms_and_conditions"
    case privacyOverview = "privacy_overview"
    case necessaryCookies = "necessary_cookies"
    case preferencesCookies = "preferences_cookies"
    case analyticsCookies = "analytics_cookies"
    case marketingCookies = "marketing_cookies"
    case socialMediaCookies = "social_media_cookies"
    case email = "email"
    case sms = "sms"
    case line = "line"
    case facebookMessenger = "facebook_messenger"
    case pushNotification = "push_notification"
    
    public var nameStr:String{
        get {
            switch self {
            case .termsAndConditions:
                return "Terms and Conditions"
            case .privacyOverview:
                return "Privacy overview"
            case .necessaryCookies:
                return "Necessary cookies"
            case .preferencesCookies:
                return "Preferences cookies"
            case .analyticsCookies:
                return "Analytics cookies"
            case .marketingCookies:
                return "Marketing cookies"
            case .socialMediaCookies:
                return "Social media cookies"
            case .email:
                return "Email"
            case .sms:
                return "SMS"
            case .line:
                return "LINE"
            case .facebookMessenger:
                return "Facebook Messenger"
            case .pushNotification:
                return "Push notification"
            }
        }
    }
    
    public var key:String{
        get{
            return self.rawValue
        }
    }
    
}
