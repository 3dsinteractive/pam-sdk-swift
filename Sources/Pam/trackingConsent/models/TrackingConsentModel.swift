// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let trackingConsentModel = try TrackingConsentModel(json)

import Foundation

// MARK: - TrackingConsentModel
struct TrackingConsentModel: Codable {
    let consentMessageID: String?
    let consentMessageType: String?
    let name: String?
    let trackingConsentModelDescription: String?
    let styleConfiguration: StyleConfiguration?
    var setting: Setting?
    let latestVersion: Int?
    let latestRevision: Int?

    enum CodingKeys: String, CodingKey {
        case consentMessageID = "consent_message_id"
        case consentMessageType = "consent_message_type"
        case name = "name"
        case trackingConsentModelDescription = "description"
        case styleConfiguration = "style_configuration"
        case setting = "setting"
        case latestVersion = "latest_version"
        case latestRevision = "latest_revision"
    }
}

// MARK: - Setting
struct Setting: Codable {
    let version: Int?
    let revision: Int?
    let displayText: AcceptButtonText?
    let acceptButtonText: AcceptButtonText?
    let consentDetailTitle: AcceptButtonText?
    let availableLanguages: [String]?
    let defaultLanguage: String?
    var termsAndConditions: ConsentOption?
    var privacyOverview: ConsentOption?
    let moreInfo: MoreInfo?
    var necessaryCookies: ConsentOption?
    var preferencesCookies: ConsentOption?
    var analyticsCookies: ConsentOption?
    var marketingCookies: ConsentOption?
    var socialMediaCookies: ConsentOption?
    var email: ConsentOption?
    var sms: ConsentOption?
    var line: ConsentOption?
    var facebookMessenger: ConsentOption?
    var pushNotification: ConsentOption?

    enum CodingKeys: String, CodingKey {
        case version = "version"
        case revision = "revision"
        case displayText = "display_text"
        case acceptButtonText = "accept_button_text"
        case consentDetailTitle = "consent_detail_title"
        case availableLanguages = "available_languages"
        case defaultLanguage = "default_language"
        case termsAndConditions = "terms_and_conditions"
        case privacyOverview = "privacy_overview"
        case moreInfo = "more_info"
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
    }
}

// MARK: - AcceptButtonText
struct AcceptButtonText: Codable {
    let en: String?
    let th: String?

    enum CodingKeys: String, CodingKey {
        case en = "en"
        case th = "th"
    }
}

struct ConsentOption: Codable{
    let brief_description: BriefDescription?
    let full_description: FullDescription?
    let is_enabled: Bool?
    let is_full_description_enabled: Bool?
    let tracking_collection: TrackingCollection?
    
    var is_expanded: Bool? = false
    var is_allow: Bool? = true
    var require:Bool? = false
    var title: String? = ""
}

struct BriefDescription: Codable{
    let en: String?
    let th: String?
}

struct FullDescription: Codable{
    let en: String?
    let th: String?
}

struct TrackingCollection: Codable{
    let google_tag_id: [String]?
    let marketing_script: [String]?
    let facebook_pixel_id: [String]?
}


// MARK: - Description
struct Description: Codable {
    
}




// MARK: - MoreInfo
struct MoreInfo: Codable {
    let isCustomURLEnabled: Bool?
    let customURL: AcceptButtonText?
    let displayText: AcceptButtonText?

    enum CodingKeys: String, CodingKey {
        case isCustomURLEnabled = "is_custom_url_enabled"
        case customURL = "custom_url"
        case displayText = "display_text"
    }
}

// MARK: - StyleConfiguration
struct StyleConfiguration: Codable {
    let barBackgroundColor: String?
    let barTextColor: String?
    let barBackgroundOpacityPercentage: Int?
    let buttonBackgroundColor: String?
    let buttonTextColor: String?
    let consentDetail: ConsentDetail?

    enum CodingKeys: String, CodingKey {
        case barBackgroundColor = "bar_background_color"
        case barTextColor = "bar_text_color"
        case barBackgroundOpacityPercentage = "bar_background_opacity_percentage"
        case buttonBackgroundColor = "button_background_color"
        case buttonTextColor = "button_text_color"
        case consentDetail = "consent_detail"
    }
}

// MARK: - ConsentDetail
struct ConsentDetail: Codable {
    let popupMainIcon: String?
    let primaryColor: String?
    let secondaryColor: String?
    let buttonTextColor: String?
    let textColor: String?

    enum CodingKeys: String, CodingKey {
        case popupMainIcon = "popup_main_icon"
        case primaryColor = "primary_color"
        case secondaryColor = "secondary_color"
        case buttonTextColor = "button_text_color"
        case textColor = "text_color"
    }
}
