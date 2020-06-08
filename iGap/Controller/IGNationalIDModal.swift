//
//  IGNationalIDModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGNationalIDModal: BaseTableViewController {

    var issecuredPass : Bool = false

    var mode : String = "NATIONAL_ID_Buy"
    var roomID : Int64 = 0
    var giftcard : IGStructGiftCardSticker!

    var isShortFormEnabled = true
    var isKeyboardPresented = false
    private var activationGiftStickerId: String?
    private var needToNationalCode : Bool = false // TODO - check and do better structure
    private var waitingCardId: String? // TODO - check and do better structure

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var tfNationalID : UITextField!
    @IBOutlet weak var btnInquery : UIButton!
    @IBOutlet weak var btnSendToAnother : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "NATIONAL_ID_Buy" :
            initView()
            break
        default :
            initView()
            break
        }
        initTheme()
        btnInquery.addTarget(self, action: #selector(didTapOnInquery), for: .touchUpInside)
        btnSendToAnother.addTarget(self, action: #selector(didTapOnSendToOthers), for: .touchUpInside)

        tfNationalID.keyboardType = .numberPad
    }

    @objc func didTapOnSendToOthers() {
        sendToOther()
    }
    @objc func didTapOnInquery() {
        showActiveOrForward()
    }
    private func sendToOther() {
//        guard let nationalCode = tfNationalID.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
//
//        btnSendToAnother.setTitle(IGStringsManager.GlobalLoading.rawValue.localized, for: .normal)
//        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
//            IGGlobal.prgHide()
//            if !success {
//                return
//            }
            self.dismiss(animated: true, completion: {
                (UIApplication.topViewController() as! IGMessageViewController).sendToAnother()
            })
//        }
    }
    
    private func showActiveOrForward(fetchNationalCode: Bool = false) {
        
        guard let nationalCode = tfNationalID.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        btnInquery.setTitle(IGStringsManager.GlobalLoading.rawValue.localized, for: .normal)
        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
            guard let sSelf = self else {return}
            if !success {
                if sSelf.mode == "NATIONAL_ID_Buy" {
                    sSelf.btnInquery.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)

                }else {
                    sSelf.btnInquery.setTitle(IGStringsManager.Activation.rawValue.localized, for: .normal)

                }
                return
            }
            
            if self?.needToNationalCode ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if sSelf.mode == "NATIONAL_ID_Buy" {
                        sSelf.btnInquery.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)

                    }else {
                        sSelf.btnInquery.setTitle(IGStringsManager.Activation.rawValue.localized, for: .normal)

                    }
                    self?.getCardPaymentInfo(stickerId: self?.waitingCardId ?? "")
                }
                return
            }
            
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.GiftCardActivationNote.rawValue.localized, doneText: IGStringsManager.GlobalDone.rawValue.localized ,cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {
                IGGlobal.prgHide()
            }, done: {
                IGApiSticker.shared.giftCardActivate(stickerId: self?.activationGiftStickerId ?? "", nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0(), completion: { data in
                    IGGlobal.prgHide()
                    if success {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.ActivationSuccessful.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                }, error: {
                    IGGlobal.prgHide()
                })
            })
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    private func getCardPaymentInfo(stickerId: String){
        let nationalCode = IGSessionInfo.getNationalCode()
        if nationalCode == nil || nationalCode!.isEmpty {
            self.waitingCardId = stickerId
            showActiveOrForward(fetchNationalCode: true)
            return
        }
        
        IGGlobal.prgShow()
        guard let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        IGApiSticker.shared.getGiftCardInfo(stickerId: stickerId, nationalCode: nationalCode!, mobileNumber: phone.phoneConvert98to0(), completion: { [weak self] giftCardInfo in
            self?.dismiss(animated: true, completion: {
                IGHelperBottomModals.shared.showGiftPayInfoModal(view: UIApplication.topViewController(), giftCardInfo: giftCardInfo)
            })
            }, error: {
                IGGlobal.prgHide()
        })
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        tfNationalID.textColor = ThemeManager.currentTheme.LabelColor
        btnInquery.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnInquery.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor

        btnSendToAnother.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnSendToAnother.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor

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
        lblHeader.text = IGStringsManager.EnterNationalCode.rawValue.localized
        tfNationalID.placeholder = IGStringsManager.NationalCode.rawValue.localized

        btnInquery.layer.cornerRadius = 10
        btnSendToAnother.layer.cornerRadius = 10
        if mode == "NATIONAL_ID_Buy" {
            btnSendToAnother.isHidden = true
            btnInquery.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)

        }else {
            btnSendToAnother.isHidden = false
            btnInquery.setTitle(IGStringsManager.Activation.rawValue.localized, for: .normal)
            btnSendToAnother.setTitle(IGStringsManager.GiftStickerSendToOther.rawValue.localized, for: .normal)

        }
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        tfNationalID.font = UIFont.igFont(ofSize: 15)
        btnInquery.titleLabel!.font = UIFont.igFont(ofSize: 15)
        btnSendToAnother.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
        tfNationalID.textAlignment = .center
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}

extension IGNationalIDModal: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(180)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(450)
        } else {
            return .contentHeight(180)
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
