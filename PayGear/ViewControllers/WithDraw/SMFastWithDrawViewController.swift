//
//  SMFastWithDrawViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/29/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import  SafariServices

class SMFastWithDrawViewController: SMScrolableButtonViewController, IndicatorInfoProvider,handleOk,Keyboard,UITextFieldDelegate,HandleReciept {
    
	
    
	var merchant : SMMerchant!
	var sourceCard: SMCard!
    var itemInfo = IndicatorInfo(title: "View")
    var innerView:SMFastView?
    var heightConstraint:NSLayoutConstraint?
    var finishDelegate : HandleDefaultCard?
    var cashOutCards = [SMCashout]()
    let heightOfComponent : CGFloat = 220.0
    var selectCard : SMCashout?
   
	
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    @IBAction func shabaTapped(_ sender: Any) {
		
		guard let url = URL(string: "https://paygear.ir/iban") else {
			return //be safe
		}
		let svc = SFSafariViewController(url: url)
		self.present(svc, animated: true, completion: nil)
        
    }
    

    override func viewWillLayoutSubviews() {
        if self.parent != nil && self.view.frame.width < (self.parent?.view.frame.width)! {
        self.view.frame.size = (self.parent?.view.frame.size)!
        innerView?.frame.size = self.view.frame.size
        self.view.frame.origin = CGPoint.init(x: 0, y: 0)
            self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute:.top, multiplier: 1, constant: 0))

            self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
            
