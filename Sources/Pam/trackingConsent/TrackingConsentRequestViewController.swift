//
//  TrackingConsentRequestViewController.swift
//  
//
//  Created by narongrit kanhanoi on 23/6/2564 BE.
//

import UIKit


class TrackingConsentRequestViewController: UIViewController {
    
    static func create(consentMessage: TrackingConsentModel) -> TrackingConsentRequestViewController{
        let vc = TrackingConsentRequestViewController.loadFromNib()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.consentMessage = consentMessage
        return vc
    }
    
    @IBOutlet var titleText:UILabel!
    @IBOutlet var langToggle: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var consentMessage: TrackingConsentModel?
    var consentAllowModel: ConsentAllowModel?
    
    var consentOptions:[ConsentOption] = []
    
    @IBAction func langTapped(){
        
    }
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "table_cells", bundle: .module)
        tableView.register(nib, forCellReuseIdentifier: "consent_header")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        titleText.text = consentMessage?.name
        createConsentOptionArray()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func createConsentOptionArray(){
        consentOptions = []
        
        if(consentMessage?.setting?.termsAndConditions?.is_enabled == true) {
            if consentAllowModel == nil {
                consentMessage?.setting?.termsAndConditions?.is_allow = true
            }
            consentMessage?.setting?.termsAndConditions?.title = "Term & Conditions"
            consentMessage?.setting?.termsAndConditions?.require = true
            if let it = consentMessage?.setting?.termsAndConditions {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.privacyOverview?.is_enabled == true{
            if consentAllowModel == nil {
                consentMessage?.setting?.privacyOverview?.is_allow = true
            }
            consentMessage?.setting?.privacyOverview?.title = "Privacy OverView"
            consentMessage?.setting?.privacyOverview?.require = true
            if let it = consentMessage?.setting?.privacyOverview {
                consentOptions.append(it)
            }
        }
        
        
        if consentMessage?.setting?.necessaryCookies?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.necessaryCookies?.is_allow = true
            }
            consentMessage?.setting?.necessaryCookies?.title = "Necessary Cookies"
            consentMessage?.setting?.necessaryCookies?.require = true
            if let it = consentMessage?.setting?.necessaryCookies {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.preferencesCookies?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.preferencesCookies?.is_allow = true
            }
            consentMessage?.setting?.preferencesCookies?.title = "Preferences Cookies"
            consentMessage?.setting?.preferencesCookies?.require = false
            if let it = consentMessage?.setting?.preferencesCookies {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.analyticsCookies?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.analyticsCookies?.is_allow = true
            }
            consentMessage?.setting?.analyticsCookies?.title = "Analytics Cookies"
            consentMessage?.setting?.analyticsCookies?.require = false
            if let it = consentMessage?.setting?.analyticsCookies {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.marketingCookies?.is_enabled == true {
            if consentAllowModel == nil{
                consentMessage?.setting?.marketingCookies?.is_allow = true
            }
            consentMessage?.setting?.marketingCookies?.title = "Marketing Cookies"
            consentMessage?.setting?.marketingCookies?.require = false
            if let it = consentMessage?.setting?.marketingCookies{
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.socialMediaCookies?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.socialMediaCookies?.is_allow = true
            }
            consentMessage?.setting?.socialMediaCookies?.title = "Social Media Cookies"
            consentMessage?.setting?.socialMediaCookies?.require = false
            if let it = consentMessage?.setting?.socialMediaCookies {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.sms?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.sms?.is_allow = true
            }
            consentMessage?.setting?.sms?.require = false
            if let it =  consentMessage?.setting?.sms {
                consentOptions.append(it)
            }
        }
        
        if consentMessage?.setting?.line?.is_enabled == true {
            if consentAllowModel == nil {
                consentMessage?.setting?.line?.is_allow = true
            }
            consentMessage?.setting?.line?.require = false
            if let it = consentMessage?.setting?.line {
                consentOptions.append(it)
            }
        }
        
        if(consentMessage?.setting?.facebookMessenger?.is_enabled == true) {
            if consentAllowModel == nil {
                consentMessage?.setting?.facebookMessenger?.is_allow = true
            }
            consentMessage?.setting?.facebookMessenger?.require = false
            if let it = consentMessage?.setting?.facebookMessenger {
                consentOptions.append(it)
            }
        }
        
    }
}


extension TrackingConsentRequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consentOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "consent_header", for: indexPath) as! ConsentHeader
        cell.setData(option: consentOptions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
