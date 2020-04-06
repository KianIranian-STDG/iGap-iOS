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

class IGGiftStickersListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tabbarHeight: CGFloat?
    var giftCardType: GiftStickerListType = .new
    var giftCardList: [IGStructGiftCardListData] = []
    var giftStickerInfo: SMCheckGiftSticker!
    var giftStickerAlertView: SMGiftStickerAlertView!
    var giftStickerPaymentInfo: SMGiftCardInfo!
    var giftCardInfo: IGStructGiftCardStatus!
    var dismissBtn: UIButton!
    let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
    var needToNationalCode : Bool = false // TODO - check and do better structure
    var waitingCardId: String? // TODO - check and do better structure
    private var activationGiftStickerId: String?
    static var tabbarHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if IGGiftStickersListViewController.tabbarHeight == nil || tabbarHeight == nil || tabbarHeight == 0{ // TODO - do this for avoid from duplicate tabbar height (this is a bug find a better solution)
            IGGiftStickersListViewController.tabbarHeight = tabbarHeight
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        initNavigationBar()
        manageShowActivties(isFirst: true)
        fetchGiftCards()
        
        NotificationCenter.default.addObserver(self, selector: #selector(IGMessageViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(title: IGStringsManager.GiftCardReport.rawValue.localized, width: 200)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func manageShowActivties(isFirst: Bool = false){
        if isFirst {
            self.tableView!.setEmptyMessage(IGStringsManager.WaitDataFetch.rawValue.localized)
        } else if giftCardList.count == 0 {
            self.tableView!.setEmptyMessage(IGStringsManager.CardListIsEmpty.rawValue.localized)
        } else {
            self.tableView!.restore()
        }
    }
    
    private func fetchGiftCards(){
        IGApiSticker.shared.giftStickerCardsList(status: giftCardType) { [weak self] giftCardList in
            for giftCard in giftCardList.data {
                self?.giftCardList.append(giftCard)
            }
            self?.manageShowActivties()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    //MARK:- User Actions

    private func getCardPaymentInfo(stickerId: String) {
        
        let nationalCode = IGSessionInfo.getNationalCode()
        if nationalCode == nil || nationalCode!.isEmpty {
            self.waitingCardId = stickerId
            showActiveOrForward(fetchNationalCode: true)
            return
        }
        
        IGGlobal.prgShow()
        guard let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        IGApiSticker.shared.getGiftCardInfo(stickerId: stickerId, nationalCode: nationalCode!, mobileNumber: phone.phoneConvert98to0(), completion: { [weak self] giftCardInfo in
            IGGlobal.prgHide()
            self?.showGiftStickerPaymentInfo(cardInfo: giftCardInfo)
        }, error: {
            IGGlobal.prgHide()
        })
    }
    
    private func getCardStatus(stickerId: String, date: String){
        self.activationGiftStickerId = stickerId
        IGGlobal.prgShow()
        IGApiSticker.shared.getGiftCardGetStatus(stickerId: stickerId, completion: { [weak self] giftCardStatus in
            IGGlobal.prgHide()
            self?.showCardInfo(stickerInfo: giftCardStatus, date: date)
        }, error: {
            IGGlobal.prgHide()
        })
    }
    
    private func showCardInfo(stickerInfo: IGStructGiftCardStatus, date: String){
        self.dismissBtn = UIButton()
        self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.view.insertSubview(self.dismissBtn, at: 2)
        self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
        
        self.dismissBtn?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
        self.giftCardInfo = stickerInfo
        self.giftStickerInfo = SMCheckGiftSticker.loadFromNib()
        self.giftStickerInfo.confirmBtn.addTarget(self, action: #selector(self.confirmTapped), for: .touchUpInside)
        self.giftStickerInfo.setInfo(giftSticker: stickerInfo, date: date)
        self.giftStickerInfo.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerInfo.frame.height)
        self.giftStickerInfo.infoLblOne.text = IGStringsManager.GiftCard.rawValue.localized
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        self.giftStickerInfo.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerInfo)
        
        UIView.animate(withDuration: 0.3) {
            self.giftStickerInfo.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerInfo.frame.height - 5 -  self.bottomPadding!, width: self.view.frame.width, height: self.giftStickerInfo.frame.height)
        }
    }
    
    private func showActiveOrForward(fetchNationalCode: Bool = false){
        self.needToNationalCode = fetchNationalCode
        self.giftStickerAlertView = SMGiftStickerAlertView.loadFromNib()
        self.giftStickerAlertView.btnOne.addTarget(self, action: #selector(self.confirmTapped), for: .touchUpInside)
        self.giftStickerAlertView.btnTwo.addTarget(self, action: #selector(self.sendToAnother), for: .touchUpInside)
        self.giftStickerAlertView.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerAlertView.frame.height)
        manageButtonsView(buttons: [giftStickerAlertView.btnOne, giftStickerAlertView.btnTwo])
        giftStickerAlertView.btnOne.setTitle(IGStringsManager.Activation.rawValue.localized, for: UIControl.State.normal)
        giftStickerAlertView.btnTwo.setTitle(IGStringsManager.GiftStickerSendToOther.rawValue.localized, for: UIControl.State.normal)
        giftStickerAlertView.infoLblOne.text = IGStringsManager.ActivateOrSendAsMessage.rawValue.localized
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        self.giftStickerAlertView.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerAlertView)
        
        let yPosition = self.view.frame.height - self.giftStickerAlertView.frame.height - (self.bottomPadding! + (IGGiftStickersListViewController.tabbarHeight ?? 0))
        UIView.animate(withDuration: 0.3) {
            self.giftStickerAlertView.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.giftStickerAlertView.frame.height)
        }
        if fetchNationalCode {
            self.dismissBtn = UIButton()
            self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            self.view.insertSubview(self.dismissBtn, at: 2)
            self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
            
            self.dismissBtn?.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.snp.top)
                make.bottom.equalTo(self.view.snp.bottom)
                make.right.equalTo(self.view.snp.right)
                make.left.equalTo(self.view.snp.left)
            }
            
            giftStickerAlertView.btnOne.setTitle(IGStringsManager.NationalCodeInquiry.rawValue.localized, for: UIControl.State.normal)
            giftStickerAlertView.btnTwo.isHidden = true
        }
    }
    private func showGiftStickerPaymentInfo(cardInfo: IGStructGiftCardInfo){
        self.dismissBtn = UIButton()
        self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.view.insertSubview(self.dismissBtn, at: 2)
        self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
        
        self.dismissBtn?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
        
        self.giftStickerPaymentInfo = SMGiftCardInfo.loadFromNib()
        self.giftStickerPaymentInfo.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerPaymentInfo.frame.height)
        self.giftStickerPaymentInfo.setInfo(giftCardInfo: cardInfo)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        self.giftStickerPaymentInfo.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerPaymentInfo)
        
        let yPosition = self.view.frame.height - self.giftStickerPaymentInfo.frame.height - (self.bottomPadding! + (IGGiftStickersListViewController.tabbarHeight ?? 0))
        UIView.animate(withDuration: 0.3) {
            self.giftStickerPaymentInfo.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.giftStickerPaymentInfo.frame.height)
        }
    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
            button.layer.borderWidth = 1.0
        }
    }
    
    @objc func didtapOutSide(keepBackground: Bool = false) {
        UIView.animate(withDuration: 0.3, animations: {
            self.giftStickerInfo?.frame.origin.y = self.view.frame.height
            self.giftStickerAlertView?.frame.origin.y = self.view.frame.height
            self.giftStickerPaymentInfo?.frame.origin.y = self.view.frame.height
        }) { (true) in }

        let hideInfo = giftStickerInfo != nil
        let hideAlertView = giftStickerAlertView != nil
        let hideCardInfo = giftStickerPaymentInfo != nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if hideInfo {
                self.giftStickerInfo?.removeFromSuperview()
                self.giftStickerInfo = nil
            }
            
            if hideAlertView {
                self.giftStickerAlertView?.removeFromSuperview()
                self.giftStickerAlertView = nil
            }
            
            if hideCardInfo {
                self.giftStickerPaymentInfo?.removeFromSuperview()
                self.giftStickerPaymentInfo = nil
            }
            
            if !keepBackground {
                self.dismissBtn?.removeFromSuperview()
                self.dismissBtn = nil
            }
        }
    }
    
    @objc func handleGesture(gesture: UITapGestureRecognizer) {
        self.didtapOutSide(keepBackground: false)
    }
    
    @objc func confirmTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if giftStickerInfo != nil {
            didtapOutSide(keepBackground: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showActiveOrForward()
            }
        } else if giftStickerAlertView != nil {
            guard let nationalCode = giftStickerAlertView.edtInternationalCode.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
            
            didtapOutSide(keepBackground : false)
            
            IGGlobal.prgShow()
            IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
                if !success {
                    IGGlobal.prgHide()
                    return
                }
                
                if self?.needToNationalCode ?? false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        IGGlobal.prgHide()
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
                            DispatchQueue.main.async {
                                self?.giftCardList.removeAll()
                                self?.tableView.reloadData()
                            }
                            self?.fetchGiftCards()
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.ActivationSuccessful.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        }
                    }, error: {
                        IGGlobal.prgHide()
                    })
                })
            }
        }
    }
    
    @objc func sendToAnother(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let nationalCode = giftStickerAlertView.edtInternationalCode.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        didtapOutSide(keepBackground: false)
        
        IGGlobal.prgShow()
        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
            IGGlobal.prgHide()
            if !success {
                return
            }
            
            if let attachment = IGAttachmentManager.sharedManager.getFileInfo(token: (self?.giftCardInfo.sticker.token)!) {
                let message = IGRoomMessage(body: (self?.giftCardInfo.sticker.name)!)
                message.type = .sticker
                message.attachment = attachment
                let stickerItem = IGRealmStickerItem(sticker: (self?.giftCardInfo.sticker)!, giftId: (self?.giftCardInfo.id)!)
                message.additional = IGRealmAdditional(additionalData: IGHelperJson.convertRealmToJson(stickerItem: stickerItem)!, additionalType: AdditionalType.GIFT_STICKER.rawValue)
                IGAttachmentManager.sharedManager.add(attachment: attachment)
                
                IGRoomMessage.saveFakeGiftStickerMessage(message: message.detach()) { [weak self] in
                    DispatchQueue.main.async {
                        IGHelperBottomModals.shared.showMultiForwardModal(view: self, messages: [message], isFromCloud: true, isGiftSticker: true, giftId: self?.giftCardInfo.id ?? "")
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let giftSticker = giftStickerAlertView {
            let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let keyboardHeight = keyboardSize?.height
            let window = UIApplication.shared.keyWindow!
            window.addSubview(giftSticker)
            UIView.animate(withDuration: 0.3) {
                var frame = giftSticker.frame
                frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                giftSticker.frame = frame
            }
        }
    }
    
    
    // MARK:- TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giftCardList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 2))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 2))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiftCardListCell", for: indexPath) as! IGGiftStickerListCell
        cell.setInfo(giftCard: giftCardList[indexPath.row], listType: self.giftCardType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let giftSticker = giftCardList[indexPath.row]
        if self.giftCardType == .new {
            getCardStatus(stickerId: giftSticker.id, date: giftSticker.createdAt)
        } else if self.giftCardType == .active {
            getCardPaymentInfo(stickerId: giftSticker.id)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let userId = giftCardList[indexPath.row].toUserId, !userId.isEmpty {
            return 140
        }
        return 85
    }
    
 }