        self.view.layoutIfNeeded()
        }
        
    }
    
    
    func up(hieght : CGFloat?) {
        
        heightConstraint?.constant =  (hieght ?? 0.0)
        self.view.layoutIfNeeded()
        //(self.view.subviews[0] as! UIScrollView).contentSize = CGSize.init(width: self.view.frame.width, height: hieght ?? 0.0)
    }
    
    func down(hieght : CGFloat?) {
        
        heightConstraint?.constant = 0.0
        self.view.layoutIfNeeded()
        //(self.view.subviews[0] as! UIScrollView).contentSize = CGSize.init(width: self.view.frame.width, height: hieght ?? 0.0)
    }
    
    
    
    @IBAction func savedCardsClicked(_ sender: Any) {
        self.view.endEditing(true)
        SMLoading.shared.showSavedCardDialog(viewController: self, icon: nil, title: "savedcards".localized, cards: self.cashOutCards,yesPressed: { card, saveDefault in
            self.selectCard = (card as! SMCashout)
            if let pan = self.selectCard?.pan {
				
				self.innerView?.cardType = .cardToken
                   let newStr = pan
                   self.innerView?.secondTextField.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
                
            }
        },noPressed: {
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        innerView = SMFastView.instanceFromNib(type: "fast")
        innerView?.delegate = self
        innerView?.frame = self.view.bounds
        innerView?.translatesAutoresizingMaskIntoConstraints = false
        innerView?.paygearBalance.text = itemInfo.balance
        innerView?.cashableBalance.text = itemInfo.balance
        self.view.addSubview(innerView!)
        
        self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute:.top, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: innerView!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        
        heightConstraint = NSLayoutConstraint(item: innerView!.contentView, attribute: .height, relatedBy: .equal, toItem: innerView, attribute: .height, multiplier: 1, constant: 50)
        self.view.addConstraint(NSLayoutConstraint(item: innerView!.contentView, attribute: .width, relatedBy: .equal, toItem: innerView, attribute: .width, multiplier: 1, constant: 0))
        
        self.view.addConstraint(heightConstraint!)
        self.delegate = self
        self.innerView?.secondTextField.delegate = self
        self.innerView?.amountTextField.delegate = self
		self.innerView?.savedCardBtn.addTarget(self, action: #selector(savedCardsClicked(_:)), for: .touchUpInside)
        
		
		if merchant != nil {
			innerView?.savedCardBtn.isHidden = true
		}
		else {
			self.cashOutCards = SMCashout.getAllCardsFromDB()
		}
		
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
   
    override func viewDidLayoutSubviews() {
        innerView?.okButton.layer.cornerRadius = (innerView?.okButton.frame.height)! / 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func okpressed(amountStr:String? , cardNumber : String?) {
		
		guard let amount = Int(amountStr!.onlyDigitChars()) else {
			return
		}
		
		guard let cardNu = cardNumber?.onlyDigitChars() else {
			return
		}
		
		if  amount <=  Int(itemInfo.balance!.inEnglishNumbers().onlyDigitChars())! {
			
			let accountId = (merchant != nil) ? merchant.id : SMUserManager.accountId
           gotoLoadingState()
			SMCard.confirmChashout(amount: amount,
								   cardNumber: (innerView?.cardType == .cardNumber) ? cardNu : "",
								   cardToken:  (innerView?.cardType == .cardToken) ? (self.selectCard?.token)! : "",
								   accountId: accountId , onSuccess: {resp in
                                    self.gotobuttonState()
				let result = self.prepareConfirm(resp: resp, amount: amountStr)
				SMLoading.shared.showConfirmDialog(viewController: self, height: 292, title: "cashout.request".localized, message: result, yesPressed: { pin in
					
					if self.merchant == nil, SMUserManager.pin == nil || SMUserManager.pin == false {
						let vc = SMWalletPasswordViewController.init(style: .grouped)
						SMMainTabBarController.packetTabNavigationController.pushViewController(vc , animated: true)
                    }
					else if self.merchant != nil, self.sourceCard != nil, self.sourceCard.protected! == false {
						let vc = SMWalletPasswordViewController.init(style: .grouped)
						vc.cardInfo = self.sourceCard
						vc.merchant = self.merchant
						SMMainTabBarController.packetTabNavigationController.pushViewController(vc , animated: true)
					}
					else {
						SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
                            self.gotoLoadingState()
							var sourceCardToken = ""
							if self.sourceCard != nil { sourceCardToken = self.sourceCard.token! } else { sourceCardToken = SMUserManager.payGearToken! }
							SMCard.chashout(amount: amount , cardNumber: cardNu.count != 16 ? "": cardNu, cardToken: self.selectCard?.token ?? "", sourceCardToken:sourceCardToken,  pin: (pin as? String) ,isFast : true, accountId: accountId ,onSuccess: {resp in
                                self.gotobuttonState()
                                SMLoading.shared.showNormalDialog(viewController: self, height: 180,isleftButtonEnabled: false, title: "cashoutSuccess".localized, message: "success".localized, yesPressed: { pin in
                                    self.view.endEditing(true)
                                    self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
									if self.merchant != nil {
										SMMainTabBarController.packetTabNavigationController.popViewController(animated: false)
									}
									else {
                                    	SMMainTabBarController.packetTabNavigationController.popToRootViewController(animated: false)
									}
                                    
                                })
								SMLog.SMPrint(resp)
							}, onFailed: {err in
								self.gotobuttonState()
								SMLog.SMPrint(err)

									if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
									SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
								}
							})
							
						}, noPressed: { value in 
						
						}, forgotPin: {
							
//							DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
								let vc = SMResetPasswordTableViewController.init(style: .grouped)
								vc.cardInfo = self.sourceCard
								vc.merchant = self.merchant
								SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
								
//							})
							
						})
					}
				}, noPressed: {
					
					
				})
				SMLog.SMPrint(resp)
				
			}, onFailed: {err in
				//?
				self.gotobuttonState()
				if SMValidation.showConnectionErrorToast(err)  {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
				
			})
			
		} else {
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "cashout.request".localized, message: "balance.not.enough".localized ,yesPressed :{yes in
                
            })
		}
	}
	
    
    func gotoLoadingState(){
        self.view.endEditing(true)
        innerView?.okButton.gotoLoadingState()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func gotobuttonState(){
        innerView?.okButton.gotoButtonState()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    

    func prepareConfirm(resp : Any?,amount: String?)->NSMutableDictionary{
        
        let result = NSMutableDictionary()
        let personalItems = ((resp as! NSDictionary)["owner"]as! NSDictionary)
        let cardItems = ((resp as! NSDictionary)["destination_card_info"]as! NSDictionary)
        
        result["amountin".localized] =  amount
        result["amountout".localized] = amount
        result["wage".localized] = "\((resp as! NSDictionary)["transfer_fee"]!)".inRialFormat().inLocalizedLanguage()
        result["dest_card".localized] = "\(cardItems["card_number"]!)"
        result["dest_bank".localized] = "\(personalItems["bank_name"]!)"
        result["ownername".localized] = "\(personalItems["first_name"]!)" + " " + "\(personalItems["last_name"]!)"
        return result
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newStr = string
        
        if textField.tag == 1 {
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inLocalizedLanguage()
        }
        else {
			
			selectCard = nil
			innerView?.cardType = .cardNumber
                if (textField.text?.contains("*"))!{
                    textField.text = ""
                 }
                else{
                    newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
                    textField.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
                    
                }
        }
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        return false
    }
    
    func close() {
        self.dismiss(animated: false, completion: {
            self.view.endEditing(true)
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
            if let barcode = SMMainTabBarController.currentSubNavNavigation.viewControllers[0] as? SMBarCodeScannerViewController{
                barcode.finishedPayment()
            }
            
            
            SMMainTabBarController.packetTabNavigationController.popToRootViewController(animated: false)
            
        })
        
    }
    
    func screenView() {
        SMReciept.getInstance().screenReciept(viewcontroller: self)
    }
    
    
}
