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

    var mode : String = "NATIONAL_ID"
    var roomID : Int64 = 0

    var isShortFormEnabled = true
    var isKeyboardPresented = false

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var tfNationalID : UITextField!
    @IBOutlet weak var btnInquery : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "NATIONAL_ID" :
            initView()
            break
        default :
            break
        }
        initTheme()
        btnInquery.addTarget(self, action: #selector(didTapOnInquery), for: .touchUpInside)
        tfNationalID.keyboardType = .numberPad
    }

    @objc func didTapOnInquery() {
        
        guard let nationalCode = tfNationalID.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        btnInquery.setTitle(IGStringsManager.GlobalLoading.rawValue.localized, for: .normal)
        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] (success) in

            self!.btnInquery.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)
            if !success {return}
//            IGMessageViewController.giftUserId = self?.room?.chatRoom?.peer?.id
            let stickerController = IGStickerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            stickerController.stickerPageType = .CATEGORY
            stickerController.isGift = true
            
            self?.dismiss(animated: true, completion: {
                IGMessageViewController.giftUserId = (UIApplication.topViewController() as! IGMessageViewController).room?.chatRoom?.peer?.id
                UIApplication.topViewController()!.navigationController?.pushViewController(stickerController, animated: true)
            })
            
        }
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        tfNationalID.textColor = ThemeManager.currentTheme.LabelColor
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
        lblHeader.text = IGStringsManager.EnterNationalCode.rawValue.localized
        tfNationalID.placeholder = IGStringsManager.NationalCode.rawValue.localized
        btnInquery.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)
        btnInquery.layer.cornerRadius = 10
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        tfNationalID.font = UIFont.igFont(ofSize: 15)
        btnInquery.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
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
        return .contentHeight(150)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(450)
        } else {
            return .contentHeight(150)
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
