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
import AKMaskField
import IGProtoBuff

class IGRepresentativeViewController: UIViewController, SelectCountryObserver {
    
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewNumber: UIView!
    @IBOutlet weak var viewCode: UIView!
    @IBOutlet weak var txtCountry: IGLabel!
    @IBOutlet weak var txtNumber: AKMaskField!
    @IBOutlet weak var txtCode: IGLabel!
    
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
        navigationItem.addModalViewItems(leftItemText: "Skip", rightItemText: "Done", title: "Set Representer")
        navigationItem.rightViewContainer?.addAction {
            self.didTapOnDone()
        }
        navigationItem.leftViewContainer?.addAction {
            self.finish()
        }
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
            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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
                    let alertVC = UIAlertController(title: "Is this correct",message: "Is this phone correct:\n"+fullPhone,preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes", style: .cancel, handler: { (action) in
                        IGGlobal.prgShow(self.view)
                        self.setRepresentative(phone: fullPhone)
                    })
                    let no = UIAlertAction(title: "Edit", style: .default, handler: nil)
                    
                    alertVC.addAction(yes)
                    alertVC.addAction(no)
                    self.present(alertVC, animated: true, completion: nil)
                    return
                }
            }
            let alertVC = UIAlertController(title: "Invalid Phone", message: "Please enter a valid phone number", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
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
                let alert = UIAlertController(title: "Hint", message: "Unfortunately an error occurred \n please set representative later!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.finish()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
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
