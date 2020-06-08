//
//  IGCheckGiftStickerModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGGIftPayInfoModal: BaseTableViewController {

    var issecuredPass : Bool = false

    var mode : String = "GIFT_PAY_INFO"

    var giftCardInfo : IGStructGiftCardInfo! {
        didSet {
            lblCardData.text = giftCardInfo.cardNumber
            lblCVVData.text = giftCardInfo.cvv2
            lblEXPData.text = giftCardInfo.expireDate
            lblPinData.text = giftCardInfo.secondPassword
        }
    }

    var isShortFormEnabled = true
    var isKeyboardPresented = false

    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblCardTitle : UILabel!
    @IBOutlet weak var lblCardData : UILabel!
    @IBOutlet weak var lblCVV : UILabel!
    @IBOutlet weak var lblCVVData : UILabel!

    @IBOutlet weak var lblEXP : UILabel!
    @IBOutlet weak var lblEXPData : UILabel!

    @IBOutlet weak var lblPin : UILabel!
    @IBOutlet weak var lblPinData : UILabel!

    @IBOutlet weak var btnInquery : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "GIFT_PAY_INFO" :
            initView()
            break
        default :
            initView()
            break
        }
        initTheme()
        btnInquery.addTarget(self, action: #selector(didTapOnCopy), for: .touchUpInside)

    }

    @objc func didTapOnCopy() {
        if mode == "GIFT_PAY_INFO" {

            dismiss(animated: true, completion: {
                var phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0)
                if phone == nil {return}
                phone = ("+"+phone!).replace("+98", withString: "0")
                
                IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
                IGApiSticker.shared.checkBuyGiftCard(stickerId: (UIApplication.topViewController() as! IGStickerViewController).giftStickerId ?? "", nationalCode: IGSessionInfo.getNationalCode() ?? "", mobileNumber: phone!, count: 1, completion: { [weak self] buyGiftSticker in
                    (UIApplication.topViewController() as! IGStickerViewController).giftStickerId = nil
                    
                    IGStickerViewController.waitingGiftCardInfo.giftId = buyGiftSticker.id
                    IGApiSticker.shared.giftStickerPaymentRequest(token: buyGiftSticker.token, completion: { giftCardPayment in
                        IGStickerViewController.waitingGiftCardInfo.orderId = giftCardPayment.info.orderID
                        IGLoading.hideLoadingPage()

                        IGPaymentView.sharedInstance.showGiftCardPayment(on: UIApplication.shared.keyWindow!, title: IGStringsManager.GiftStickerBuy.rawValue.localized, payment: giftCardPayment)
                    }, error: {
                        IGLoading.hideLoadingPage()
                        
                        IGPaymentView.sharedInstance.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.GiftCard.rawValue.localized, message: IGStringsManager.PaymentErrorMessage.rawValue.localized)
                    })
                    }, error: {
                        print("ERROR HAPPEND")
                        IGLoading.hideLoadingPage()
                })
            })
        } else {
            dismiss(animated: true, completion: {
                IGHelperBottomModals.shared.showNationalIDModal(view: UIApplication.topViewController(), mode : "NATIONAL_ID_SEND")

            })
        }
        
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblCVV.textColor = ThemeManager.currentTheme.LabelColor
        lblEXP.textColor = ThemeManager.currentTheme.LabelColor
        lblPin.textColor = ThemeManager.currentTheme.LabelColor
        lblCVVData.textColor = ThemeManager.currentTheme.LabelColor
        lblPinData.textColor = ThemeManager.currentTheme.LabelColor
        lblEXPData.textColor = ThemeManager.currentTheme.LabelColor

        lblCardData.textColor = ThemeManager.currentTheme.LabelColor
        lblCardTitle.textColor = ThemeManager.currentTheme.LabelColor

        btnInquery.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnInquery.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    @objc func keyboardWillShow(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID APPEAR")
        
        isKeyboardPresented = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID DISAPPEAR")
        isKeyboardPresented = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
  
    
    

    
    
    private func initView() {
        lblHeader.text = IGStringsManager.GiftStickerBuy.rawValue.localized
        lblCardTitle.text = IGStringsManager.CardNumber.rawValue.localized
        lblCVV.text = IGStringsManager.CVV2.rawValue.localized
        lblEXP.text = IGStringsManager.ExpireDate.rawValue.localized
        lblPin.text = IGStringsManager.Pin.rawValue.localized

        if mode == "GIFT_PAY_INFO" {
            btnInquery.setTitle(IGStringsManager.Copy.rawValue.localized, for: .normal)

        }
        btnInquery.layer.cornerRadius = 10
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblCardTitle.font = UIFont.igFont(ofSize: 15)
        lblCardData.font = UIFont.igFont(ofSize: 15)
        lblCVVData.font = UIFont.igFont(ofSize: 15)
        lblCVV.font = UIFont.igFont(ofSize: 15)
        lblPinData.font = UIFont.igFont(ofSize: 15)
        lblPin.font = UIFont.igFont(ofSize: 15)
        lblEXPData.font = UIFont.igFont(ofSize: 15)
        lblEXP.font = UIFont.igFont(ofSize: 15)

        btnInquery.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }
    
    

}

extension IGGIftPayInfoModal: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(450)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(450)
        } else {
            return .contentHeight(450)
        }

    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}
