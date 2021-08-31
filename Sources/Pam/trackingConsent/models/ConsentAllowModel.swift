//
//  ConsentAllowModel.swift
//  
//
//  Created by narongrit kanhanoi on 25/6/2564 BE.
//

import Foundation

struct ConsentAllowModel : Codable {
    let consentId: String?
    let consentMessageId: String?
    let version: Int?
    let lastConsentVersion: Int?
    let latestVersion: Int?
    let lastConsentAt: String?
    let needConsentReview: Bool?
    let code: String?
    let message: String
    let trackingPermission: TrackingPermission?
    let contactingPermission: ContactPermissions?
    let consentType: String?
    let contactId: String?
    let showConsentBar: Bool?
    
    enum CodingKeys: String, CodingKey {
        case consentId = "consent_id"
        case consentMessageId = "consent_message_id"
        case version = "version"
        case lastConsentVersion = "last_consent_version"
        case latestVersion = "latest_version"
        case lastConsentAt = "last_consent_at"
        case needConsentReview = "need_consent_review"
        case code = "code"
        case message = "message"
        case trackingPermission = "tracking_permission"
        case contactingPermission = "contacting_permission"
        case consentType = "consent_type"
        case contactId = "contact_id"
        case showConsentBar = "show_consent_bar"
    }
    
}


struct ContactPermissions: Codable{
    let allow_something: Bool?
}

struct TrackingPermission: Codable{
    let analyticsCookies: Bool?
    let marketingCookies: Bool?
    let necessaryCookies: Bool?
    let preferencesCookies: Bool?
    let privacyOverview: Bool?
    let socialMediaCookies: Bool?
    let termsAndConditions: Bool?

    enum CodingKeys: String, CodingKey {
        case analyticsCookies = "analytics_cookies"
        case marketingCookies = "marketing_cookies"
        case necessaryCookies = "necessary_cookies"
        case preferencesCookies = "preferences_cookies"
        case privacyOverview = "privacy_overview"
        case socialMediaCookies = "social_media_cookies"
        case termsAndConditions = "terms_and_conditions"
    }
}
