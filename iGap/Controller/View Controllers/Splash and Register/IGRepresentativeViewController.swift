/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import IGProtoBuff

class IGRepresentativeViewController: BaseViewController, SelectCountryObserver {
    
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewNumber: UIView!
    @IBOutlet weak var viewCode: UIView!
    @IBOutlet weak var txtCountry: IGLabel!
    @IBOutlet weak var txtNumber: AKMaskField!
    @IBOutlet weak var txtCode: IGLabel!
    @IBOutlet weak var lblHeader: IGLabel!

    var popView = false
    var selectedCountry: IGCountryInfo!
    static var selectCountryObserver: SelectCountryObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGRepresentativeViewController.selectCountryObserver = self
        initNavigationBar()
        customizeView(view: viewCountry)
        customizeView(view: viewNumber)
        customizeView(view: viewCode)
        
        let tapOnCountry = UITapGestureRecognizer(target: self, action: #selector(showCountriesList))
        viewCountry.addGestureRecognizer(tapOnCountry)
        
        selectedCountry = IGCountryInfo.iranCountry()
        setCountryInfo(country: selectedCountry)
    }
    
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: "SKIP".localizedNew, rightItemText: "DONE_BTN".localizedNew, title: "SET_REFERRAL".localizedNew)
        navigationItem.rightViewContainer?.addAction {
            self.didTapOnDone()
        }
        navigationItem.leftViewContainer?.addAction {
            self.finish()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblHeader.text = "ENTER_REFERRAL_NUMBER".localizedNew
    }
    private func customizeView(view: UIView){
        view.layer.cornerRadius = 6.0;
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.organizationalColor().cgColor
    }
    
    @objc func showCountriesList() {
        performSegue(withIdentifier: "showCountrySelection", sender: self)
    }
    
    private func didTapOnDone() {
        if !IGAppManager.sharedManager.isUserLoggiedIn() {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "NO_NETWORK".RecentTableViewlocalizedNew, cancelText: "GLOBAL_CLOSE".localizedNew )
        } else {
            
            var phoneSpaceLess: String?
            let phone = txtNumber.text
            if phone != nil && phone != "" {
                phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
                phoneSpaceLess = phoneSpaceLess?.replacingOccurrences(of: "_", with: "")
            }
            
            if phoneSpaceLess != nil && phoneSpaceLess != "" && Int64(phoneSpaceLess!) != nil{
                if IGGlobal.matches(for: (selectedCountry?.codeRegex)!, in: phoneSpaceLess!) {
                    let countryCode = String(Int((self.selectedCountry?.countryCode)!))
                    let fullPhone = countryCode + " " + (phone?.replacingOccurrences(of: "_", with: ""))!
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: "IS_IT_CORRECT".localizedNew, showIconView: true, showDoneButton: true, showCancelButton: true, message: "IS_PHONE_OK".localizedNew + fullPhone, doneText: "GLOBAL_YES".localizedNew  ,cancelText: "BTN_EDITE".localizedNew,done: {
                        IGGlobal.prgShow(self.view)
                        self.setRepresentative(phone: fullPhone)

                    })

                    return
                }
            }
            
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "INVALID_PHONE".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "ENTER_VALID_P_NUMBER".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew )

        }
    }
    
    private func setCountryInfo(country: IGCountryInfo){
        txtCountry.text = country.countryName
        txtCode.text = "+"+String(Int((country.countryCode)))
        
        if country.codePattern != nil && country.codePattern != "" {
            txtNumber.setMask((country.codePatternMask), withMaskTemplate: country.codePatternTemplate)
        } else {
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            txtNumber.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    private func setRepresentative(phone: String){
        IGUserProfileSetRepresentativeRequest.Generator.generate(phone: phone).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let response = protoResponse as? IGPUserProfileSetRepresentativeResponse {
                IGUserProfileSetRepresentativeRequest.Handler.interpret(response: response)
            }
            self.finish()
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            DispatchQueue.main.async {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "UNSSUCCESS_OTP".RecentTableViewlocalizedNew, cancelText: "GLOBAL_CLOSE".localizedNew )

            }
        }).send()
    }
    
    private func finish(){
        if popView {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: {
                self.view.endEditing(true)
                IGAppManager.sharedManager.setUserLoginSuccessful()
            })
        }
    }
    
    /************************ Callback ************************/
    
    func onSelectCountry(country: IGCountryInfo) {
        selectedCountry = country
        setCountryInfo(country: country)
    }
}
