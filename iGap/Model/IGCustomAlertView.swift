/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import SnapKit
import UIKit

class CustomAlertDirectPay: UIView, IGCustomModal {
    var backgroundView = UIView()
    var dialogView = UIView()
    
    var inquery : Bool!
    var amount : Int64!
    var toUserID : Int64!
    var invoiceNumber : Int64!
    var descriptionR : String!
    
    convenience init(data: String) {
        self.init(frame: UIScreen.main.bounds)
        parseData(data: data)
    }
    
    convenience init(data: IGStructAdditionalPayDirect) {
        self.init(frame: UIScreen.main.bounds)
        toUserID = tmpUserID
        initialize(title: data.title, price: data.price, description: data.description)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func parseData(data : String) {
        let str = data
        let data = Data(str.utf8)
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if str.contains("toId") {
                    toUserID = json["toId"] as! Int64
                } else {
                    toUserID = tmpUserID
                }
                amount = json["price"] as! Int64
                invoiceNumber = json["invoiceNumber"] as! Int64
                descriptionR = (json["description"] as! String)
                let tmpInquery = (json["inquiry"] as! Bool)
                if tmpInquery  {
                    inquery = true
                } else {
                    inquery = false
                }
                initialize(title : json["title"] as! String , price: String(amount) , description : json["description"] as! String)
                
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    func initialize(title : String , price: String , description : String){
        
        
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
        
        let dialogViewWidth = frame.width
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        titleLabel.text = title
        titleLabel.font = UIFont.igFont(ofSize: 17)
        
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)
        
        let descriptionLabel = UILabel(frame: CGRect(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8, width: dialogViewWidth-16, height: 30))
        descriptionLabel.font = UIFont.igFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .center
        dialogView.addSubview(descriptionLabel)
        
        let separatorView1 = UIView()
        separatorView1.frame.origin = CGPoint(x: 0, y: descriptionLabel.frame.height + descriptionLabel.frame.origin.y + 8)
        separatorView1.frame.size = CGSize(width: dialogViewWidth, height: 10)
        separatorView1.backgroundColor = UIColor.clear
        dialogView.addSubview(separatorView1)
        
        let priceTitleLabel = UILabel(frame: CGRect(x: 8, y: separatorView1.frame.height + separatorView1.frame.origin.y + 8, width: dialogViewWidth-16, height: 30))
        priceTitleLabel.font = UIFont.igFont(ofSize: 19 , weight: .bold)
        priceTitleLabel.textColor = .black
        priceTitleLabel.text = "PRICE".localized
        priceTitleLabel.textAlignment = .center
        dialogView.addSubview(priceTitleLabel)
        
        let priceLabel = UILabel(frame: CGRect(x: 8, y: priceTitleLabel.frame.height + priceTitleLabel.frame.origin.y + 8, width: dialogViewWidth-16, height: 30))
        priceLabel.font = UIFont.igFont(ofSize: 20, weight: .bold)
        //        priceLabel.textColor = .black
        priceLabel.text = price.inRialFormat().inLocalizedLanguage() + " " + "CURRENCY".localized
        priceLabel.textColor = UIColor.iGapGreen()
        
        priceLabel.textAlignment = .center
        dialogView.addSubview(priceLabel)
        
        
        let imageView = UIImageView()
        imageView.frame.origin = CGPoint(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8)
        imageView.frame.size = CGSize(width: dialogViewWidth - 16 , height: dialogViewWidth - 16)
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        //        dialogView.addSubview(imageView)
        let separatorView2 = UIView()
        separatorView2.frame.origin = CGPoint(x: 0, y: priceLabel.frame.height + priceLabel.frame.origin.y + 8)
        separatorView2.frame.size = CGSize(width: dialogViewWidth, height: 10)
        separatorView2.backgroundColor = UIColor.clear
        dialogView.addSubview(separatorView2)
        
        //BUTTON
        let btnAction = UIButton()
        btnAction.frame.origin = CGPoint(x: 8, y: separatorView2.frame.height + separatorView2.frame.origin.y + 8)
        btnAction.frame.size = CGSize(width: dialogViewWidth - 16 , height: 40)
        btnAction.layer.cornerRadius = 10.0
        btnAction.setTitle("BTN_PAY".localized, for: .normal)
        btnAction.titleLabel?.font = UIFont.igFont(ofSize: 17)
        btnAction.backgroundColor = UIColor.iGapGreen()
        btnAction.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        
        dialogView.addSubview(btnAction)
        
        let dialogViewHeight = titleLabel.frame.height + 8 + descriptionLabel.frame.height + 8 + priceLabel.frame.height + 8 + priceTitleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + separatorView1.frame.height + 8 + separatorView2.frame.height + 8 + btnAction.frame.height + 8
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    @objc func sendRequest(){
        IGHelperFinancial.shared.sendPayDirectRequest(inquery: inquery, amount: amount, toUserId: toUserID, invoiceNUmber: invoiceNumber, description: descriptionR)
        dismiss(animated: true)
        
        
    }
}


