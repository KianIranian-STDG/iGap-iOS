//
//  SMPacketViewController.swift
//  PayGear
//
//  Created by a on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import Wallet
import webservice
import Crashlytics

class SMPacketViewController : UIViewController,HandleDefaultCard,HandleReciept, KPDropMenuDelegate {
   
    
	
	@IBOutlet weak var titleView: UIView!
	@IBOutlet weak var pageTitleLabel: UILabel!
	@IBOutlet var titleViewIcons: [UIView]!
    @IBOutlet weak var amountValueLabel: UILabel!
	@IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var walletView: WalletView!
    @IBOutlet weak var walletHeaderView: UIView!
	
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var addCardViewButton: UIButton!
    @IBOutlet weak var reachebleBalanceTextField: UILabel!
    @IBOutlet weak var giftTextField: UILabel!
    @IBOutlet weak var paygearCharge: SMGradientButton!
    @IBOutlet weak var paygearPay: SMGradientButton!
    @IBOutlet weak var amountStack: UIStackView!
    @IBOutlet weak var paygearAmountLoading: UIActivityIndicatorView!
    var defaultCard = [SMDefaultCard]()
    var userCards: [SMCard]?
	var userMerchants: [SMMerchant]?
	var dropDown: KPDropMenu?
    
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		let transform = SMDirection.PageAffineTransform()
		self.titleView.transform = transform
		self.pageTitleLabel.transform = transform
		self.titleViewIcons.forEach { (view) in
			view.transform = transform
		}
		self.cardView.transform = transform
		self.cardTitleLabel.transform = transform

		pageTitleLabel.text = "paygear_card_balance".localized
		cardTitleLabel.text = "my_cards".localized
		self.pageTitleLabel.textAlignment = SMDirection.TextAlignment()
		self.cardTitleLabel.textAlignment = SMDirection.TextAlignment()
		currencyLabel.text = "Currency".localized
		
        //SMLoading.showLoadingPage(viewcontroller: self)
		walletView.walletHeader = walletHeaderView
		
		
		paygearCharge.setTitle("packet.pay".localized, for: .normal)
		paygearPay.setTitle("packet.withdraw".localized, for: .normal)
		
