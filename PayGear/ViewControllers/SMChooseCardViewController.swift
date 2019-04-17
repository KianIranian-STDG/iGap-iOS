//
//  ChooseCardViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/21/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import Wallet
import SwiftyRSA
import maincore


class SMChooseCardViewController: SMBottomButtonViewController, VCPayDelegate, HandleDefaultCard, HandleReciept {
    
    @IBOutlet weak var blueHeader: SMBlueHeader!
    @IBOutlet weak var walletHeaderView: UIView!
	@IBOutlet weak var cardHeaderView: UIView!
    @IBOutlet weak var walletView: WalletView!
    @IBOutlet weak var addCardViewButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var cardTitle: UILabel!
	@IBOutlet weak var amountTitle: UILabel!
	
    var amount = ""
    
    var toAccountId : String?
    var amountView = SMBlueHeader()
    var userCards : [SMCard]?
    var defaultCard = [SMDefaultCard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletView.walletHeader = walletHeaderView
        
        let amountInt = Int(amount)
        let account = toAccountId 
        SMLoading.showLoadingPage(viewcontroller: self)
        SMCard.initPayment(amount: amountInt,accountId: account, onSuccess: { response in
            SMLoading.hideLoadingPage()
            let json = response as? Dictionary<String, AnyObject>
            if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                if let url = URL(string: ipg) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            else{
            SMUserManager.publicKey = json?["pub_key"] as? String
            SMUserManager.payToken = json?["token"] as? String
            }
        }, onFailed: {err in
            SMLoading.hideLoadingPage()
            SMLog.SMPrint(err)
        })
        let myAttribute = [NSAttributedString.Key.font: SMFonts.IranYekanBold(14) ]
        let myString = NSMutableAttributedString(string: amount.inRialFormat().inLocalizedLanguage(), attributes: myAttribute )
		myString.append(NSAttributedString(string: " "))
        let attrString = NSAttributedString(string: "Currency".localized)
        myString.append(attrString)
        amountLabel.attributedText = myString
        walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            self?.showAddCardViewButtonIfNeeded()
            self?.addCardViewButton.addTransitionFade()
        }
        self.SMTitle = "chooseCard".localized
		cardTitle.text = "my_cards".localized
		amountTitle.text = "pay.header.title".localized
        userCards = SMCard.getAllCardsFromDB()
        
        DispatchQueue.main.async {
            self.reloadCardViews(userCards: self.userCards!)
        }
		
