//
//  SMReciept.swift
//  PayGear
//
//  Created by amir soltani on 6/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation

class SMReciept {
    
    private static var reciept : SMReciept?
    
    public static func getInstance() -> SMReciept{
        if reciept == nil
        {
            reciept = SMReciept()
            return reciept!
        }
        
        return reciept!
        
    }
    
    init() {
        
    }
    
    
    var recieptPage : UIViewController?
    //var recieptView : SMRecieptView?
    var response : NSDictionary?
    var viewcontroller : UIViewController?
    
    
    func showReciept(viewcontroller : UIViewController , response : NSDictionary) {
        self.response = response
        self.viewcontroller = viewcontroller
        let page = prepareReciept()
        page.modalPresentationStyle = .overCurrentContext
        viewcontroller.present(page, animated: true , completion: {
            viewcontroller.tabBarController?.tabBar.isUserInteractionEnabled = false
            page.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    
    
    func prepareReciept()->UIViewController{
        recieptPage = UIViewController()
        recieptPage?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        recieptPage?.modalTransitionStyle = .crossDissolve
        recieptPage?.modalPresentationStyle = .overCurrentContext
        let recieptView = SMRecieptView.instanceFromNib()
        if let rowData = self.response?.value(forKey: "result") as? [Any] {
            for item in rowData{
                
                
                if let pairItem = item as? NSDictionary , (pairItem["value"] as? String) != "0" {
                    
                    
                    let row = SMRecieptRowView.instanceFromNib()
                    row.recieptTitleLabel.text = (pairItem["key"] as? String)?.inLocalizedLanguage()
                    row.valueLabel.text = (pairItem["value"] as? String)?.inLocalizedLanguage()
                    recieptView.dataStackView.addArrangedSubview(row)
                    
                    
                }
            }
            
            
            recieptView.layer.cornerRadius = 15
            recieptView.layer.masksToBounds = true
            recieptView.delegate = viewcontroller as? HandleReciept
            recieptView.frame = CGRect(x: recieptPage!.view.center.x - 140, y: recieptPage!.view.center.y - 230, width: 280, height: 380)
            recieptPage?.view.addSubview(recieptView)
//          self.viewcontroller?.present(recieptPage! , animated: true, completion: nil)
        }
            
        else if let rowData = self.response?.value(forKey: "result") as? NSDictionary{
            
            for item in rowData{
                
                
                if  String.init(describing: item.value) != "0"  {
                    
                    
                    let row = SMRecieptRowView.instanceFromNib()
                    row.recieptTitleLabel.text = String.init(describing: item.key).inLocalizedLanguage()
                    if String.init(describing: item.key) == "amount" || String.init(describing: item.key) == "مبلغ"
                    {
                        row.valueLabel.text = String.init(describing: item.value).inRialFormat().inLocalizedLanguage()
                    }else{
                        row.valueLabel.text = String.init(describing: item.value).inLocalizedLanguage()
                    }
                    recieptView.dataStackView.addArrangedSubview(row)
                    
                    
                }
            }
            if let state = self.response?.value(forKey: "state") as? UInt , state == 0 {
                
                recieptView.recieptColor.backgroundColor = UIColor.init(netHex: 0xFFC158)
                recieptView.titleLabel.text = IGStringsManager.PaymentPending.rawValue.localized
                recieptView.statusImage.image = UIImage.init(named: "hourglass")
            }
            else {
//                recieptView.recieptColor.backgroundColor = UIColor.init(netHex: 0x3BFF3D)
                recieptView.titleLabel.text = IGStringsManager.SuccessPayment.rawValue.localized
                 recieptView.statusImage.image = UIImage.init(named: "tick")
            }
            
            recieptView.layer.cornerRadius = 15
            recieptView.layer.masksToBounds = true
            recieptView.delegate = viewcontroller as? HandleReciept
            recieptView.frame = CGRect(x: recieptPage!.view.center.x - 140, y: recieptPage!.view.center.y - 230, width: 280, height: 380)
            recieptPage?.view.addSubview(recieptView)
            
            
            //viewcontroller.present(recieptPage! , animated: true, completion: nil)
        }
        return recieptPage!
    }
    
    
    
    func screenReciept(viewcontroller : UIViewController){
        
        let page = prepareReciept()
        let reciptView = (page.view.subviews[0]as! SMRecieptView)
        reciptView.buttonStackView.isHidden = true
        UIGraphicsBeginImageContextWithOptions(reciptView.frame.size,true,0.0)
        reciptView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imagesToShare = [image as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = reciptView
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.mail]
        activityViewController.modalPresentationStyle = .overCurrentContext
        viewcontroller.present(activityViewController, animated: true, completion: {

        })
        
        
    }
}