		paygearCharge.layer.cornerRadius = paygearCharge.frame.height / 2
		paygearPay.layer.cornerRadius = paygearCharge.frame.height / 2
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.ipg_success(notification:)), name: Notification.Name("ipg_success"), object: nil)
		
		walletInitial()
		
		userMerchants = SMMerchant.getAllMerchantsFromDB()

		
    }
    
    
	func walletInitial() {
		walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
			self?.showAddCardViewButtonIfNeeded()
			//			self?.addCardViewButton.addTransitionFade()
		}
		DispatchQueue.main.async {
			self.userCards = SMCard.getAllCardsFromDB()
			self.preparePayGearCard()
			self.walletView.presentedCardView = nil
			self.reloadCardViews(userCards: self.userCards!)
		}
		
		SMInitialInfos.AtLeastOneFailedDelegate = {
			SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
		}
		
		self.walletView.enabledPullToRefresh = true
		self.walletView.refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)

	}
	func getMerchantData() {
		
		SMMerchant.getAllMerchantsFromServer(SMUserManager.accountId, { (response) in
			
			self.userMerchants = SMMerchant.getAllMerchantsFromDB()
			self.setupUI()
			
		}) { (error) in
			//
		}
	}
	func getMerchantDataToDropDown()-> [Dictionary<String, Any>] {
		var list : [Dictionary<String, Any>] = []
		
		for merchant in userMerchants! {
			if (merchant.role != nil) {
				var dic: Dictionary<String, AnyObject> = [:]
				dic["id"] = merchant.id as AnyObject
				dic["name"] = merchant.name as AnyObject
				
				if merchant.businessType != nil {
					dic["role"] = "\((merchant.role)?.localized as AnyObject) - \(SMMerchant.roleString[merchant.businessType!])" as AnyObject
				}
				else {
					dic["role"] = (merchant.role)?.localized as AnyObject
				}
				let name = (merchant.accountType == 2) ?  "profile.png" : "\(String(describing: merchant.id!)).png"
				if  let profileImage = SMImage.getImage(imageName: name){
					//I got the image
					dic["image"] = profileImage as AnyObject
				}
				else {
					
					dic["image"] = UIImage.init(named: "oval")! as AnyObject
				}
				dic["profilePicture"] = merchant.profilePicture as AnyObject
				dic["type"] = merchant.accountType as AnyObject
				
				list.append(dic)
			}
		}
		return list
	}

    @objc func ipg_success (notification : AnyObject ){
        let orderId = notification.userInfo["order_id"] as! String
        if self.tabBarController?.selectedIndex == 0 {
        SMLoading.showFullPageLoading(viewcontroller: self)
        SMHistory.getHistoryFromServer(last: "", itemCount: 5, {
            success in
			
            SMLoading.hideFullPageLoading()
            print(success as Any)
            if let rowData = (success as? [PAY_obj_history])
            {
            var row : PAY_obj_history = PAY_obj_history()
                for item in rowData{
                if orderId == item._id{ row = item; break;}
            }
            
                let date = Date.init(timeIntervalSince1970: TimeInterval((row.pay_date != 0 ? row.pay_date: row.created_at_timestamp)/1000)).localizedDateTime()
                let dic = ["recieveName".localized : row.receiver.name ,"transType".localized : SMStringUtil.getTransType(type: (row.transaction_type.rawValue)), "status".localized :  (row.is_paid) == IS_PAID_STATUS.PAID ? "success.payment".localized : "history.paygear.receive.waiting".localized , "amount".localized : row.amount  ,"invoice_number".localized : row.invoice_number,"date".localized : date] as [String : Any]
            let result = ["result" : dic ] as NSDictionary
            SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
            }
        }, onFailed: { error in
            SMLog.SMPrint(error)
            SMLoading.hideFullPageLoading()
            
        })
        }
        
    }
	
	@objc
	func gotToSubPage(page: Int) {
		
		if page == 0 {
			//show charge
			chargePressed(nil)
		}
		else if page == 1 {
			//show my withdraw
			payPress(nil)
		}
		else if page == 2 {
			myQRCodeIsSelected()
		}
		
	}
	
	@objc func refresh(sender:AnyObject) {
		//my refresh code here..
        finishDefault(isPaygear: true,isCard: true)
		getMerchantData()
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
			self.walletView.refreshControl.endRefreshing()
		}
		self.viewWillAppear(false)
	}
	
	func hide(animated: Bool, myCompletionHandler: ((Bool) -> ())?) {
		if animated {
			
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
			}, completion: myCompletionHandler) // I want to run 'myCompletionHandler' in this completion handler
		}
	}
    @IBAction func historyPressed(_ sender: Any) {
        
        SMNavigationController.shared.style = .SMMainPageStyle
        SMMainTabBarController.packetTabNavigationController.pushNewViewController(page: .HistoryTable)
    }
	
	@IBAction func currencyPressed(_ sender: Any) {
		
		myQRCodeIsSelected()
	}
	
	func myQRCodeIsSelected() {
		SMNavigationController.shared.style = .SMMainPageStyle
		SMMainTabBarController.packetTabNavigationController.pushNewViewController(page: .MyQR)
	}
    var waitToRefresh = false
    
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
        if paygearAmountLoading == nil {
            waitToRefresh = true; return;
        }
        
        if isCard == true {
            SMLoading.showLoadingPage(viewcontroller: self)
        }
        else if isCard! == false && isPaygear == true {
            paygearAmountLoading.isHidden = false
            amountValueLabel.isHidden = true
            paygearAmountLoading.startAnimating()
        }
        waitToRefresh = false
        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
                        self.walletView.dismissPresentedCardView(animated: true)
                        self.walletHeaderView.alpha = 1.0
                        self.userCards = SMCard.getAllCardsFromDB()
                        if   isPaygear!{
                            self.preparePayGearCard()
                            self.paygearAmountLoading.isHidden = true
                            self.amountValueLabel.isHidden = false
                            self.paygearAmountLoading.stopAnimating()
                        }
                        if isCard!{
                            self.reloadCardViews(userCards: self.userCards!)
                            SMLoading.hideLoadingPage()
                        }
                    }
                }
            }
        }, onFailed: {err in
            self.paygearAmountLoading.isHidden = true
            self.amountValueLabel.isHidden = false
            self.paygearAmountLoading.stopAnimating()
            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
        })
    }
    
    @objc func showProfile(){
         SMNavigationController.shared.style = .SMMainPageStyle
         SMMainTabBarController.packetTabNavigationController.pushNewViewController(page: .ProfilePage)

		
    }
	
	@objc func showSetting(){
		SMNavigationController.shared.style = .SMMainPageStyle
		let settingVC = SMSettingViewController(style: .grouped)
		SMMainTabBarController.packetTabNavigationController.pushViewController(settingVC , animated: true)
	}
	
	@objc func showMerchatProfiles() {
		
		
	}
	

	
    func preparePayGearCard(){
        self.walletView?.walletHeader?.alpha = 1.0
        if let cards = userCards {
            for card in cards {
                
                if card.type == 1{
                    
                    amountValueLabel.text = String.init(describing: card.balance ?? 0).inRialFormat().inLocalizedLanguage()
                    reachebleBalanceTextField.text = String.init(describing: card.cashablebalance ?? 0).inRialFormat().inLocalizedLanguage()
                    SMUserManager.payGearToken = card.token
                    paygearAmountLoading.isHidden = true
                    amountValueLabel.isHidden = false
                    if ((card.balance ?? 0) - (card.cashablebalance ?? 0)) == 0 {
                        self.descView.isHidden = true
                        
                    }
                    else{
                        self.descView.isHidden = false
                    }
                }
            }
        }
    }
	
	@objc
    @IBAction func chargePressed(_ sender: Any?) {

        let vc = SMNavigationController.shared.findViewController(page: .PayAmount) as! SMPayAmountViewController
        vc.balance = amountValueLabel.text!
        vc.finishDelegate = self
        SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
    }
	
	@objc
    @IBAction func payPress(_ sender: Any?) {
        let vc = SMNavigationController.shared.findViewController(page: .WithDraw) as! SMWithDrawTabStripController
        vc.balance = amountValueLabel.text!
        vc.finishDelegate = self
        SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Handle controller being exposed from push/present or pop/dismiss
		self.tabBarController?.tabBar.isHidden = false
        setupUI()
        if (waitToRefresh){
            // Controller is being pushed on or presented.
            finishDefault(isPaygear: true, isCard: false)
        }
    }
    
	@objc func onProfileTapped(gesture:UITapGestureRecognizer){
		
		showProfile()
	}
	
	
	@objc func removeCardView(_ sender: Any) {
		
		
		SMLoading.shared.showNormalDialog(viewController: SMNavigationController.shared.viewControllers[0] , height: 180, isleftButtonEnabled: true, title: "card.remove.title".localized, message: "card.remove.message".localized, leftButtonTitle: "logout.cancel.btn".localized, rightButtonTitle:"card.remove.btn".localized , yesPressed: {obj in
			
			let cardview = (self.walletView?.presentedCardView as? SMCardView)
			cardview?.removeCardViewButton?.gotoLoadingState()
			cardview?.isUserInteractionEnabled = false
			SMCard.deleteCardFromServer(cardview?.card.token, onSuccess: {
				
				self.walletView?.dismissPresentedCardView(animated: true)
				self.walletView?.remove(cardView: cardview!, animated: true, completion : {
					if self.walletView?.insertedCardViews.count == 0  {
						self.finishDefault(isPaygear: false,isCard: true)
					}
				})
			}, onFailed: { err in
				cardview?.removeCardViewButton?.gotoButtonState()
				cardview?.isUserInteractionEnabled = true
				if SMValidation.showConnectionErrorToast(err) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
			})
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
	
	
	
	
    func reloadCardViews(userCards : [SMCard]) {
        if userCards.count > 1 {
            let cardViews = SMCardView.prepareCardViews(userCards: userCards, isPay: false)
            for card in cardViews {
                card.removeCardViewButton?.addTarget(self, action: #selector(self.removeCardView(_:)), for: .touchUpInside)
                card.defaultDelegate = self
                if card == cardViews.last {
                    card.cardNumberConstraint?.constant = card.frame.height
                    card.cardNumbertrainling?.constant = 50
                    card.numberLabel?.text = card.card.pan?.inLocalizedLanguage().printMaskedPanNumber().formatPanStringWith(char : "      ")
                    card.numberLabel?.textAlignment = .center
                }
                else {
                    card.cardNumberConstraint?.constant = 20
                    card.cardNumbertrainling?.constant = 0
                    card.numberLabel?.text = card.card.pan?.inLocalizedLanguage().printMaskedPanNumber().formatPanStringWith(char : "  ").substring(11)
                    card.numberLabel?.textAlignment = .left
                }
            }

            self.walletView.reload(cardViews: cardViews)
            self.walletView.layoutIfNeeded()
        }
        else {
            defaultCard = SMDefaultCard.prepareDefaultCard()
            defaultCard[0].addCardButton.addTarget(self, action: #selector(self.addCardViewAction(_:)), for: .touchUpInside)
            self.walletView.reload(cardViews: defaultCard)
        }

    }
    
    
    func showAddCardViewButtonIfNeeded() {
        if walletView.presentedCardView == nil || walletView.insertedCardViews.count < 1 {
            for card in (self.walletView?.insertedCardViews as! [SMCardView]){
                card.isDefaultView?.alpha = 0
                card.topconstraint?.constant = 0
                card.cardNumberConstraint?.constant = 20
                card.cardNumbertrainling?.constant = 0
                card.numberLabel?.text = card.card.pan?.inLocalizedLanguage().printMaskedPanNumber().formatPanStringWith(char : "  ").substring(11)
                card.numberLabel?.textAlignment = .left
                if card == self.walletView?.insertedCardViews.last{
                    card.cardNumberConstraint?.constant = card.cardGradientLayer!.frame.height * 0.4
                    card.cardNumbertrainling?.constant = (card.bankLogoImage?.frame.width)!
                    card.numberLabel?.text = card.card.pan?.printMaskedPanNumber().inLocalizedLanguage().formatPanStringWith(char : "      ")
                    card.numberLabel?.textAlignment = .center
					
                }
                card.cardGradientLayer?.layoutIfNeeded()
            }
            self.walletView.presentedCardView?.layoutIfNeeded()
        }
        else if self.walletView.presentedCardView is SMCardView{
            let smCardView = (self.walletView.presentedCardView as! SMCardView)
            smCardView.topconstraint?.constant = 20
            smCardView.cardNumberConstraint?.constant = smCardView.cardGradientLayer!.frame.height * 0.4
            smCardView.cardNumbertrainling?.constant = (smCardView.bankLogoImage?.frame.width)!
            smCardView.numberLabel?.text = smCardView.card.pan?.inLocalizedLanguage().printMaskedPanNumber().formatPanStringWith(char : "      ")
            smCardView.numberLabel?.textAlignment = .center
            self.walletView.presentedCardView?.layoutIfNeeded()
            self.walletView?.walletHeader?.alpha = 0.0
			
        }
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        let addViewController = SMMainTabBarController.packetTabNavigationController.findViewController(page: .AddCard) as! SMAddCardViewController
        addViewController.finishDelegate = self
        SMMainTabBarController.packetTabNavigationController.pushViewController(addViewController, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    @objc func setupUI(){
		
		
		let settingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		settingBtn.setImage(UIImage.init(named: "setting"), for: .normal)
		settingBtn.imageView?.contentMode = .scaleAspectFill
		settingBtn.imageView?.translatesAutoresizingMaskIntoConstraints = false
		settingBtn.imageView?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
		settingBtn.imageView?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
		settingBtn.translatesAutoresizingMaskIntoConstraints = false
		settingBtn.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
		settingBtn.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
		settingBtn.addTarget(self, action: #selector(self.showSetting), for: .touchUpInside)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingBtn)
		if SMUserManager.isUpdateAvailable {
			self.navigationItem.rightBarButtonItem?.addBadge(string: "!", andColor: UIColor(netHex: 0xff6d00))
		}
		
		if userMerchants?.count == 0 {
			NotificationCenter.default.addObserver(self, selector: #selector(self.setupUI), name:Notification.Name(SMConstants.notificationMerchant) , object: nil)
		}
		if (userMerchants?.count)! > 1 && dropDown == nil {
			
			dropDown = KPDropMenu.init(frame:CGRect(x: 0, y: 0, width: 40, height: 40))
			dropDown?.delegate = self
			dropDown?.backgroundImage = UIImage.init(named: "store")
			dropDown?.superView = self.view;
			dropDown?.directionDown = true
			dropDown!.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
			dropDown!.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
			dropDown?.items = getMerchantDataToDropDown()
			dropDown?.titleTextAlignment = .left
			dropDown?.titleColor = SMColor.PrimaryColor
			dropDown?.itemsFont = SMFonts.IranYekanRegular(14.0)

			self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingBtn), UIBarButtonItem(customView: dropDown!)]
			
		}
		
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        btn.imageView?.contentMode = .scaleAspectFill
        if  let profileImage = SMImage.getImage(imageName: "profile.png"){
            //I got the image
            btn.setImage(profileImage, for: .normal)
        }
        else {
            SMImage.saveImage(image: UIImage.init(named: "user")! , withName: "profile.png")
            btn.setImage(UIImage.init(named: "user")!, for: .normal)
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        btn.imageView?.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
        btn.imageView?.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        btn.imageView?.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.layer.masksToBounds = true
        btn.imageView?.layer.cornerRadius = 35/2
        
        btn.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        lbl.backgroundColor = .clear
        lbl.font = SMFonts.IranYekanRegular(15.0)
        lbl.text = SMUserManager.fullName.inLocalizedLanguage()
        lbl.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        lbl.textColor = .white
        lbl.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action:  #selector(SMPacketViewController.onProfileTapped(gesture:)))
        lbl.addGestureRecognizer(tap)

        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: btn),UIBarButtonItem(customView: lbl)]
	}
	
    func close() {
        self.dismiss(animated: true, completion: {
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.finishDefault(isPaygear: true,isCard: false)
        })
    }
    
    func screenView() {
         SMReciept.getInstance().screenReciept(viewcontroller: self)
    }
	
	func didSelectItem(_ dropMenu: KPDropMenu!, at atIndex: Int32) {
		if atIndex == 0 {
			self.tabBarController?.tabBar.isHidden = false
		}
		else {
			
			let index : Int = Int(atIndex)
			let merchant: SMMerchant = (userMerchants?[index])!
			self.tabBarController?.tabBar.isHidden = true
			let vc = SMNavigationController.shared.findViewController(page: .Merchant) as! SMMerchantViewController
			vc.merchant = merchant
            vc.finishDel = self
			self.navigationController?.pushViewController(vc, animated: true)
			
		}
	}
	
	func refresh(_ isRefresh: (() -> Void)!) {
		SMMerchant.getAllMerchantsFromServer(SMUserManager.accountId, { (res) in
			
			self.userMerchants = SMMerchant.getAllMerchantsFromDB()
			self.dropDown?.items = self.getMerchantDataToDropDown()
			isRefresh()
		}) { (err) in
			isRefresh()
		}
	}
}





