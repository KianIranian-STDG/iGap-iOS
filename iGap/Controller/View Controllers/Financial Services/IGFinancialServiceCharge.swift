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
import PecPayment

protocol AlertClouser {
    func onActionClick(title: String)
}

class IGFinancialServiceCharge: BaseViewController, UITextFieldDelegate, MerchantResultObserver, TopupMerchantResultObserver {

    @IBOutlet weak var edtPhoneNubmer: UITextField!
    @IBOutlet weak var txtOperatorTransport: UILabel!
    @IBOutlet weak var btnOperator: UIButton!
    @IBOutlet weak var btnChargeType: UIButton!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var switchButton: UISwitch!

    let PHONE_LENGTH = 11
    var latestPhoneNumber = ""
    
    let operatorIrancell = IGStringsManager.Irancell.rawValue.localized
    let operatorMCI = IGStringsManager.MCI.rawValue.localized
    let operatorRightel = IGStringsManager.Rightel.rawValue.localized
    let operatorNotDetect = ""
    
    let normalCharge = IGStringsManager.NormalCharge.rawValue.localized
    let amazingCharge = IGStringsManager.AmazingCharge.rawValue.localized
    let wimaxCharge = IGStringsManager.WimaxCharge.rawValue.localized
    let permanently = IGStringsManager.PerminantalySimcard.rawValue.localized
    
    let P1000: Int64 = 10000
    let P2000: Int64 = 20000
    let P5000: Int64 = 50000
    let P10000: Int64 = 100000
    let P20000: Int64 = 200000
    let rials = IGStringsManager.Currency.rawValue.localized
    
    var operatorDictionary: [String:IGOperator] =
        ["0910":IGOperator.mci,
         "0911":IGOperator.mci,
         "0912":IGOperator.mci,
         "0913":IGOperator.mci,
         "0914":IGOperator.mci,
         "0915":IGOperator.mci,
         "0916":IGOperator.mci,
         "0917":IGOperator.mci,
         "0918":IGOperator.mci,
         "0919":IGOperator.mci,
         "0990":IGOperator.mci,
         "0991":IGOperator.mci,
         
         "0901":IGOperator.irancell,
         "0902":IGOperator.irancell,
         "0903":IGOperator.irancell,
         "0930":IGOperator.irancell,
         "0933":IGOperator.irancell,
         "0935":IGOperator.irancell,
         "0936":IGOperator.irancell,
         "0937":IGOperator.irancell,
         "0938":IGOperator.irancell,
         "0939":IGOperator.irancell,
         
         "0920":IGOperator.rightel,
         "0921":IGOperator.rightel,
         "0922":IGOperator.rightel
    ]
    
    var operatorType: IGOperator!
    var operatorTypeBackup: IGOperator!
    var operatorChargeType: IGPMplGetTopupToken.IGPType!
    var chargeAmount: Int64!
    var operatorTransport: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edtPhoneNubmer.delegate = self
        
