//
//  SMGetGift.swift
//  PayGear
//
//  Created by HSM on 2/21/19.
//  Copyright © 2019 Samsoon. All rights reserved.
//

import Foundation
import SnapKit

class SMGetGift {
    
    private static var GetGift : SMGetGift?
    
    public static func getInstance() -> SMGetGift{
        if GetGift == nil
        {
            GetGift = SMGetGift()
            return GetGift!
        }
        
        return GetGift!
        
    }
    
    init() {
        
    }
    
    
    var GetGiftPage : UIViewController?
    var MerchantInfo : SMMerchant?
    var viewcontroller : UIViewController?
    var ID: String?
    var Value: String?
    var ResultMessage: String?
    func showInfo(viewcontroller : UIViewController , id: String, value: String, isFaild: Bool) {
        self.ID = id
        self.Value = value
        self.viewcontroller = viewcontroller
        var page = UIViewController()
        if isFaild {
            page = PrepareErrorPage()
        } else {
            page = prepareInformation()
        }
        
        page.modalPresentationStyle = .overCurrentContext
        viewcontroller.present(page, animated: true , completion: {
            viewcontroller.tabBarController?.tabBar.isUserInteractionEnabled = false
            page.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    func showSuccess(viewcontroller : UIViewController, Message: String) {
        self.ResultMessage = Message
        self.viewcontroller = viewcontroller
        let page = PrepareSuccessPage()
        page.modalPresentationStyle = .overCurrentContext
        UIView.transition(with: GetGiftPage!.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            viewcontroller.present(page, animated: true , completion: {
                viewcontroller.tabBarController?.tabBar.isUserInteractionEnabled = false
                page.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            })
        })

        
        
    }
    
    func prepareInformation()->UIViewController{
        GetGiftPage = UIViewController()
        GetGiftPage?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        GetGiftPage?.modalTransitionStyle = .crossDissolve
        GetGiftPage?.modalPresentationStyle = .overCurrentContext
        let GetGiftView = GetGiftPopupView.instanceFromNib()
        
        if self.Value != nil && Int64(self.Value!) != 0 {
            
            GetGiftView.MessageLabel.text = "کوپن هدیه پیگیر به مبلغ \(self.Value ?? "0") ریال. \nمایل به دریافت آن هستید؟"
            
        } else {
            GetGiftView.MessageLabel.text = "barcode.gift.wrongemessage".localized
        }
        
        GetGiftView.layer.cornerRadius = 15
        GetGiftView.layer.masksToBounds = true
        GetGiftView.delegate = viewcontroller as? HandleGiftView
//        GetGiftView.frame = CGRect(x: GetGiftPage!.view.center.x - 150, y: GetGiftPage!.view.center.y - 84, width: 300, height: 300)
        GetGiftPage?.view.addSubview(GetGiftView)
        GetGiftView.snp.makeConstraints { (make) in
            make.centerX.equalTo(GetGiftPage!.view.snp.centerX)
            make.centerY.equalTo(GetGiftPage!.view.snp.centerY)
            make.width.equalTo(300.0)
            make.height.equalTo(200.0)
        }
        
        
        return GetGiftPage!
    }
    
    func PrepareErrorPage()->UIViewController {
        GetGiftPage = UIViewController()
        GetGiftPage?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        GetGiftPage?.modalTransitionStyle = .crossDissolve
        GetGiftPage?.modalPresentationStyle = .overCurrentContext
        let GetGiftView = GetGiftPopupView.instanceFromNib()
        GetGiftView.TitleLabel.text = self.ID
        GetGiftView.MessageLabel.text = self.Value
        GetGiftView.ConfirmButton.isHidden = true
        GetGiftView.ConfirmButtonWidth.constant = 0
        GetGiftView.CancelButton.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
        GetGiftView.layer.cornerRadius = 15
        GetGiftView.layer.masksToBounds = true
        GetGiftView.delegate = viewcontroller as? HandleGiftView
//        GetGiftView.frame = CGRect(x: GetGiftPage!.view.center.x - 150, y: GetGiftPage!.view.center.y - 84, width: 300, height: 300)
        GetGiftPage?.view.addSubview(GetGiftView)
        GetGiftView.snp.makeConstraints { (make) in
            make.centerX.equalTo(GetGiftPage!.view.snp.centerX)
            make.centerY.equalTo(GetGiftPage!.view.snp.centerY)
            make.width.equalTo(300.0)
            make.height.equalTo(200.0)
        }
        return GetGiftPage!
    }
    
    func PrepareSuccessPage()->UIViewController {
        GetGiftPage = UIViewController()
        GetGiftPage?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        GetGiftPage?.modalTransitionStyle = .crossDissolve
        GetGiftPage?.modalPresentationStyle = .overCurrentContext
        let GetGiftView = GetGiftPopupView.instanceFromNib()
        GetGiftView.TitleLabel.isHidden = true
        GetGiftView.MessageLabel.isHidden = true
        GetGiftView.ConfirmButton.isHidden = true
        GetGiftView.ConfirmButtonWidth.constant = 0
        GetGiftView.CancelButton.isHidden = false
        GetGiftView.CancelButton.backgroundColor = UIColor(red: 0/255, green: 230/255, blue: 118/255, alpha: 1)
        GetGiftView.CancelButton.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
        GetGiftView.CancelButton.setTitleColor(UIColor.white, for: .normal)
        GetGiftView.ResultLabel.text = self.ResultMessage
        GetGiftView.layer.cornerRadius = 15
        GetGiftView.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = GetGiftView.GradiantView.frame
        gradientLayer.colors = [UIColor(red: 34/255, green: 148/255, blue: 255/255, alpha: 1), UIColor(red: 222/255, green: 10/255, blue: 233/255, alpha: 1)]
        gradientLayer.locations = [0.0,1.0]
        GetGiftView.GradiantView.layer.addSublayer(gradientLayer)
        
        GetGiftView.delegate = viewcontroller as? HandleGiftView
//        GetGiftView.frame = CGRect(x: GetGiftPage!.view.center.x - 150, y: GetGiftPage!.view.center.y - 84, width: 300, height: 300)
        GetGiftView.resultBackGroundView.isHidden = false
        GetGiftPage?.view.addSubview(GetGiftView)
        GetGiftView.snp.makeConstraints { (make) in
            make.centerX.equalTo(GetGiftPage!.view.snp.centerX)
            make.centerY.equalTo(GetGiftPage!.view.snp.centerY)
            make.width.equalTo(300.0)
            make.height.equalTo(200.0)
        }

        
        return GetGiftPage!
    }
}