		let transform = SMDirection.PageAffineTransform()
		cardHeaderView.transform = transform
		cardTitle.transform = transform
		cardTitle.textAlignment = SMDirection.TextAlignment()
		
        
        // Do any additional setup after loading the view.
    }
    
    func finishPassing(card: SMCardView) {
        do{
            self.view.endEditing(true)
            //Encrypt a string with the public key
            
            let para  = NSMutableDictionary()
            
            para.setValue(card.card.token, forKey: "c")
            para.setValue(card.selectCardView?.secondPassTextField.text?.onlyDigitChars().inEnglishNumbers(), forKey: "p2")
            para.setValue(card.card.type, forKey: "type")
            para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
            para.setValue(card.card.bankCode, forKey: "bc")
            para.setValue(card.selectCardView?.cvv2TextField.text?.onlyDigitChars().inEnglishNumbers(), forKey: "cv")
            if card.card.token == nil{
                para.setValue(card.numberLabel?.text, forKey: "c")
                para.setValue(card.card.exp_m, forKey: "em")
                para.setValue(card.card.exp_y, forKey: "ey")
            }
            let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            self.gotoLoadingState()

            if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey)
            {
                SMCard.payPayment(enc: enc, onSuccess: {resp in
                    self.gotobuttonState()
                    if let result = resp as? NSDictionary{
                        SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                    }
                }, onFailed: {err in
                    SMLog.SMPrint(err)

						if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
						SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
					}
                    self.gotobuttonState()
                })
            }
            
        }catch{
            SMLog.SMPrint(error)
        }
    }
    
    
    
    
    
    func gotoLoadingState(){
        (self.walletView.presentedCardView as! SMCardView).payCardViewButton?.gotoLoadingState()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func gotobuttonState(){
        (self.walletView.presentedCardView as! SMCardView).payCardViewButton?.gotoButtonState()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    
    
    
    
    
    
    
    var finishDelegate : HandleDefaultCard?
    
    
    
    
    func finishDefault(isPaygear: Bool?, isCard: Bool?) {
        SMCard.getAllCardsFromServer({ cards in
            
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0{
                        
                        self.walletView.dismissPresentedCardView(animated: true)
                        self.userCards = SMCard.getAllCardsFromDB()
                        self.reloadCardViews(userCards: self.userCards!)
                        self.finishDelegate?.finishDefault(isPaygear: isPaygear, isCard: isCard)
                    }
                }
            }
        }, onFailed: {err in
			
			if SMValidation.showConnectionErrorToast(err) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
        })
    }
	
	func valueChanged(value: Bool) {
		
		let cardview = (self.walletView?.presentedCardView as? SMCardView)
		
		if cardview!.card.token != nil {
			cardview!.isDefaultView?.loading.startAnimating()
			cardview!.isDefaultView?.loading.isHidden = false
			cardview!.isDefaultView?.isUserInteractionEnabled = false
			SMCard.defaultCardFromServer(cardview!.card.token,isDefault: "\(value)", onSuccess: {
				cardview!.isDefaultView?.loading.stopAnimating()
				cardview!.isDefaultView?.loading.isHidden = true
				cardview!.isDefaultView?.isUserInteractionEnabled = true
			}, onFailed: {err in
				
				if SMValidation.showConnectionErrorToast(err) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
					cardview!.isDefaultView?.loading.stopAnimating()
					cardview!.isDefaultView?.loading.isHidden = true
					cardview!.isDefaultView?.isUserInteractionEnabled = true
					cardview!.isDefaultView?.isDefault.isOn = !(cardview!.isDefaultView?.isDefault.isOn)!
				})
				
			})
		}
		else{
		}
	}
    
    
    
    func reloadCardViews(userCards : [SMCard]){
        if userCards.count > 1 {
            let cardViews = SMCardView.prepareCardViews(userCards: userCards, isPay: true )
            for card in cardViews{
                card.defaultDelegate = self
            }
            self.walletView.setNeedsLayout()
            self.walletView.reload(cardViews: cardViews)
            
            self.walletView.layoutIfNeeded()
            
        }
        else{
            defaultCard = SMDefaultCard.prepareDefaultCard()
            defaultCard[0].addCardButton.addTarget(self, action: #selector(self.addCardViewAction(_:)), for: .touchUpInside)
            self.walletView.reload(cardViews: defaultCard)
        }
    }
	
    func showAddCardViewButtonIfNeeded() {
        if walletView.presentedCardView == nil || walletView.insertedCardViews.count < 1 {
            addCardViewButton.alpha = 1.0
            walletHeaderView.isHidden = false
            amountView.isHidden = true
            for card in walletView.insertedCardViews{
                let cardV = (card as! SMCardView)
                cardV.selectCardView?.isHidden = true
                cardV.topconstraint?.constant = 0
                cardV.layoutIfNeeded()
            }
        }
        else{
            addCardViewButton.alpha = 0.0
            walletHeaderView.isHidden = true
            amountView.isHidden = false
            let cardV = (walletView.presentedCardView as! SMCardView)
            cardV.selectCardView?.isHidden = false
            cardV.frame.origin.y = (walletView.walletHeader?.frame.height)!
            cardV.topconstraint?.constant = 20
            cardV.layoutIfNeeded()
            cardV.delegate = self
        }
        
    }
    
    
    @IBAction func addCardViewAction(_ sender: Any) {
        let vc = SMMainTabBarController.currentSubNavNavigation.findViewController(page: .AddCard) as! SMAddCardViewController
        vc.finishDelegate = self
        SMMainTabBarController.currentSubNavNavigation.pushViewController(vc, animated: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func close() {
        SMReciept.getInstance().recieptPage?.dismiss(animated: false, completion: {
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






