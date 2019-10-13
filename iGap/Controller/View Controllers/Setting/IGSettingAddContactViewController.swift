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

class IGSettingAddContactViewController: BaseViewController, IGRegistrationStepSelectCountryTableViewControllerDelegate {

    @IBOutlet weak var edtFirstName: UITextField!
    @IBOutlet weak var edtLastName: UITextField!
    @IBOutlet weak var txtCountryCode: UILabel!
    @IBOutlet weak var edtPhoneNumber: AKMaskField!
    @IBOutlet weak var btnChooseCountry: UIButton!
    static var reloadAfterAddContact: Bool = false
    
    @IBAction func btnChooseCountry(_ sender: UIButton) {
        let chooseCountry = IGRegistrationStepSelectCountryTableViewController.instantiateFromAppStroryboard(appStoryboard: .Register)
        chooseCountry.popView = true
        chooseCountry.delegate = self
        self.navigationController!.pushViewController(chooseCountry, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edtPhoneNumber.setMask("{ddddddddddddddddddddddddd}", withMaskTemplate: "_________________________")

        makeView()
        btnChooseCountry.setTitle("CHOOSE_COUNTRY".localizedNew, for: .normal)
        btnChooseCountry.layer.borderColor = UIColor.darkGray.cgColor
        btnChooseCountry.layer.borderWidth = 1.0
        btnChooseCountry.layer.cornerRadius = 15.0
        btnChooseCountry.titleLabel?.font = UIFont.igFont(ofSize: 20)
        navInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edtFirstName.placeholder = "PLACE_HOLDER_F_NAME".localizedNew
        edtLastName.placeholder = "PLACE_HOLDER_L_NAME".localizedNew
        edtFirstName.font = UIFont.igFont(ofSize: 15.0)
        edtLastName.font = UIFont.igFont(ofSize: 15.0)
        let current : String = SMLangUtil.loadLanguage()
        
        switch current {
        case "fa" :

            edtLastName.textAlignment = .right
            edtFirstName.textAlignment = .right
        case "en" :
            edtLastName.textAlignment = .left
            edtFirstName.textAlignment = .left

        case "ar" :

            break
        default :
            break
        }
        
    }
    private func navInit() {
        self.initNavigationBar(title: "ADD_BTN".localizedNew, rightItemText: "", iGapFont: true) {
            self.addContact()
        }
    }
    
    private func makeView(){
        btnChooseCountry.layer.cornerRadius = 5
        btnChooseCountry.layer.borderWidth = 1
        btnChooseCountry.layer.borderColor = UIColor.iGapColor().cgColor
        
        txtCountryCode.layer.cornerRadius = 5
        txtCountryCode.layer.borderWidth = 1
        txtCountryCode.layer.borderColor = UIColor.iGapColor().cgColor
    }
    
    private func addContact(){
        
        if edtPhoneNumber != nil && !(edtPhoneNumber.text?.isEmpty)! && edtFirstName != nil && !(edtFirstName.text?.isEmpty)!  {
            // continue
        } else {
            return
        }
        
        var lastName: String = ""
        if edtLastName != nil && !(edtLastName.text?.isEmpty)! {
            lastName = edtLastName.text!
        }
        
        let contact = IGContact(phoneNumber: "\(txtCountryCode.text!)\(edtPhoneNumber.text!)", firstName: edtFirstName.text, lastName: lastName)
        IGUserContactsImportRequest.Generator.generate(contacts: [contact], force: true).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let contactImportResponse = protoResponse as? IGPUserContactsImportResponse {
                    IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                    self.getContactListFromServer()
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getContactListFromServer() {
        IGUserContactsGetListRequest.Generator.generate().success { (protoResponse) in
            switch protoResponse {
            case let contactGetListResponse as IGPUserContactsGetListResponse:
                DispatchQueue.main.async {
                    IGUserContactsGetListRequest.Handler.interpret(response: contactGetListResponse)
                    IGSettingAddContactViewController.reloadAfterAddContact = true
                    self.navigationController?.popViewController(animated: true)
                }
                break
            default:
                break
            }
            }.error { (errorCode, waitTime) in
                
            }.send()
    }
    
    
    fileprivate func setSelectedCountry(_ country:IGCountryInfo) {
        txtCountryCode.text = "+" + String(Int((country.countryCode))).inLocalizedLanguage()
        btnChooseCountry.setTitle(country.countryName , for: UIControl.State.normal)
        let codePattern = (country.codePattern)

        if codePattern != nil && codePattern != "" {
            let codePatternMask = (country.codePatternMask)
            let codePatternTemplate = country.codePatternTemplate
//            edtPhoneNumber.setMask("{ddddddddddddddddddddddddd}", withMaskTemplate: "_________________________")
            
//            edtPhoneNumber.setMask((codePatternMask), withMaskTemplate: codePatternTemplate)
        } else {
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            edtPhoneNumber.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    func didSelectCountry(country: IGCountryInfo) {
        setSelectedCountry(country)
    }
}
