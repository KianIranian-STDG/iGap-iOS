//
//  IGCardToCardModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import SwiftEventBus

class IGCardToCardModal: BaseTableViewController {

    var issecuredPass : Bool = false

    var mode : String = "CARDTOCARD"
    var roomID : Int64 = 0

    var isShortFormEnabled = true
    var isKeyboardPresented = false

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var tfAmount : UITextField!
    @IBOutlet weak var lblCardNum : UILabel!
    @IBOutlet weak var tfCardNum : UITextField!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var tfDescription : UITextField!

    @IBOutlet weak var btnSend : UIButton!

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self,name: EventBusManager.sendCardToCardMessage)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "CARDTOCARD" :
            initView()
            break
        default :
            break
        }
        initTheme()
        btnSend.addTarget(self, action: #selector(didTapOnSend), for: .touchUpInside)
        tfAmount.keyboardType = .numberPad
        tfCardNum.keyboardType = .numberPad
    }

    @objc func didTapOnSend() {
        if tfCardNum.text == "" ||  tfCardNum.text == nil || tfAmount.text == "" ||  tfAmount.text == nil || tfDescription.text == "" ||  tfDescription.text == nil {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AmountNotValid.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
        } else {
            self.dismiss(animated: true, completion: {
                let messageText = self.tfDescription.text!.substring(offset: 4096)
                let message = IGRoomMessage.makeCardToCardRequestWithAmount(messageText: messageText, amount: ((self.tfAmount.text!).inEnglishNumbersNew().onlyDigitChars()), cardNumber: ((self.tfCardNum.text!).inEnglishNumbersNew().onlyDigitChars()))
                SwiftEventBus.post(EventBusManager.sendCardToCardMessage,sender: message)

            })
        }

    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblCardNum.textColor = ThemeManager.currentTheme.LabelColor
        lblDescription.textColor = ThemeManager.currentTheme.LabelColor
        tfAmount.textColor = ThemeManager.currentTheme.LabelColor
        tfCardNum.textColor = ThemeManager.currentTheme.LabelColor
        tfDescription.textColor = ThemeManager.currentTheme.LabelColor
        btnSend.setTitleColor(.white, for: .normal)
        btnSend.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        
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
        lblHeader.text = IGStringsManager.MBEnterAmount.rawValue.localized
        lblAmount.text = IGStringsManager.AmountInRial.rawValue.localized
        lblCardNum.text = IGStringsManager.DestinationCard.rawValue.localized + ":"
        lblDescription.text = IGStringsManager.Desc.rawValue.localized + ":"
        btnSend.setTitle(IGStringsManager.Send.rawValue.localized, for: .normal)
        btnSend.layer.cornerRadius = 10
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblAmount.font = UIFont.igFont(ofSize: 13)
        lblCardNum.font = UIFont.igFont(ofSize: 13)
        lblDescription.font = UIFont.igFont(ofSize: 13)
        tfAmount.font = UIFont.igFont(ofSize: 15)
        tfCardNum.font = UIFont.igFont(ofSize: 15)
        tfDescription.font = UIFont.igFont(ofSize: 15)
        btnSend.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
        lblAmount.textAlignment = lblHeader.localizedDirection
        lblCardNum.textAlignment = lblHeader.localizedDirection
        lblDescription.textAlignment = lblHeader.localizedDirection
        tfAmount.textAlignment = .center
        tfCardNum.textAlignment = .center
        tfDescription.textAlignment = .center
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}

extension IGCardToCardModal: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(350)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(600)
        } else {
            return .contentHeight(350)
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
