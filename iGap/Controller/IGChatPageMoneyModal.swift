//
//  IGChatPageMoneyModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus


protocol GiftCardTapDelegate {
    func didTapOnGiftCard(button:UIView)
}

protocol CardToCardTapDelegate {
    func didTapOnCardToCard(button:UIView)
}

protocol CashoutWalletTapDelegate {
    func didTapOnCashout(button:UIView)
}

class IGChatPageMoneyModal: BaseTableViewController {
    var GiftCardDelegate:GiftCardTapDelegate!
    var cardToCardDelegate:CardToCardTapDelegate!
    var CashoutDelegate:CashoutWalletTapDelegate!

    var issecuredPass : Bool = false

    var mode : String = "MONEY_MODAL"
    var roomID : Int64 = 0

    var isShortFormEnabled = true
    var isKeyboardPresented = false

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblGiftCard : UILabel!
    @IBOutlet weak var lblCardToCard : UILabel!
    @IBOutlet weak var lblWallet : UILabel!

    @IBOutlet weak var lblGiftCardIcon : UILabel!
    @IBOutlet weak var lblCardToCardIcon : UILabel!
    @IBOutlet weak var lblWalletIcon : UILabel!

    @IBOutlet weak var btnGiftCard : UIView!
    @IBOutlet weak var btnCardToCard : UIView!
    @IBOutlet weak var btnWallet : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "MONEY_MODAL" :
            initView()
            break
        default :
            break
        }
        initTheme()
        let tapGiftCard = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnGiftCard(_:)))
        btnGiftCard.addGestureRecognizer(tapGiftCard)

        let tapCardToCard = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnCardToCard(_:)))
        btnCardToCard.addGestureRecognizer(tapCardToCard)

        let tapCashout = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnWalletCashout(_:)))
        btnWallet.addGestureRecognizer(tapCashout)

    }

    @objc func handleTapOnGiftCard(_ sender: UITapGestureRecognizer? = nil) {
//        GiftCardDelegate.didTapOnGiftCard(button: btnGiftCard)
        self.dismiss(animated: true, completion: {
            IGHelperBottomModals.shared.showNationalIDModal(view: UIApplication.topViewController())
        })
    }

    @objc func handleTapOnCardToCard(_ sender: UITapGestureRecognizer? = nil) {
//        cardToCardDelegate.didTapOnCardToCard(button: btnGiftCard)
        self.dismiss(animated: true, completion: {
            IGHelperBottomModals.shared.showCardToCardModal(view: UIApplication.topViewController())
        })

    }

    @objc func handleTapOnWalletCashout(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: {
            IGHelperBottomModals.shared.showWalletTransferModal(view: UIApplication.topViewController())
        })
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblGiftCard.textColor = ThemeManager.currentTheme.LabelColor
        lblGiftCardIcon.textColor = ThemeManager.currentTheme.LabelColor

        lblCardToCard.textColor = ThemeManager.currentTheme.LabelColor
        lblCardToCardIcon.textColor = ThemeManager.currentTheme.LabelColor

        lblWallet.textColor = ThemeManager.currentTheme.LabelColor
        lblWalletIcon.textColor = ThemeManager.currentTheme.LabelColor


        
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
        lblHeader.text = IGStringsManager.ChooseOne.rawValue.localized

        
        lblGiftCardIcon.text = "☚"
        lblGiftCard.text = IGStringsManager.GiftCard.rawValue.localized
        lblCardToCardIcon.text = ""
        lblCardToCard.text = IGStringsManager.CardToCard.rawValue.localized
        lblWallet.text = IGStringsManager.WalletMoneyTransfer.rawValue.localized
        lblWalletIcon.text = ""

        

    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblGiftCard.font = UIFont.igFont(ofSize: 13)
        lblGiftCardIcon.font = UIFont.iGapFonticon(ofSize: 30)

        lblCardToCard.font = UIFont.igFont(ofSize: 13)
        lblCardToCardIcon.font = UIFont.iGapFonticon(ofSize: 30)

        lblWallet.font = UIFont.igFont(ofSize: 13)
        lblWalletIcon.font = UIFont.iGapFonticon(ofSize: 30)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
        lblWallet.textAlignment = .center
        lblWalletIcon.textAlignment = .center
        lblCardToCard.textAlignment = .center
        lblCardToCardIcon.textAlignment = .center
        lblGiftCard.textAlignment = .center
        lblGiftCardIcon.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}

extension IGChatPageMoneyModal: PanModalPresentable {
    
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
            return .contentHeight(150)
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