        initNavigationBar(title: IGStringsManager.ChargeSimCard.rawValue.localized) {}
        manageButtonsView(buttons: [btnOperator,btnChargeType,btnPrice,btnBuy])
        ButtonViewActivate(button: btnOperator, isEnable: false)
        self.initTheme()
    }
    private func initTheme() {
        txtOperatorTransport.textColor = ThemeManager.currentTheme.LabelColor
        edtPhoneNubmer.backgroundColor = .white
        btnOperator.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnBuy.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnPrice.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnChargeType.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)


        btnChargeType.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        btnBuy.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        btnPrice.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        btnOperator.backgroundColor = UIColor.gray
        self.view.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.edtPhoneNubmer.layer.borderColor = UIColor.gray.cgColor
        switchButton.onTintColor = ThemeManager.currentTheme.SliderTintColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initCHangeLang()
    }
    func initCHangeLang() {
        txtOperatorTransport.text = IGStringsManager.PortedSubsDisable.rawValue.localized

        edtPhoneNubmer.placeholder = IGStringsManager.MobileNumber.rawValue.localized
        self.btnPrice.setTitle(IGStringsManager.ChargePrice.rawValue.localized, for: UIControl.State.normal)
        self.btnBuy.setTitle(IGStringsManager.Buy.rawValue.localized, for: UIControl.State.normal)
        self.btnOperator.setTitle(IGStringsManager.ChooseOperator.rawValue.localized, for: UIControl.State.normal)
        self.btnChargeType.setTitle(IGStringsManager.ChooseChargeType.rawValue.localized, for: UIControl.State.normal)

    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for btn in buttons {
            //btn.removeUnderline()
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 0.2
            btn.layer.borderColor = ThemeManager.currentTheme.LabelGrayColor.cgColor
        }
    }
    
    private func ButtonViewActivate(button: UIButton, isEnable: Bool){
        
        if isEnable {
            button.layer.borderColor = ThemeManager.currentTheme.LabelGrayColor.cgColor
            button.layer.backgroundColor = ThemeManager.currentTheme.BackGroundColor.cgColor
        } else {
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.backgroundColor = UIColor.gray.cgColor
        }
    }
    
    private func setOperator() {
        
        if operatorType == nil {
            btnOperator.setTitle(operatorNotDetect, for: UIControl.State.normal)
            return
        }
        
        switch operatorType {
        case .irancell?:
            btnOperator.setTitle(operatorIrancell, for: UIControl.State.normal)
            break
            
        case .mci?:
            btnOperator.setTitle(operatorMCI, for: UIControl.State.normal)
            break
            
        case .rightel?:
            btnOperator.setTitle(operatorRightel, for: UIControl.State.normal)
            break
            
        default:
            break
        }
        
        operatorChargeType = nil
        self.btnChargeType.setTitle(IGStringsManager.ChooseChargeType.rawValue.localized, for: UIControl.State.normal)
    }
    
    private func showAlertView(title: String, message: String?, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){
        let option = UIAlertController(title: title, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        
        for subtitle in subtitles {
            let action = UIAlertAction(title: subtitle, style: .default, handler: { (action) in
                alertClouser(action.title!)
            })
            option.addAction(action)
        }
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        option.addAction(cancel)
        
        self.present(option, animated: true, completion: {})
    }
    
    private func showErrorAlertView(title: String, message: String?, dismiss: Bool = false){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .cancel, handler: { (action) in
            if dismiss {
                self.navigationController?.popViewController(animated: true)
            }
        })
        option.addAction(ok)
        self.present(option, animated: true, completion: {})
    }

    private func registerTopup(token: String){
        let initpayment = InitPayment()
        initpayment.registerTopup(merchant: self)
        initpayment.initTopupPayment(Token: token, MerchantVCArg: self, TSPEnabled: 0)
    }
    
    /*********************************************************/
    /********************* User Actions **********************/
    /*********************************************************/
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            operatorTransport = true
            txtOperatorTransport.text = IGStringsManager.PortedSubsEnable.rawValue.localized
            txtOperatorTransport.textColor = ThemeManager.currentTheme.SliderTintColor
        } else {
            operatorTransport = false
            txtOperatorTransport.text = IGStringsManager.PortedSubsDisable.rawValue.localized
            txtOperatorTransport.textColor = ThemeManager.currentTheme.LabelColor
            
            if operatorTypeBackup != nil {
                operatorType = operatorTypeBackup
                setOperator()
            }
        }
        btnOperator.isEnabled = sender.isOn
        ButtonViewActivate(button: btnOperator, isEnable: sender.isOn)
    }
    
    @IBAction func btnChooseOperator(_ sender: UIButton) {
        showAlertView(title: IGStringsManager.ChooseOperator.rawValue.localized, message: nil, subtitles: [operatorIrancell,operatorMCI,operatorRightel], alertClouser: { (title) -> Void in
            
            switch title {
            case self.operatorIrancell:
                self.operatorType = IGOperator.irancell
                self.setOperator()
                break
            case self.operatorMCI:
                self.operatorType = IGOperator.mci
                self.setOperator()
                break
            case self.operatorRightel:
                self.operatorType = IGOperator.rightel
                self.setOperator()
                break
            default:
                break
            }
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnChooseChargeType(_ sender: UIButton) {
        
        var chargeType: [String] = [normalCharge]
        if operatorType == IGOperator.irancell {
            chargeType = [normalCharge,amazingCharge,wimaxCharge,permanently]
        }
        
        showAlertView(title: IGStringsManager.ChargeType.rawValue.localized, message: nil, subtitles: chargeType, alertClouser: { (title) -> Void in
            
            switch title {
            case self.normalCharge:
                if self.operatorType == IGOperator.irancell {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellPrepaid
                } else if self.operatorType == IGOperator.mci {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.mci
                } else if self.operatorType == IGOperator.rightel {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.rightel
                }
                self.btnChargeType.setTitle(self.normalCharge, for: UIControl.State.normal)
                break
                
            case self.amazingCharge:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellWow
                self.btnChargeType.setTitle(self.amazingCharge, for: UIControl.State.normal)
                break
                
            case self.wimaxCharge:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellWimax
                self.btnChargeType.setTitle(self.wimaxCharge, for: UIControl.State.normal)
                break
                
            case self.permanently:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellPostpaid
                self.btnChargeType.setTitle(self.permanently, for: UIControl.State.normal)
                break
                
            default:
                break
            }
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnChoosePrice(_ sender: UIButton) {
        
        let chargePrice = ["\(P1000) \(rials)" , "\(P2000) \(rials)" , "\(P5000) \(rials)", "\(P10000) \(rials)", "\(P20000) \(rials)"]
        
        showAlertView(title: IGStringsManager.ChargePrice.rawValue.localized, message: nil, subtitles: chargePrice, alertClouser: { (title) -> Void in
            switch title {
            case "\(self.P1000) \(self.rials)":
                self.chargeAmount = self.P1000
                break
            case "\(self.P2000) \(self.rials)":
                self.chargeAmount = self.P2000
                break
            case "\(self.P5000) \(self.rials)":
                self.chargeAmount = self.P5000
                break
            case "\(self.P10000) \(self.rials)":
                self.chargeAmount = self.P10000
                break
            case "\(self.P20000) \(self.rials)":
                self.chargeAmount = self.P20000
                break
            default:
                break
            }
            self.btnPrice.setTitle(title, for: UIControl.State.normal)
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnBuy(_ sender: UIButton) {
        
        guard let phoneNumber: String = edtPhoneNubmer.text?.inEnglishNumbersNew() else {
            return
        }
        
        if (phoneNumber.count) < 11 || !phoneNumber.isNumber ||  (operatorDictionary[(phoneNumber.substring(offset: 4))] == nil) {
            showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.WrongPhoneNUmber.rawValue.localized)
            return
        }
        
        if operatorChargeType == nil || chargeAmount == nil {
            showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalCheckFields.rawValue.localized)
            return
        }
        
        IGGlobal.prgShow(self.view)
        
        if self.operatorType == IGOperator.mci {
            
            IGApiTopup.shared.purchase(telNum: phoneNumber, cost: chargeAmount) { (success, token) in
                
                if success {
                    guard let token = token else { return }
                    IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                        IGGlobal.prgHide()
                        let paymentView = IGPaymentView.sharedInstance
                        if success {
                            guard let paymentData = payment else {
                                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                                return
                            }
                            paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.MCI.rawValue.localized, payToken: token, payment: paymentData)
                        } else {
                            
                            paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.MCI.rawValue.localized, message: errorMessage ?? "", payToken: token)
                        }
                    })
                    
                } else {
                    IGGlobal.prgHide()
                }
            }
            
        } else {
            IGMplGetTopupToken.Generator.generate(number: Int64(phoneNumber)!, amount: chargeAmount, type: operatorChargeType).success({ (protoResponse) in
                IGGlobal.prgHide()
                if let getTokenResponse = protoResponse as? IGPMplGetTopupTokenResponse {
                    if getTokenResponse.igpStatus == 0 { //success
                        self.registerTopup(token: getTokenResponse.igpToken)
                    } else {
                        self.showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: getTokenResponse.igpMessage)
                    }
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                
            }).send()
        }
        
    }
    
    
    /*********************************************************/
    /*************** Overrided Payment Mehtods ***************/
    /*********************************************************/
    
    func TopupMerchantUpdate(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func TopupMerchantError(errorType: Int) {
        showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized, dismiss: true)
    }
    
    
    
    func update(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func error(errorType: Int, orderID: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*********************************************************/
    /******************* Overrided Method ********************/
    /*********************************************************/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = edtPhoneNubmer.text {
            let newLength = text.count + string.count - range.length
            if (newLength == PHONE_LENGTH) {
                operatorTypeBackup = operatorDictionary[text.substring(offset: 4)]
                if !operatorTransport {
                    operatorType = operatorTypeBackup
                }
                setOperator()
                latestPhoneNumber = text
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5){
                    self.view.endEditing(true)
                }
            } else if (newLength > PHONE_LENGTH) {
                edtPhoneNubmer.text = latestPhoneNumber
            } else {
                latestPhoneNumber = text
            }
        }
        return true
    }
}
