//
//  MerchantViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 7/16/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// This view controller shows the merchant view;
/// Some user in system has merchant, so they see an icon on top right of wallet page
/// by touching that icon, they see list of their merchant. Selecting each item
/// loads this view controller, this view controller needs to have merchant info
class SMMerchantViewController: UIViewController, HandleDefaultCard {
	
	

	var merchant : SMMerchant!
    @IBOutlet var merchantScrollView: UIScrollView!
    let refreshControl = UIRefreshControl()
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var titleView: UIView!
	@IBOutlet var amountLbl: UILabel!
	@IBOutlet var currencyLbl: UILabel!
	@IBOutlet var cashoutPaymentBtn: SMGradientButton!
	@IBOutlet var indicator: UIActivityIndicatorView!
	@IBOutlet var historyTitleView: UIView!
	@IBOutlet var historyTitle: UILabel!
	
	@IBOutlet var cashoutBtnConstraintHieght: NSLayoutConstraint!
	
	var historyVC : SMHistoryTableViewController!
	var merchantCard : SMCard?
    var finishDel : HandleDefaultCard?
    
	
    /// Load view and titles
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.SMTitle = merchant.name
		let transform = SMDirection.PageAffineTransform()
		self.titleView.transform = transform
		self.titleLbl.transform = transform
		self.historyTitleView.transform = transform
		self.historyTitle.transform = transform
		
		titleLbl.text = "merchant_paygear_card_balance".localized
		historyTitle.text = "history".localized
		titleLbl.textAlignment = SMDirection.TextAlignment()
		historyTitle.textAlignment = SMDirection.TextAlignment()
		currencyLbl.text = "Currency".localized
		cashoutPaymentBtn.setTitle("packet.withdraw".localized, for: .normal)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
			self.cashoutPaymentBtn.layer.cornerRadius = self.cashoutPaymentBtn.frame.height / 2
		}
		getCard()
        setUpScrollView()
		
		if merchant.role! != "admin" {
//			cashoutBtnConstraintHieght.constant = 0
//			self.viewDidLayoutSubviews()
			cashoutPaymentBtn.isHidden = true
		}
    }
    

    // MARK: - Navigation
    
    /// set up scrollview content and refrsh controll
    private func setUpScrollView() {
//        refreshControl.tintColor = #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1)
        refreshControl.addTarget(self, action: #selector(handlePulltoRefresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.merchantScrollView.refreshControl = self.refreshControl
        } else {
            self.merchantScrollView.addSubview(self.refreshControl)
        }
    }
    
    /// view pull to refresh handler
    @objc private func handlePulltoRefresh() {
        getCard()
        historyVC.pullToRefresh()
        SMLoading.showLoadingPage(viewcontroller: historyVC)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /// Load history of merchant by container view
    ///
    /// - Parameters:
    ///   - segue: segue information
    ///   - sender: sender ?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		let destination = segue.destination
		if let history = destination as? SMHistoryTableViewController {
			historyVC = history
			historyVC.accountId = merchant.id!
		}
    }

	/// Show merchant QR code (like my QR code)
	///
	/// - Parameter sender: sender object
	@IBAction func showMerchantQRCode(_ sender: Any) {
	
		SMNavigationController.shared.style = .SMMainPageStyle
		let myQRVC = SMMainTabBarController.packetTabNavigationController.findViewController(page: .MyQR) as! SMMyBarCodeViewController
		myQRVC.merchant = merchant
		SMMainTabBarController.packetTabNavigationController.pushViewController(myQRVC, animated: true)
	}
	
	/// Show history page as a full view controller
	///
	/// - Parameter sender: sender
	@IBAction func fullHistoryDidSelect(_ sender: Any) {
		
		let vc = SMMainTabBarController.packetTabNavigationController.findViewController(page: .HistoryTable) as! SMHistoryTableViewController
		vc.accountId = merchant.id
		SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
	}
	
	/// Cashout page (Admin role of merchant is able to cashout the money,
	/// by this action merchant goes to cashout.
	@IBAction func cashoutDidSelect(_ sender: Any) {
		
		let vc = SMNavigationController.shared.findViewController(page: .WithDraw) as! SMWithDrawTabStripController
		vc.balance = amountLbl.text!
		vc.finishDelegate = self
		vc.merchant  = merchant
		vc.sourceCard = merchantCard
		SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
		
	}
	
	/// Protocol method
	func finishDefault(isPaygear: Bool?, isCard: Bool?) {
		if indicator.isAnimating {
			return;
		}
		
		if  isCard == true {
			SMLoading.showLoadingPage(viewcontroller: self)
		} else if isCard! == false && isPaygear == true {
			amountLbl.isHidden = true
			indicator.startAnimating()
		}
		
		getCard()
		historyVC.pullToRefresh()
        
	}
	
	/// Protocol method
	func valueChanged(value: Bool) {

	}
	
	func getCard(){
        if !self.refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
		
		DispatchQueue.main.async {
			SMCard.getMerchatnCardsFromServer(accountId: self.merchant.id!, { (value) in
				if let card = value {
					self.merchantCard = card as? SMCard
					self.preparePayGearCard()
				}
                self.refreshControl.endRefreshing()
			}, onFailed: { (value) in
				// think about it
				self.indicator.stopAnimating()
				self.amountLbl.isHidden = false
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
                self.refreshControl.endRefreshing()
			})
		}
	}
	
	func preparePayGearCard() {
		if let card = merchantCard {
			if card.type == 1 {
				amountLbl.isHidden = false
				amountLbl.text = String.init(describing: card.balance ?? 0).inRialFormat().inLocalizedLanguage()
                finishDel?.finishDefault(isPaygear: true, isCard: false)
				indicator.stopAnimating()
			}
		}
	}
}
