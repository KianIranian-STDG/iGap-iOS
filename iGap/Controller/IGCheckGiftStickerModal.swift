//
//  IGCheckGiftStickerModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGCheckGiftStickerModal: BaseTableViewController {

    var issecuredPass : Bool = false

    var mode : String = "BUY_STICKER"
    var roomID : Int64 = 0
    var token : String = "0"
    var amount : String = "0"
    var giftcard : IGStructGiftCardSticker!
    var isShortFormEnabled = true
    var isKeyboardPresented = false

    @IBOutlet weak var imgGiftCard : UIImageView!
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblStickerData : UILabel!
    @IBOutlet weak var btnInquery : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "BUY_STICKER" :
            initView()
            break
        default :
            initView()
            break
        }
        initTheme()
        btnInquery.addTarget(self, action: #selector(didTapOnInquery), for: .touchUpInside)
        setInfo(token: token, amount: amount)
    }

    @objc func didTapOnInquery() {
        if mode == "BUY_STICKER" {

            dismiss(animated: true, completion: {
                var phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0)
                if phone == nil {return}
                phone = ("+"+phone!).replace("+98", withString: "0")
                
                IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
                IGApiSticker.shared.checkBuyGiftCard(stickerId: (UIApplication.topViewController() as! IGStickerViewController).giftStickerId ?? "", nationalCode: IGSessionInfo.getNationalCode() ?? "", mobileNumber: phone!, count: 1, completion: { [weak self] buyGiftSticker in
                    (UIApplication.topViewController() as! IGStickerViewController).giftStickerId = nil
                    
                    IGStickerViewController.waitingGiftCardInfo.giftId = buyGiftSticker.id
                    IGApiSticker.shared.giftStickerPaymentRequest(token: buyGiftSticker.token, completion: { giftCardPayment in
                        
                        guard let orderId = giftCardPayment.info?.orderID else {
                            IGLoading.hideLoadingPage()
                            
                            IGPaymentView.sharedInstance.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.GiftCard.rawValue.localized, message: IGStringsManager.PaymentErrorMessage.rawValue.localized)
                            return
                        }
                        
                        IGStickerViewController.waitingGiftCardInfo.orderId = orderId
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
        lblStickerData.textColor = ThemeManager.currentTheme.LabelColor
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
        if mode == "BUY_STICKER" {
            btnInquery.setTitle(IGStringsManager.Payment.rawValue.localized, for: .normal)

        }else {
            btnInquery.setTitle(IGStringsManager.ActivateOrSendAsMessage.rawValue.localized, for: .normal)

        }
        btnInquery.layer.cornerRadius = 10
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblStickerData.font = UIFont.igFont(ofSize: 15)
        btnInquery.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
        lblStickerData.textAlignment = .center
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
    }
    
    func setInfo(token: String, amount: String){
        if mode == "BUY_STICKER" {
            btnInquery.setTitle(IGStringsManager.Payment.rawValue.localized, for: .normal)
        }else {
            btnInquery.setTitle(IGStringsManager.ActivateOrSendAsMessage.rawValue.localized, for: .normal)
        }

        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            DispatchQueue.main.async {
                self.imgGiftCard.setSticker(for: file)
            }
        })
        
        lblStickerData.text = IGStringsManager.GiftCardSelected.rawValue.localized + "\n" + amount.inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
    }

}

extension IGCheckGiftStickerModal: PanModalPresentable {
    
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
