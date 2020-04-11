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
import SnapKit

class IGGiftStickerFirstPageViewController: BaseViewController {

    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var imgBanner: IGImageView!
    @IBOutlet weak var viewNationlCodeParent: UIView!
    @IBOutlet weak var txtGiftLabel: UILabel!
    @IBOutlet weak var edtNationalCode: UITextField!
    @IBOutlet weak var btnNationalCode: UIButton!
    @IBOutlet weak var btnMyCards: UIButton!
    @IBOutlet weak var btnActivatedGiftCards: UIButton!
    var pageInfo: IGStructGiftFirstPageInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        customizeView(img: imgBanner, view: viewBanner)
        customizeView(view: viewNationlCodeParent)
        manageButtonsView(buttons: [btnNationalCode, btnMyCards, btnActivatedGiftCards])
        self.hideKeyboardWhenTappedAround()
        
        edtNationalCode.placeholder = IGStringsManager.NationalCode.rawValue.localized
        edtNationalCode.textColor = ThemeManager.currentTheme.LabelColor
        //edtNationalCode.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        edtNationalCode.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        edtNationalCode.layer.borderWidth = 1.0
        edtNationalCode.layer.masksToBounds = true
        edtNationalCode.layer.cornerRadius = edtNationalCode.bounds.height / 2
        
        txtGiftLabel.text = IGStringsManager.GiftStickerBuy.rawValue.localized
        btnNationalCode.setTitle(IGStringsManager.InquiryAndShopping.rawValue.localized, for: UIControl.State.normal)
        btnMyCards.setTitle(IGStringsManager.MyCards.rawValue.localized, for: UIControl.State.normal)
        btnActivatedGiftCards.setTitle(IGStringsManager.MyReceivedGiftSticker.rawValue.localized, for: UIControl.State.normal)
        
        if let nationalCode = IGSessionInfo.getNationalCode() {
            self.edtNationalCode.text = nationalCode
        }
        
        imgBanner.snp.remakeConstraints { (make) in
            make.leading.equalTo(self.view.snp.leading).offset(10)
            make.trailing.equalTo(self.view.snp.trailing).offset(-10)
            make.top.equalTo(self.view.snp.top).offset(10)
            make.height.equalTo(computeHeight(scale: pageInfo.info.scale) + 4)
        }
        if let url = URL(string: pageInfo.data[0].imageURL) {
            imgBanner?.sd_setImage(with: url, completed: nil)
        }
        let tmplabelcolor = IGGlobal.makeCustomColor(OtherThemesColor: .white, BlackThemeColor: .white)
        let tmpbgcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.SliderTintColor, BlackThemeColor: .white)
        btnMyCards.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        btnMyCards.setTitleColor(tmplabelcolor, for: .normal)
        btnNationalCode.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        btnNationalCode.setTitleColor(tmplabelcolor, for: .normal)
        btnActivatedGiftCards.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        btnActivatedGiftCards.setTitleColor(tmplabelcolor, for: .normal)
        txtGiftLabel.textColor = tmpbgcolor

    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.GiftCard.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
            button.layer.borderWidth = 1.0
        }
    }
    
    private func customizeView(img: UIImageView? = nil, view: UIView?){
        view?.layer.masksToBounds = false
        view?.layer.cornerRadius = IGDashboardViewController.itemCorner
        view?.layer.shadowOffset = CGSize(width: 1, height: 1)
        view?.layer.shadowRadius = 1
        view?.layer.shadowColor = UIColor.gray.cgColor
        view?.layer.shadowOpacity = 0.4
        view?.backgroundColor = ThemeManager.currentTheme.DashboardCellBackgroundColor
        
        img?.layer.cornerRadius = IGDashboardViewController.itemCorner
        img?.layer.masksToBounds = true
        img?.backgroundColor = UIColor.clear
    }
    
    private func computeHeight(scale: String) -> CGFloat{
        let split = scale.split(separator: ":")
        let heightScale = NumberFormatter().number(from: split[1].description)
        let widthScale = NumberFormatter().number(from: split[0].description)
        let scale = CGFloat(truncating: heightScale!) / CGFloat(truncating: widthScale!)
        let height: CGFloat = (IGGlobal.fetchUIScreen().width - 20) * scale // -40 because of 20 offset from leading and trailing
        return height
    }
    
    
    @IBAction func btnNationalCode(_ sender: UIButton) {
        guard let nationalCode = edtNationalCode.text, let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        IGGlobal.prgShow()
        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] (success) in
            IGGlobal.prgHide()
            if !success {return}
            IGMessageViewController.giftUserId = nil
            let stickerController = IGStickerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            stickerController.stickerPageType = .CATEGORY
            stickerController.isGift = true
            self?.navigationController!.pushViewController(stickerController, animated: true)
        }
    }
    
    @IBAction func btnMyCards(_ sender: UIButton) {
        IGTabBarGiftStickersList.openGiftStickersReport()
    }
    
    @IBAction func btnActivatedCards(_ sender: UIButton) {
        let giftStickerCards = IGGiftStickersListViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        giftStickerCards.giftCardType = .active
        self.navigationController!.pushViewController(giftStickerCards, animated: true)
    }
}
