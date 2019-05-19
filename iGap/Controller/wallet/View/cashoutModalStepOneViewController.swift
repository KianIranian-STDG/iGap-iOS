//
//  cashoutModalStepOneViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/10/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import maincore

class cashoutModalStepOneViewController: BaseViewController {
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!

    @IBOutlet weak var confirmStackView: UIStackView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var leftLBLone: UILabel!
    @IBOutlet weak var leftLBLtwo: UILabel!
    @IBOutlet weak var leftLBLthree: UILabel!
    @IBOutlet weak var leftLBLfour: UILabel!
    @IBOutlet weak var leftLBLfive: UILabel!
    @IBOutlet weak var leftLBLSix: UILabel!
    @IBOutlet weak var rightLBLone: UILabel!
    @IBOutlet weak var rightLBLtwo: UILabel!
    @IBOutlet weak var rightLBLthree: UILabel!
    @IBOutlet weak var rightLBLfour: UILabel!
    @IBOutlet weak var rightLBLfive: UILabel!
    @IBOutlet weak var rightLBLsix: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraits: NSLayoutConstraint!
    @IBOutlet weak var confirmRequestView: UIView!
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var lblWalletPinTitle: UILabel!
    
    @IBOutlet weak var tfPin : UITextField!
    var isStepOne = true
    var keyBoardIsOpen = false
    var keyboardHeight : CGFloat?
    var sourceCard: SMCard!

    var dialogT : String?
    var message : Any?
    var leftButtonTitle:String?
    var rightButtonTitle:String?
    var leftButtonAction: SimpleCallBack?
    var rightButtonAction: CallBack?
    var leftButtonEnable : Bool?
    var amount : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        initView()
        handleUIChange()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initCHangeLang()
    }
    func initCHangeLang() {
        lblWalletPinTitle.text = "ENTER_WALLET_PIN".localizedNew
        dialogTitle.text = "WALLET_PIN".localizedNew
    }
    
    func initView() {
        self.view.isUserInteractionEnabled = true
        self.leftButton.isUserInteractionEnabled = true
        self.leftButton.isEnabled = true
        passView.isHidden = true
        passView.isUserInteractionEnabled = false
        
        confirmRequestView.isHidden = false
        confirmRequestView.isUserInteractionEnabled = true
        
        prepareConfirm(resp: message, amount: amount)
        self.dialogTitle.text = dialogT
        btnOk.setTitle("GLOBAL_OK".localizedNew, for: .normal)
        btnCancel.setTitle("CANCEL_BTN".localizedNew, for: .normal)
    }
    func AnimateMainViewHeight() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewHeight.constant = 250 // heightCon is the IBOutlet to the constraint
            self.GoToWalletPinUI()
            self.view.layoutIfNeeded()
        })
    }
    func prepareConfirm(resp : Any?,amount: String!) {
        
        _ = NSMutableDictionary()
        let personalItems = ((resp as! NSDictionary)["owner"]as! NSDictionary)
        let cardItems = ((resp as! NSDictionary)["destination_card_info"]as! NSDictionary)
        
        leftLBLone.text  = "AMOUNT_IN".localizedNew
        rightLBLone.text = amount + " " + "CURRENCY".localizedNew

        leftLBLtwo.text  = "AMOUNT_OUT".localizedNew
        rightLBLtwo.text = amount + " " + "CURRENCY".localizedNew
        
        leftLBLthree.text  = "WAGE".localizedNew
        rightLBLthree.text = "\((resp as! NSDictionary)["transfer_fee"]!)".inRialFormat().inLocalizedLanguage()
        
        leftLBLfour.text  = "DEST_CARD".localizedNew
        rightLBLfour.text = "\(cardItems["card_number"]!)".addSepratorCardNum()

        leftLBLfive.text  = "DEST_BANK".localizedNew
        rightLBLfive.text = "\(personalItems["bank_name"]!)"

        leftLBLSix.text  = "OWNER_NAME".localizedNew
        rightLBLsix.text = "\(personalItems["first_name"]!)" + " " + "\(personalItems["last_name"]!)"
        
    }

    @IBAction func btnOkTapped(_ sender: Any) {
        
        if isStepOne {
            isStepOne = false

        confirmRequestView.isUserInteractionEnabled = false
        confirmRequestView.isHidden = true
        
        passView.isUserInteractionEnabled = true
        passView.isHidden = false
        
        
        AnimateMainViewHeight()
        }
        else {
            SMLoading.showLoadingPage(viewcontroller: self)

            SMCard.chashout(amount: Int(rightLBLone.text!) , cardNumber: (rightLBLfour.text)?.onlyDigitChars(), cardToken: SMUserManager.token ?? "", sourceCardToken:SMUserManager.payGearToken,  pin: (tfPin.text?.onlyDigitChars()) ,isFast : true, accountId: SMUserManager.accountId ,onSuccess: {resp in
                SMLoading.shared.showNormalDialog(viewController: self, height: 180,isleftButtonEnabled: false, title: "CASHOUT_REQUEST".localizedNew, message: "SUCCESS_OPERATION".localizedNew, yesPressed: { pin in
                    self.view.endEditing(true)
                    self.navigationController?.popViewController(animated: true)
                    
                })
                SMLog.SMPrint(resp)
            }, onFailed: {err in
                SMLog.SMPrint(err)
            })
        }
    }
    func handleUIChange() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    /// Change position of popup by keyboard size
    func refreshPopupPosition(){
        
        if keyBoardIsOpen {
        verticalConstraits.constant -= (keyboardHeight! / 2)
        self.view.layoutIfNeeded()
        }
    }
    
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        keyBoardIsOpen = true
        keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        refreshPopupPosition()
        self.view.layoutIfNeeded()
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        keyBoardIsOpen = false

        verticalConstraits.constant = 0
        self.view.layoutIfNeeded()

    }
    @IBAction func btnCancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func GoToWalletPinUI() {
        dialogTitle.text = "WALLET_PIN".localizedNew
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
